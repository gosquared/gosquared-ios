//
//  GoSquared+Chat.h
//  GoSquared
//
//  Created by Edward Wellbrook on 07/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <GoSquared/GoSquared.h>
#import "GSTracker.h"
#import "GSChatViewController.h"

@interface GoSquared (Chat)

/**
 Singleton shared instance of GSChatViewController for interacting with GoSquared Chat
 
 @return The shared instance of GSChatViewController
 */
+ (nonnull GSChatViewController *)sharedChatViewController;

@end
