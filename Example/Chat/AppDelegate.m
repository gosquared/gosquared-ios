//
//  AppDelegate.m
//  Chat
//
//  Created by Edward Wellbrook on 21/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <GoSquared/GoSquared.h>
#import <GoSquared/GoSquared+Chat.h>

#import "AppDelegate.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // replace these with your own details from https://www.gosquared.com/setup/general
    [GoSquared sharedTracker].token  = @"GSN-XXXXXX-X";
    [GoSquared sharedTracker].key    = @"XXXXXXXXXXXXXXXX";
    [GoSquared sharedTracker].secret = @"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

    [GoSquared sharedChatViewController].title = @"Chatting with Example App";

    [[GoSquared sharedTracker] identifyWithProperties:@{
                                                        @"id": @"2388975",
                                                        @"name": @"Example User",
                                                        @"email": @"email@example.com"
                                                        }];

    return YES;
}

@end
