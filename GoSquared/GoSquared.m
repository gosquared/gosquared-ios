//
//  GoSquared.m
//  GoSquared
//
//  Created by Edward Wellbrook on 04/11/2015.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import "GoSquared.h"

@implementation GoSquared

static GSTracker *tracker = nil;

+ (GSTracker *)sharedTracker {
    if(tracker == nil) {
        tracker = [[GSTracker alloc] init];
    }

    return tracker;
}

@end
