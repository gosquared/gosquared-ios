//
//  ViewController.m
//  Chat
//
//  Created by Edward Wellbrook on 26/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "ViewController.h"
#import <GoSquared/GoSquared.h>
#import <GoSquared/GoSquared+Chat.h>
#import <GoSquared/UIViewController+Chat.h>

@implementation ViewController

- (IBAction)presentChat:(id)sender
{
    [self gs_presentChatViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUnreadCount:)
                                                 name:GSUnreadMessageNotification
                                               object:nil];
}

- (void)updateUnreadCount:(NSNotification *)notification
{
    NSNumber *count = notification.userInfo[GSUnreadMessageNotificationCount];

    if ([count isEqualToNumber:@0]) {
        [self.button setTitle:@"Chat with GoSquared" forState:UIControlStateNormal];
    } else {
        [self.button setTitle:[NSString stringWithFormat:@"Chat with GoSquared (%@)", count] forState:UIControlStateNormal];
    }
}

@end
