//
//  GoSquared+Chat.m
//  GoSquared
//
//  Created by Edward Wellbrook on 07/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GoSquared+Chat.h"

@implementation GoSquared (Chat)

+ (GSChatViewController *)sharedChatViewController
{
    static GSChatViewController *sharedChatViewController = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        [[GoSquared sharedTracker] performSelector:@selector(verifyCredsAreSet)];
        sharedChatViewController = [[GSChatViewController alloc] initWithTracker:[GoSquared sharedTracker]];
    });
    return sharedChatViewController;
}

@end
