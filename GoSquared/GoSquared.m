//
//  GoSquared.m
//  GoSquared
//
//  Created by Edward Wellbrook on 04/11/2015.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import "GoSquared.h"

@implementation GoSquared

static GSTracker *sharedTracker = nil;

+ (GSTracker *)sharedInstance {
    if(sharedTracker == nil) {
        sharedTracker = [[GSTracker alloc] init];
    }

    return sharedTracker;
}

@end
