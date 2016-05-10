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

@end
