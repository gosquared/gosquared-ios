//
//  GSChatManager.m
//  GoSquared
//
//  Created by Edward Wellbrook on 04/02/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatManager.h"
#import "GSChatMessage.h"
#import "GSTrackerDelegate.h"
#import "GSRequest.h"

const int kGSChatMessageLimit = 20;

NSString * const kGSChatWebsocketURL             = @"/chat/v1/stream?site_token=%@&person_id=%@&auth=%@";
NSString * const kGSChatAnonymousIdURL           = @"/chat/v1/clientAuth?site_token=%@&client_id=%@";
NSString * const kGSChatAnonymousClaimURL        = @"/chat/v1/clientAuth?site_token=%@&person_id=%@&auth=%@";
NSString * const kGSChatMessagesURL              = @"https://api.gosquared.com/chat/v1/chats/%@/messages?site_token=%@&person_id=%@&auth=%@&limit=%d";
NSString * const kGSChatMessagesToTimestampURL   = @"https://api.gosquared.com/chat/v1/chats/%@/messages?site_token=%@&person_id=%@&auth=%@&limit=%d&to=%lu";
NSString * const kGSChatMessagesFromTimestampURL = @"https://api.gosquared.com/chat/v1/chats/%@/messages?site_token=%@&person_id=%@&auth=%@&limit=%d&from=%lu";


@interface GSTracker ()

@property (weak) id<GSTrackerDelegate> delegate;

@end


const NSComparator kTimestampComparator = ^NSComparisonResult(GSChatMessage *obj1, GSChatMessage *obj2) {
    if (obj1.timestamp == 0 && obj2.timestamp == 0) {
        return obj1.internalId >= obj2.internalId;
    } else if (obj1.timestamp == 0) {
        return NSOrderedDescending;
    } else if (obj2.timestamp == 0) {
        return NSOrderedAscending;
    } else {
        return obj1.timestamp >= obj2.timestamp;
    }
};

@interface GSChatManager () <GSTrackerDelegate>

@property (nonnull) GSTracker *tracker;
@property (nullable) NSString *configPerson;
@property (nullable) NSString *configSignature;

@property (nullable) SRWebSocket *webSocket;
@property (nonnull)  NSURLSession *URLSession;
@property (nonnull)  NSMutableArray *messages;
@property (nonnull)  NSMutableArray *pendingMessages;
@property (nullable) NSTimer *retryTimer;

@property int nextMessageId;
@property BOOL isConnected;
@property BOOL isLoadingMessages;
@property BOOL hasReachedEnd;
@property NSUInteger lastReadTimestamp;
@property (nonatomic) NSUInteger numberOfUnreadMessages;

// rate limitting
@property (nonnull) NSDate *lastSentTypingNotifTimestamp;

@end

@implementation GSChatManager

- (instancetype)init
{
    if (self = [super init]) {
        self.URLSession = [NSURLSession sharedSession];
        self.messages = [[NSMutableArray alloc] init];
        self.pendingMessages = [[NSMutableArray alloc] init];

        self.nextMessageId = 200;
        self.isConnected = NO;
        self.isLoadingMessages = NO;
        self.hasReachedEnd = NO;
        self.numberOfUnreadMessages = 0;
    }
    return self;
}

- (void)setNumberOfUnreadMessages:(NSUInteger)numberOfUnreadMessages
{
    _numberOfUnreadMessages = numberOfUnreadMessages;

    if ([self.delegate respondsToSelector:@selector(didUpdateUnreadMessageCount:)]) {
        [self.delegate didUpdateUnreadMessageCount:self.numberOfUnreadMessages];
    }
}

- (BOOL)isOpen {
    return self.isConnected;
}

- (void)setConfigWithTracker:(GSTracker *)tracker
{
    self.tracker = tracker;
    self.configPerson = tracker.personId;
    self.configSignature = tracker.signature;

    self.tracker.delegate = self;
}

- (BOOL)needsAnonymousId
{
    if (self.configPerson == nil) {
        return YES;
    } else {
        return NO;
    }
}

# pragma mark GSTrackerDelegate Methods

- (void)didIdentifyPerson
{
    [self identifyChatWithPersonId:self.tracker.personId signature:self.tracker.signature completionHandler:^(NSError *error) {
        if (error != nil) {
            return;
        }

        self.configPerson = self.tracker.personId;
        self.configSignature = self.tracker.signature;
    }];
}

- (void)didUnidentifyPerson
{
    [self closeWebSocket];
    self.configPerson = nil;
    self.configSignature = nil;
}


# pragma mark Public Methods

- (void)openWebSocket
{
    if (self.webSocket) {
        if (self.tracker.logLevel == GSLogLevelDebug) {
            NSLog(@"GSChat - WebSocket already open — cancelling");
        }
        return;
    }

    if (self.needsAnonymousId) {
        [self registerAnonymousIdWithVisitorId:self.tracker.visitorId completionHandler:^(NSString *signature, NSError *error) {
            if (error != nil) {
                return;
            }

            self.configPerson = self.tracker.visitorId;
            self.configSignature = signature;

            // open websocket with new config
            [self openWebSocket];
        }];
        return;
    }

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodGET
                                             path:[NSString stringWithFormat:kGSChatWebsocketURL, self.tracker.token, self.configPerson, self.configSignature]
                                             body:nil];

    [req sendWithCompletionHandler:^(NSDictionary *data, NSError *error) {
        if (error != nil) {
            if (self.tracker.logLevel == GSLogLevelQuiet) {
                NSLog(@"GSChat - Error getting WebSocket URL: %@", error);
            }
            return [self.delegate managerDidFailToConnect];
        }

        if (data == nil) {
            if (self.tracker.logLevel == GSLogLevelQuiet) {
                NSLog(@"GSChat - Error getting WebSocket URL: Empty response");
            }
            return [self.delegate managerDidFailToConnect];
        }

        NSURL *webSocketURL = [NSURL URLWithString:data[@"url"]];
        if (webSocketURL == nil) {
            return [self.delegate managerDidFailToConnect];
        }

        [self openWebSocketWithURL:webSocketURL];
    }];
}

- (void)openWebSocketWithURL:(NSURL *)URL
{
    if (self.webSocket) {
        if (self.tracker.logLevel == GSLogLevelDebug) {
            NSLog(@"GSChat - WebSocket already open — cancelling");
        }
        return;
    }

    self.webSocket = [[SRWebSocket alloc] initWithURL:URL];
    [self.webSocket setDelegate:self];

    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - Attempting to connect to WebSocket at URL: %@", URL);
    }

    [self.webSocket open];
}

- (void)closeWebSocket
{
    [self.webSocket close];

    self.webSocket = nil;
    self.isConnected = NO;
}

- (void)registerAnonymousIdWithVisitorId:(NSString *)visitorId completionHandler:(void (^)(NSString *signature, NSError *error))completionHandler
{
    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodGET
                                             path:[NSString stringWithFormat:kGSChatAnonymousIdURL, self.tracker.token, visitorId]
                                             body:nil];

    [req sendWithCompletionHandler:^(NSDictionary *data, NSError *error) {
        if (error != nil) {
            return completionHandler(nil, error);
        }

        if (data == nil) {
            return completionHandler(nil, [NSError errorWithDomain:@"com.gosquared" code:-1 userInfo:nil]);
        }

        NSString *signature = data[@"token"];
        if (signature == nil) {
            return completionHandler(nil, [NSError errorWithDomain:@"com.gosquared" code:-1 userInfo:data]);
        }

        return completionHandler(signature, nil);
    }];
}

- (void)identifyChatWithPersonId:(NSString *)personId signature:(NSString *)signature completionHandler:(void (^)(NSError *error))completionHandler
{
    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST
                                             path:[NSString stringWithFormat:kGSChatAnonymousClaimURL, self.tracker.token, personId, signature]
                                             body:@{
                                                    @"client_id": self.configPerson,
                                                    @"token": self.configSignature
                                                    }];

    [req sendWithCompletionHandler:^(NSDictionary *data, NSError *error) {
        if (error != nil) {
            return completionHandler(error);
        }

        completionHandler(nil);
    }];
}

- (void)loadMessageHistory
{
    if (self.isLoadingMessages) return;

    NSString *URLString;

    if (self.messages.count == 0) {
        URLString = [NSString stringWithFormat:kGSChatMessagesURL, self.configPerson, self.tracker.token, self.configPerson, self.configSignature, kGSChatMessageLimit];
    } else {
        NSInteger timestamp = [(GSChatMessage *)self.messages.firstObject timestamp];
        URLString = [NSString stringWithFormat:kGSChatMessagesToTimestampURL, self.configPerson, self.tracker.token, self.configPerson, self.configSignature, kGSChatMessageLimit, (long)timestamp];
    }

    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadMessageHistoryWithURL:URL];
}

- (void)loadMessageHistoryFrom:(NSUInteger)from
{
    if (self.isLoadingMessages) return;

    NSInteger timestamp = [(GSChatMessage *)self.messages.firstObject timestamp];
    NSString *URLString = [NSString stringWithFormat:kGSChatMessagesFromTimestampURL, self.configPerson, self.tracker.token, self.configPerson, self.configSignature, kGSChatMessageLimit, (long)timestamp];
    NSURL *URL = [NSURL URLWithString:URLString];

    [self loadMessageHistoryWithURL:URL];
}

- (void)loadMessageHistoryWithURL:(NSURL *)URL
{
    if (self.isLoadingMessages) {
        return;
    }

    self.isLoadingMessages = YES;

    if ([self.delegate respondsToSelector:@selector(didBeginLoadingHistory)]) {
        [self.delegate didBeginLoadingHistory];
    }

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodGET URL:URL body:nil];

    [req sendWithCompletionHandler:^(NSDictionary *data, NSError *error) {
        self.isLoadingMessages = NO;

        if (error) {
            if (self.tracker.logLevel == GSLogLevelQuiet) {
                NSLog(@"GSChat - Error getting messages: %@", error);
            }
            return [self.delegate didAddMessagesInRange:NSMakeRange(NSNotFound, NSNotFound) reachedEnd:self.hasReachedEnd];
        }

        if (!data) {
            if (self.tracker.logLevel == GSLogLevelQuiet) {
                NSLog(@"GSChat - Error getting messages: Empty repsonse");
            }
            return [self.delegate didAddMessagesInRange:NSMakeRange(NSNotFound, NSNotFound) reachedEnd:self.hasReachedEnd];
        }

        NSUInteger addedMessageCount = 0;
        NSMutableArray *msgs = [[NSMutableArray alloc] init];

        for (NSDictionary *item in [data[@"list"] reverseObjectEnumerator]) {
            GSChatMessage *message = [GSChatMessage messageWithDictionary:item];

            if (![self messageExists:message]) {
                [msgs addObject:message];
                [self.messages insertObject:message atIndex:0];
                addedMessageCount++;
            }
        }

        [msgs sortUsingComparator:kTimestampComparator];
        [self.messages sortUsingComparator:kTimestampComparator];

        if (self.messages.count == addedMessageCount && addedMessageCount != 0) {
            [self markDelivered:self.messages.lastObject];
        }

        self.hasReachedEnd = (addedMessageCount == 0);

        NSRange range = NSMakeRange([self.messages indexOfObject:msgs.firstObject], addedMessageCount);
        [self.delegate didAddMessagesInRange:range reachedEnd:self.hasReachedEnd];
        
        [self checkUnread];
    }];
}

- (void)sendMessage:(GSChatMessage *)message
{
    BOOL isRetry = [self.messages containsObject:message];

    if (!isRetry) {
        message.internalId = self.nextMessageId++;
        message.pending = YES;
    }

    if (!self.isConnected) {
        message.failed = YES;
    }

    if (isRetry) {
        [self.messages removeObject:message];
        [self.messages addObject:message];
        [self.delegate didUpdateMessageList];
    } else {
        [self.messages addObject:message];
        [self.delegate didAddMessage:message];
    }

    [self sendWithPayload:[message payloadValue] retryIfFailed:NO];
}

- (void)deleteMessage:(GSChatMessage *)message
{
    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - Deleting message: %@", message);
    }

    [self.messages removeObject:message];
    [self.delegate didUpdateMessageList];
}

- (void)markReadWithTimestamp:(NSNumber *)timestamp
{
    if ([timestamp isEqualToNumber:@0]) {
        return;
    }

    self.lastReadTimestamp = [timestamp longValue];
    [self checkUnread];

    if (!self.isConnected) {
        return;
    }

    NSDictionary *payload = @{
                              @"type": @"read",
                              @"timestamp": timestamp
                              };

    [self sendWithPayload:payload retryIfFailed:YES];
}

- (void)sendTypingNotification
{
    if (self.lastSentTypingNotifTimestamp == nil || self.lastSentTypingNotifTimestamp.timeIntervalSinceNow < -1) {
        NSDictionary *payload = @{
                                  @"type": @"typing",
                                  @"by": @"client"
                                  };

        [self sendWithPayload:payload retryIfFailed:YES];
        self.lastSentTypingNotifTimestamp = [[NSDate alloc] init];
    }
}


# pragma mark Private methods

- (void)sendWithPayload:(NSDictionary *)payload retryIfFailed:(BOOL)shouldRetry
{
    [self.pendingMessages removeObject:payload];

    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - Attempting to send: %@", payload);
    }

    if (self.isConnected) {
        [self.webSocket send:[NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:nil]];
    } else if (shouldRetry) {
        [self.pendingMessages addObject:payload];
    }
}

- (BOOL)messageExists:(GSChatMessage *)message
{
    for (GSChatMessage *msg in self.messages) {
        if ([msg.serverId isEqualToString:message.serverId]) {
            return YES;
        }
    }
    return NO;
}

- (void)markDelivered:(GSChatMessage *)message
{
    NSDictionary *payload = @{
                              @"type": @"delivered",
                              @"timestamp": @(message.timestamp)
                              };

    [self sendWithPayload:payload retryIfFailed:YES];
}

- (void)checkUnread
{
    if (self.lastReadTimestamp == 0 || self.isLoadingMessages) {
        return;
    }

    NSUInteger unread = 0;

    if (self.lastReadTimestamp > 0 && !self.isLoadingMessages) {
        for (GSChatMessage *message in self.messages) {
            if (message.timestamp > self.lastReadTimestamp && message.sender != GSChatSenderClient) {
                unread += 1;
            }
        }
    }

    self.numberOfUnreadMessages = unread;
}


#pragma mark WebSocket message handlers

- (void)handleReply:(NSDictionary *)payload
{
    NSNumber *messageId = payload[@"reply_to"];
    BOOL successful = [payload[@"success"] boolValue];

    NSInteger i = 0;
    for (GSChatMessage *message in self.messages) {
        if (message.internalId == [messageId intValue]) {
            message.serverId = payload[@"id"];

            if (successful) {
                message.pending = NO;
                message.failed = NO;
            } else {
                message.pending = YES;
                message.failed = YES;
            }

            return [self.delegate didUpdateMessageAtIndex:i];
        }
        i += 1;
    }
}

- (void)handleMessage:(NSDictionary *)payload
{
    GSChatMessage *msg = [GSChatMessage messageWithDictionary:payload];
    msg.pending = NO;

    if (msg.sender == GSChatSenderAgent && msg.personId != nil && ![msg.personId isEqualToString:self.configPerson]) return;

    NSUInteger idx = 0;
    BOOL idxShouldUpdateMessage = NO;
    for (GSChatMessage *message in self.messages) {
        if ([message.serverId isEqualToString:payload[@"id"]]) {
            idxShouldUpdateMessage = YES;
            break;
        }
        idx += 1;
    }

    if (idxShouldUpdateMessage) {
        self.messages[idx] = msg;
        [self.delegate didUpdateMessageAtIndex:idx];
        return;
    }

    [self.messages addObject:msg];
    [self.delegate didAddMessage:msg];

    if (msg.sender == GSChatSenderAgent) {
        [self markDelivered:msg];
        [self checkUnread];
    }
}

- (void)handleDelivered:(NSDictionary *)payload
{
    // this can be filled when we display message delivered state
}

- (void)handleRead:(NSDictionary *)payload
{
    // this can be filled when we display message read state
}

- (void)handleTyping:(NSDictionary *)payload
{
    NSString *sender = payload[@"by"];

    if ([self.delegate respondsToSelector:@selector(didReceiveTypingMessageWithSender:)]) {
        [self.delegate didReceiveTypingMessageWithSender:payload[sender]];
    }
}

- (void)handleSession:(NSDictionary *)payload
{
    self.lastReadTimestamp = [(NSNumber *)payload[@"last_read"] longValue];

    if (self.messages.count == 0) {
        [self loadMessageHistoryFrom:self.lastReadTimestamp];
    }
    [self checkUnread];
}


#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - WebSocket message received: %@", message);
    }

    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    if ([json[@"type"] isEqualToString:@"reply"]) {
        return [self handleReply:json];
    } else if ([json[@"type"] isEqualToString:@"message"]) {
        return [self handleMessage:json];
    } else if ([json[@"type"] isEqualToString:@"typing"]) {
        return [self handleTyping:json];
    } else if ([json[@"type"] isEqualToString:@"session"]) {
        return [self handleSession:json];
    } else {
        if (self.tracker.logLevel == GSLogLevelDebug) {
            NSLog(@"GSChat - WebSocket message type not handled: %@", json[@"type"]);
        }
        return;
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - WebSocket opened");
    }

    self.isConnected = YES;

    for (NSDictionary *msg in self.pendingMessages) {
        if (self.isConnected) {
            [self sendWithPayload:msg retryIfFailed:YES];
        }
    }

    [self.retryTimer invalidate];
    [self.delegate managerDidConnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - WebSocket error: %@", error);
    }

    if (error.code == 57) {
        [self.delegate managerDidDisconnect];
        [self closeWebSocket];

        self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(openWebSocket) userInfo:nil repeats:YES];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - WebSocket closed: %@", reason);
    }

    [self.delegate managerDidDisconnect];
    [self closeWebSocket];
}

@end
