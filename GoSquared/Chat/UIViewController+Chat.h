//
//  UIViewController+Chat.h
//  GoSquared
//
//  Created by Edward Wellbrook on 08/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Chat)

/**
 Category method for presenting the GSChatViewController from a given UIViewController
 */
- (void)gs_presentChatViewController;

/**
 Category method for presenting the GSChatViewController from a given UIViewController

 @param sender The sender
 */
- (void)gs_presentChatViewController:(nullable id)sender;

@end
