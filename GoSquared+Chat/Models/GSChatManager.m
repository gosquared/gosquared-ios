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

NSString * const kGSChatAnonymousIdURL           = @"/chat/v1/clientAuth?site_token=%@&client_id=%@";
NSString * const kGSChatAnonymousClaimURL        = @"/chat/v1/clientAuth?site_token=%@&person_id=%@&auth=%@";
NSString * const kGSChatWebsocketURL             = @"/chat/v1/stream?%@";
NSString * const kGSChatMessagesURL              = @"https://api.gosquared.com/chat/v1/chats/%@/messages?%@&limit=%d";
NSString * const kGSChatMessagesToTimestampURL   = @"https://api.gosquared.com/chat/v1/chats/%@/messages?%@&limit=%d&to=%lu";
NSString * const kGSChatMessagesFromTimestampURL = @"https://api.gosquared.com/chat/v1/chats/%@/messages?%@&limit=%d&from=%lu";

const NSComparator kGSChatTimestampComparator = ^NSComparisonResult(GSChatMessage *obj1, GSChatMessage *obj2) {
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


@interface GSTracker ()

@property (weak) id<GSTrackerDelegate> delegate;

@end


@interface GSChatManager () <GSTrackerDelegate>

@property dispatch_queue_t queue;

@property (nonnull) GSTracker *tracker;
@property (nullable) NSString *configPerson;
@property (nullable) NSString *configSignature;

@property (nullable) SRWebSocket *webSocket;

@property (nonnull) NSMutableArray<GSChatMessage *> *messages;
@property (nonnull) NSMutableArray<NSDictionary *> *pendingMessages;

@property (nullable) NSTimer *retryTimer;

@property BOOL isConnected;
@property BOOL isLoadingMessages;
@property BOOL hasReachedEnd;
@property NSUInteger nextMessageId;
@property NSUInteger lastReadTimestamp;
@property (nonatomic) NSUInteger numberOfUnreadMessages;

// rate limitting
@property (nonnull) NSDate *lastSentTypingNotifTimestamp;

- (BOOL)needsAnonymousId;
- (NSString *)APIAuthParams;

@end

@implementation GSChatManager

- (instancetype)init
{
    if (self = [super init]) {
        self.messages = [[NSMutableArray alloc] init];
        self.pendingMessages = [[NSMutableArray alloc] init];
        self.nextMessageId = 200;
        self.queue = dispatch_queue_create("com.gosquared.chat.queue", DISPATCH_QUEUE_SERIAL);
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

- (void)setConfigWithTracker:(GSTracker *)tracker
{
    self.tracker = tracker;
    self.configPerson = tracker.personId;

    // only set signature if we have a personId
    if (tracker.personId) {
        self.configSignature = tracker.signature;
    }

    self.tracker.delegate = self;
}

- (BOOL)needsAnonymousId
{
    if (self.configPerson == nil && self.configSignature == nil) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)userId
{
    if (self.configPerson != nil) {
        return self.configPerson;
    } else {
        return self.tracker.visitorId;
    }
}

- (NSString *)APIAuthParams
{
    return [NSString stringWithFormat:@"site_token=%@&person_id=%@&auth=%@", self.tracker.token, self.userId, self.configSignature];
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
        NSString *visitorId = self.tracker.visitorId;

        [self registerAnonymousIdWithVisitorId:visitorId completionHandler:^(NSString *signature, NSError *error) {
            if (error != nil) {
                return;
            }

            self.configPerson = visitorId;
            self.configSignature = signature;

            // open websocket with new config
            [self openWebSocket];
        }];
        return;
    }

    NSString *path = [NSString stringWithFormat:kGSChatWebsocketURL, self.APIAuthParams];
    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodGET path:path body:nil];

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

        NSString *URLString = data[@"url"];
        if (URLString == nil) {
            return [self.delegate managerDidFailToConnect];
        }

        NSURL *webSocketURL = [NSURL URLWithString:data[@"url"]];
        if (webSocketURL == nil) {
            return [self.delegate managerDidFailToConnect];
        }

        [self openWebSocketWithURL:webSocketURL];
        [self loadMessageHistory];
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
    NSString *path = [NSString stringWithFormat:kGSChatAnonymousIdURL, self.tracker.token, visitorId];
    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodGET path:path body:nil];

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
    NSString *path = [NSString stringWithFormat:kGSChatAnonymousClaimURL, self.tracker.token, personId, signature];
    NSDictionary *body = @{
                           @"client_id": self.userId,
                           @"token": self.configSignature
                           };

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];

    [req sendWithCompletionHandler:^(NSDictionary *data, NSError *error) {
        completionHandler(error);
    }];
}

- (void)loadMessageHistory
{
    if (self.isLoadingMessages || self.needsAnonymousId) {
        return;
    }

    NSString *URLString;

    if (self.messages.count == 0) {
        URLString = [NSString stringWithFormat:kGSChatMessagesURL, self.userId, self.APIAuthParams, kGSChatMessageLimit];
    } else {
        NSUInteger timestamp = [(GSChatMessage *)self.messages.firstObject timestamp];
        URLString = [NSString stringWithFormat:kGSChatMessagesToTimestampURL, self.userId, self.APIAuthParams, kGSChatMessageLimit, (long)timestamp];
    }

    NSURL *URL = [NSURL URLWithString:URLString];
    [self loadMessageHistoryWithURL:URL allowsReachingEnd:YES];
}

- (void)loadMessageHistoryFrom:(NSUInteger)from
{
    NSInteger timestamp = [(GSChatMessage *)self.messages.firstObject timestamp];
    NSString *URLString = [NSString stringWithFormat:kGSChatMessagesFromTimestampURL, self.configPerson, self.APIAuthParams, kGSChatMessageLimit, (long)timestamp];
    NSURL *URL = [NSURL URLWithString:URLString];

    [self loadMessageHistoryWithURL:URL allowsReachingEnd:NO];
}

- (void)loadMessageHistoryWithURL:(NSURL *)URL allowsReachingEnd:(BOOL)allowsReachingEnd
{
    NSLog(@"URL: %@", URL);

    self.isLoadingMessages = YES;

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodGET URL:URL body:nil];

    [req sendWithCompletionHandler:^(NSDictionary *data, NSError *error) {
        if (error) {
            if (self.tracker.logLevel == GSLogLevelQuiet) {
                NSLog(@"GSChat - Error getting messages: %@", error);
            }
            self.isLoadingMessages = NO;
            return;
        }

        if (!data) {
            if (self.tracker.logLevel == GSLogLevelQuiet) {
                NSLog(@"GSChat - Error getting messages: Empty repsonse");
            }
            self.isLoadingMessages = NO;
            return;
        }

        NSArray *messageList = data[@"list"];
        if (messageList == nil) {
            if (self.tracker.logLevel == GSLogLevelQuiet) {
                NSLog(@"GSChat - Error getting messages: Incorrect response format");
            }
            self.isLoadingMessages = NO;
            return;
        }

        NSMutableArray<GSChatMessage *> *newMessages = [[NSMutableArray alloc] initWithCapacity:messageList.count];

        for (NSDictionary *item in messageList) {
            GSChatMessage *msg = [GSChatMessage messageWithDictionary:item];

            if ([self messageExists:msg] == NO) {
                [newMessages addObject:msg];
            }
        }

        dispatch_barrier_async(self.queue, ^{
            [self.messages addObjectsFromArray:newMessages];
            [self.messages sortUsingComparator:kGSChatTimestampComparator];
            [self.delegate didAddMessagesInRange:NSMakeRange(NSNotFound, newMessages.count)];

            if (newMessages.count == 0 && allowsReachingEnd == YES) {
                [self.delegate didReachEndOfConversation];
            }

            self.isLoadingMessages = NO;
        });
    }];
}

- (GSChatMessage *)messageAtIndex:(NSUInteger)index
{
    return self.messages[index];
}

- (void)sendMessage:(GSChatMessage *)message
{
    dispatch_barrier_async(self.queue, ^{
        BOOL messageExists = ([self.messages indexOfObject:message] != NSNotFound);

        if (self.isConnected == NO) {
            message.failed = YES;
        }

        if (messageExists == NO) {
            message.internalId = self.nextMessageId++;
            message.pending = YES;

            [self.messages addObject:message];
            [self.delegate didAddMessageAtIndex:self.messages.count-1];
        }

        [self sendWithPayload:[message payloadValue] retryIfFailed:NO];
    });
}

- (void)deleteMessage:(GSChatMessage *)message
{
    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - Deleting message: %@", message);
    }

    dispatch_barrier_async(self.queue, ^{
        NSUInteger messageIndex = [self.messages indexOfObject:message];

        [self.delegate didRemoveMessageAtIndex:messageIndex];
        [self.messages removeObject:message];
    });
}

- (void)markRead
{
    dispatch_barrier_async(self.queue, ^{
        self.numberOfUnreadMessages = 0;
        GSChatMessage *latestMessage = self.messages.lastObject;
        [self markReadWithTimestamp:latestMessage.timestamp];
    });
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

- (void)markReadWithTimestamp:(NSUInteger)timestamp
{
    if (timestamp == 0) {
        return;
    }

    self.lastReadTimestamp = timestamp;
    [self updateUnreadCount];

    NSDictionary *payload = @{
                              @"type": @"read",
                              @"timestamp": @(timestamp)
                              };

    [self sendWithPayload:payload retryIfFailed:YES];
}

- (void)sendWithPayload:(NSDictionary *)payload retryIfFailed:(BOOL)shouldRetry
{
    [self.pendingMessages removeObject:payload];

    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - Attempting to send: %@", payload);
    }

    if (self.isConnected) {
#warning not handling error here
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

- (void)updateUnreadCount
{
    if (self.lastReadTimestamp == 0 || self.isLoadingMessages) {
        return;
    }

    dispatch_async(self.queue, ^{
        NSUInteger unread = 0;

        for (GSChatMessage *message in self.messages) {
            if (message.timestamp > self.lastReadTimestamp && message.sender != GSChatSenderClient) {
                unread += 1;
            }
        }

        self.numberOfUnreadMessages = unread;
    });
}


#pragma mark WebSocket message handlers

- (void)handleReply:(NSDictionary *)payload
{
    NSNumber *messageId = payload[@"reply_to"];
    BOOL successful = [payload[@"success"] boolValue];

    dispatch_barrier_async(self.queue, ^{
        NSUInteger index = 0;
        BOOL messageExists = NO;

        for (GSChatMessage *msg in self.messages) {
            if (msg.internalId == messageId.longValue) {
                messageExists = YES;
                break;
            }
            index += 1;
        }

        if (messageExists) {
            GSChatMessage *message = self.messages[index];
            message.serverId = payload[@"id"];
            message.timestamp = ((NSNumber *)payload[@"timestamp"]).unsignedIntegerValue;
            message.pending = NO;
            message.failed = !successful;

            [self.delegate didUpdateMessageAtIndex:index];
        }
    });
}

- (void)handleMessage:(NSDictionary *)payload
{
    GSChatMessage *message = [GSChatMessage messageWithDictionary:payload];
    message.pending = NO;

    dispatch_barrier_async(self.queue, ^{
        NSUInteger index = 0;
        BOOL messageExists = NO;

        for (GSChatMessage *msg in self.messages) {
            messageExists = [msg.serverId isEqualToString:message.serverId];

            if (messageExists) {
                break;
            }
            index += 1;
        }

        if (messageExists) {
            self.messages[index] = message;
            [self.delegate didUpdateMessageAtIndex:index];
        } else {
            [self.messages addObject:message];
            [self.delegate didAddMessageAtIndex:self.messages.count-1];

            [self markDelivered:message];
            [self updateUnreadCount];
        }
    });
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
    self.lastReadTimestamp = ((NSNumber *)payload[@"last_read"]).longValue;

    [self loadMessageHistoryFrom:self.lastReadTimestamp];
    [self updateUnreadCount];
}


#pragma mark SRWebSocketDelegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - WebSocket message received: %@", message);
    }

    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];

#warning not handling error here
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    if ([json[@"type"] isEqualToString:@"reply"]) {
        return [self handleReply:json];
    } else if ([json[@"type"] isEqualToString:@"message"]) {
        return [self handleMessage:json];
    } else if ([json[@"type"] isEqualToString:@"typing"]) {
        return [self handleTyping:json];
    } else if ([json[@"type"] isEqualToString:@"session"]) {
        return [self handleSession:json];
    }

    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - WebSocket message type not handled: %@", json[@"type"]);
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    if (self.tracker.logLevel == GSLogLevelDebug) {
        NSLog(@"GSChat - WebSocket opened");
    }

    self.isConnected = YES;

    dispatch_barrier_async(self.queue, ^{
        for (NSDictionary *msg in self.pendingMessages) {
            if (self.isConnected) {
                [self sendWithPayload:msg retryIfFailed:YES];
            }
        }

        [self.retryTimer invalidate];
        [self.delegate managerDidConnect];
    });
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
