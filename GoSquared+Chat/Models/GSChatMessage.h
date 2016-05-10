//
//  GSChatMessage.h
//  GoSquared
//
//  Created by Edward Wellbrook on 22/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GSChatSender) {
    GSChatSenderClient,
    GSChatSenderAgent
};

@interface GSChatMessage : NSObject

@property int internalId;
@property (nullable) NSString *serverId;
@property (nullable) NSString *personId;
@property (nonnull) NSString *content;
@property (nullable) NSURL *avatar;
@property GSChatSender sender;
@property NSInteger timestamp;
@property BOOL pending;
@property BOOL failed;

@property (nullable) NSString *agentId;
@property (nullable) NSString *agentFirstName;
@property (nullable) NSString *agentLastName;
@property (nullable) NSString *agentEmail;

+ (nonnull instancetype)messageWithContent:(nonnull NSString *)content sender:(GSChatSender)sender;
+ (nonnull instancetype)messageWithDictionary:(nonnull NSDictionary *)dictionary;
+ (nonnull instancetype)messageWithData:(nonnull NSData *)data;

- (nonnull NSDictionary *)payloadValue;

@end
