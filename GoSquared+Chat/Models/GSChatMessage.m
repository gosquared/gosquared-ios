//
//  GSChatMessage.m
//  GoSquared
//
//  Created by Edward Wellbrook on 22/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatMessage.h"
#import "NSString+Emojione.h"

@implementation GSChatMessage

+ (GSChatMessage *)messageWithContent:(NSString *)content sender:(GSChatSender)sender
{
    GSChatMessage *message = [[GSChatMessage alloc] init];
    message.content = [content stringWithResolvedShortnameCodes];
    message.sender = sender;

    return message;
}

+ (GSChatMessage *)messageWithDictionary:(NSDictionary *)dictionary
{
    GSChatMessage *message = [[GSChatMessage alloc] init];
    message.content = dictionary[@"content"];
    message.serverId = dictionary[@"id"];
    message.personId = dictionary[@"person_id"];

    NSNumber *ts = dictionary[@"timestamp"];
    message.timestamp = [ts integerValue];

    NSArray *entities = dictionary[@"entities"];
    for (NSDictionary *entity in entities.reverseObjectEnumerator) {
        NSArray *offsets = entity[@"offsets"];
        long len = [offsets.lastObject integerValue] - [offsets.firstObject integerValue];
        NSRange range = NSMakeRange([offsets.firstObject integerValue], len);

        if ([entity[@"type"] isEqualToString:@"emoji"]) {
            message.content = [message.content stringByReplacingCharactersInRange:range withString:entity[@"unicode"]];
        }
    }

    if ([dictionary[@"from"] isEqualToString:@"client"]) {
        message.sender = GSChatSenderClient;
    } else {
        message.sender = GSChatSenderAgent;
    }

    NSDictionary *dataDict = dictionary[@"data"];
    if (dataDict == nil) {
        return message;
    }

    NSDictionary *agentDict = dataDict[@"agent"];
    if (agentDict == nil) {
        return message;
    }

    if (agentDict[@"avatar"] != nil) {
        message.avatar = [[NSURL alloc] initWithString:agentDict[@"avatar"]];
    }

    return message;
}

+ (GSChatMessage *)messageWithData:(NSData *)data
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    return [GSChatMessage messageWithDictionary:json];
}

- (NSDictionary *)payloadValue
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                  @"id": [NSNumber numberWithInt:self.internalId],
                                                                                  @"type": @"message",
                                                                                  @"content": self.content,
                                                                                  @"data": @{
                                                                                          @"platform": @"ios"
                                                                                          }
                                                                                  }];

    if (self.personId != nil) {
        dict[@"person_id"] = self.personId;
    }

    if (self.agentId && self.agentFirstName && self.agentLastName && self.agentEmail) {
        dict[@"agent"] = @{
                           @"id": self.agentId,
                           @"first_name": self.agentFirstName,
                           @"last_name": self.agentLastName,
                           @"email": self.agentEmail
                           };
    }

    return dict;
}

- (NSString *)description
{
    NSString *msgId = self.serverId;
    if (msgId == nil) msgId = [NSString stringWithFormat:@"%d", self.internalId];

    return [NSString stringWithFormat:@"%@: %@", msgId, self.content];
}

@end
