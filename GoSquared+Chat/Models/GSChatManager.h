//
//  GSChatManager.h
//  GoSquared
//
//  Created by Edward Wellbrook on 04/02/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SRWebSocket.h>
#import "GSChatMessage.h"
#import "GSTracker+Chat.h"

@class GSChatManager;

@protocol GSChatManagerDelegate <NSObject>

@required
- (void)managerDidConnect;
- (void)managerDidFailToConnect;
- (void)managerDidDisconnect;
- (void)didAddMessage:(nonnull GSChatMessage *)message;
- (void)didAddMessagesInRange:(NSRange)range reachedEnd:(BOOL)reachedEnd;
- (void)didUpdateMessageAtIndex:(NSInteger)index;

@optional
- (void)didBeginLoadingHistory;
- (void)didReceiveTypingMessageWithSender:(nonnull NSDictionary *)sender;
- (void)didUpdateUnreadMessageCount:(NSUInteger)count;

// TODO: remove this
- (void)didUpdateMessageList;

@end

@interface GSChatManager : NSObject <SRWebSocketDelegate>

@property (weak, nullable) id<GSChatManagerDelegate> delegate;
@property (readonly, nonnull) NSMutableArray *messages;

- (void)setConfigWithTracker:(nonnull GSTracker *)tracker;
- (void)loadMessageHistory;
- (void)loadMessageHistoryWithURL:(nonnull NSURL *)URL;
- (void)openWebSocket;
- (void)closeWebSocket;
- (void)sendMessage:(nonnull GSChatMessage *)message;
- (void)deleteMessage:(nonnull GSChatMessage *)message;
- (void)markReadWithTimestamp:(nonnull NSNumber *)timestamp;
- (void)sendTypingNotification;
- (BOOL)isOpen;

@end
