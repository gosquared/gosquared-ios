//
//  GoSquared.m
//  GoSquared
//
//  Created by Edward Wellbrook on 04/11/2015.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import "GoSquared.h"

@implementation GoSquared

+ (GSTracker *)sharedTracker
{
    static GSTracker *sharedTracker = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedTracker = [[GSTracker alloc] init];
    });
    return sharedTracker;
}

@end
