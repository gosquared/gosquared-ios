//
//  GoSquared+Chat.h
//  GoSquared
//
//  Created by Edward Wellbrook on 07/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <GoSquared/GoSquared.h>
#import "GSTracker+Chat.h"
#import "GSChatViewController.h"

@interface GoSquared (Chat)

+ (nonnull GSChatViewController *)sharedChatViewController;

@end
