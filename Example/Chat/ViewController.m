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

- (IBAction)identify:(id)sender {
    
    [[GoSquared sharedTracker] identifyWithProperties:@{
                                                        @"id": @"12345",
                                                        @"name": @"Example User",
                                                        @"email": @"email@example.com"
                                                        }];
}

- (IBAction)unidentify:(id)sender {
    [[GoSquared sharedTracker] unidentify];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Chat Example";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUnreadCount:)
                                                 name:GSUnreadMessageNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNewMesage:)
                                                 name:GSMessageNotification
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

- (void)handleNewMesage:(NSNotification *)notification
{
    NSLog(@"Received GoSquared Chat message: %@", notification.userInfo);
}

@end
