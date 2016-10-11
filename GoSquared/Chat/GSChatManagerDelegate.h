//
//  GSChatManagerDelegate.h
//  GoSquared
//
//  Created by Edward Wellbrook on 18/08/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GSChatManagerDelegate <NSObject>

- (void)didTapMessageLinkWithURL:(nonnull NSURL *)URL;
- (void)didUpdateUnreadMessageCount:(NSUInteger)count;
- (void)webviewDidLoad;
- (void)chatDidLoad;
- (void)didReceiveNewMessage:(nonnull NSDictionary *)message;
- (void)didReceiveConfig:(nonnull NSDictionary *)config;

@end
