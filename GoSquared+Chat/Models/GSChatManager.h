//
//  GSChatManager.h
//  GoSquared
//
//  Created by Edward Wellbrook on 04/02/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>
#import "GSChatConnectionStatus.h"
#import "GSChatMessage.h"
#import "GSTracker+Chat.h"

@protocol GSChatManagerDelegate <NSObject>

@required
- (void)didAddMessageAtIndex:(NSUInteger)index;
- (void)didUpdateMessageAtIndex:(NSUInteger)index;
- (void)didRemoveMessageAtIndex:(NSUInteger)index;
- (void)didAddMessagesInRange:(NSRange)range;
- (void)didReachEndOfConversation;

@optional
- (void)managerDidConnect;
- (void)managerDidFailToConnect;
- (void)managerDidDisconnect;
- (void)didReceiveTypingMessageWithSender:(nonnull NSDictionary *)sender;
- (void)didUpdateUnreadMessageCount:(NSUInteger)count;

@end


@interface GSChatManager : NSObject <SRWebSocketDelegate>

@property (weak, nullable) id<GSChatManagerDelegate> delegate;

- (void)setConfigWithTracker:(nonnull GSTracker *)tracker;
- (void)loadMessageHistory;
- (void)openWebSocket;
- (void)closeWebSocket;

- (void)sendMessage:(nonnull GSChatMessage *)message;
- (void)deleteMessage:(nonnull GSChatMessage *)message;
- (nullable GSChatMessage *)messageAtIndex:(NSUInteger)index;

- (void)markRead;
- (void)sendTypingNotification;

@end
