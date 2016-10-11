//
//  UIViewController+Chat.m
//  GoSquared
//
//  Created by Edward Wellbrook on 08/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "UIViewController+Chat.h"
#import "GoSquared+Chat.h"

@implementation UIViewController (Chat)

- (void)gs_presentChatViewController
{
    [self gs_presentChatViewController:nil];
}

- (void)gs_presentChatViewController:(id)sender
{
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[GoSquared sharedChatViewController]];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navController animated:YES completion:nil];
    });
}

@end
