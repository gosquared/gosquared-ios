//
//  GSChatBarButtonItem.m
//  GoSquared
//
//  Created by Edward Wellbrook on 07/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatBarButtonItem.h"
#import "GSChatViewController.h"

@implementation GSChatBarButtonItem

static NSString * const buttonDetailText = @" (%@)";

+ (instancetype)buttonWithTitle:(NSString *)title target:(id)target
{
    GSChatBarButtonItem *button = [[GSChatBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:@selector(gs_presentChatViewController:)];
    button.buttonText = title;

    [[NSNotificationCenter defaultCenter] addObserver:button selector:@selector(updateButtonTextWithNotification:) name:GSUnreadMessageNotification object:nil];

    return button;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GSUnreadMessageNotification object:nil];
}

- (void)updateButtonTextWithNotification:(NSNotification *)notification
{
    NSNumber *count = notification.userInfo[GSUnreadMessageNotificationCount];
    self.title = [count isEqualToNumber:@0] ? self.buttonText : [self.buttonText stringByAppendingFormat:buttonDetailText, count];
}

@end
