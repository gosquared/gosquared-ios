//
//  GSChatManager.h
//  GoSquared
//
//  Created by Edward Wellbrook on 04/02/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "GSTracker.h"
#import "GSChatManagerDelegate.h"

@interface GSChatManager : WKUserContentController <WKScriptMessageHandler, WKNavigationDelegate>

@property (nullable, weak) id<GSChatManagerDelegate> managerDelegate;
@property (nonatomic) NSUInteger numberOfUnreadMessages;

+ (nonnull NSString *)configForTracker:(nonnull GSTracker *)tracker;

- (nonnull instancetype)initWithTracker:(nonnull GSTracker *)tracker;

@end
