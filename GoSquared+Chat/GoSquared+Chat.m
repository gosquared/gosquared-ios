//
//  GoSquared+Chat.m
//  GoSquared
//
//  Created by Edward Wellbrook on 07/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GoSquared+Chat.h"

static GSChatViewController *sharedChatViewController = nil;

@implementation GoSquared (Chat)

+ (GSChatViewController *)sharedChatViewController
{
    if (sharedChatViewController == nil) {
        sharedChatViewController = [[GSChatViewController alloc] initWithTracker:[GoSquared sharedTracker]];
    }
    return sharedChatViewController;
}

@end
