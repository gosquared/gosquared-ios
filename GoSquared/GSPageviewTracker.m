//
//  GSPageviewTracker.m
//  GoSquared
//
//  Created by Giles Williams on 15/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GSPageviewTracker.h"
#import "GSTracker.h"
#import "GSDevice.h"
#import "GSRequest.h"


dispatch_queue_t GSPageviewTrackerQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.gosquared.pageviewtracker.queue", 0);
    });
    return queue;
}


const float kGSPageviewTrackerDefaultPingInterval = 20.0f;

static NSString * const kGSPageviewTrackerReturningDefaultsKey = @"com.gosquared.pageviewtracker.returning";
static NSString * const kGSPageviewLastTimestamp = @"com.gosquared.pageview.last";


@interface GSPageviewTracker()

@property (getter=isValid) BOOL valid;

@property (weak) GSTracker *tracker;

@property NSTimer *timer;

@property NSString *urlString;
@property NSString *title;

@property NSNumber *returning;
@property NSNumber *lastPageview;

@end

@implementation GSPageviewTracker {
    long long currentPageIndex;
}

- (id)initWithTracker:(GSTracker *)tracker
{
    self = [super init];

    if (self) {
        currentPageIndex = 0;

        self.tracker = tracker;
        self.returning = [[NSUserDefaults standardUserDefaults] objectForKey:kGSPageviewTrackerReturningDefaultsKey];
        self.lastPageview = [[NSUserDefaults standardUserDefaults] objectForKey:kGSPageviewLastTimestamp];

        if (!self.returning) {
            self.returning = @0;
        }

        if (!self.lastPageview) {
            self.lastPageview = @0;
        }

        if (!self.tracker.shouldTrackInBackground) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        }
    }

    return self;
}

- (void)setPageIndex:(long long)index
{
    currentPageIndex = index;
}

- (NSNumber *)pageIndex
{
    return [NSNumber numberWithLongLong:currentPageIndex];
}

#pragma mark Lifecycle methods

- (void)appEnteredBackground
{
    [self invalidate];
}

- (void)appEnteredForeground
{
    if (self.title != nil && self.urlString != nil) {
        [self startWithURLString:self.urlString title:self.title];
    }
}

- (void)startWithURLString:(NSString *)urlString title:(NSString *)title
{
    [self invalidate];

    self.title = title;
    self.urlString = urlString;

    self.valid = YES;

    [self startTimer];
    [self track];
}

- (void)startTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kGSPageviewTrackerDefaultPingInterval target:self selector:@selector(ping) userInfo:nil repeats:YES];
    });
}

- (void)invalidate
{
    self.valid = NO;

    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}


#pragma mark Track methods (tracks initial page view)

- (NSDictionary *)generateBodyForPing:(BOOL)isForPing
{
    GSDevice *device = [GSDevice currentDevice];

    NSMutableDictionary *page = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"url": self.urlString,
                                                                                @"title": [NSString stringWithFormat:@"%@: %@", device.os, self.title]
                                                                                }];

    if (isForPing) {
        page[@"index"] = [self pageIndex];
    } else {
        page[@"previous"] = [self pageIndex];
    }

    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"timestamp": [NSNumber numberWithLong:(long)[NSDate new].timeIntervalSince1970],
                                                                                @"visitor_id": self.tracker.visitorId,
                                                                                @"page": page,
                                                                                @"character_set": @"UTF-8",
                                                                                @"ip": @"detect",
                                                                                @"language": device.isoLanguage,
                                                                                @"user_agent": device.userAgent,
                                                                                @"returning": self.returning,
                                                                                @"engaged_time": @0,
                                                                                @"screen": @{
                                                                                        @"height": device.screenHeight,
                                                                                        @"width": device.screenWidth,
                                                                                        @"pixel_ratio": device.screenPixelRatio,
                                                                                        @"depth": device.colorDepth,
                                                                                        },
                                                                                @"document": @{
                                                                                        @"height": device.screenHeight,
                                                                                        @"width": device.screenWidth
                                                                                        },
                                                                                @"viewport": @{
                                                                                        @"height": device.screenHeight,
                                                                                        @"width": device.screenWidth
                                                                                        },
                                                                                @"scroll": @{
                                                                                        @"top": @0,
                                                                                        @"left": @0
                                                                                        },
                                                                                @"location": @{
                                                                                        @"timezone_offset": device.timezoneOffset
                                                                                        },
                                                                                @"tracker_version": self.tracker.trackerVersion
                                                                                }];

    if (!isForPing) {
        body[@"last_pageview"] = self.lastPageview;
    }

    if (self.tracker.personId != nil) {
        body[@"person_id"] = self.tracker.personId;
    }

    self.lastPageview = [NSNumber numberWithLong:(long)[NSDate new].timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastPageview forKey:kGSPageviewLastTimestamp];

    return [NSDictionary dictionaryWithDictionary:body];
}

- (void)track
{
    if (!self.isValid) return;

    // use GCD barrier to force queuing of requests
    dispatch_barrier_async(GSPageviewTrackerQueue(), ^{

        NSDictionary *body = [self generateBodyForPing:NO];
        NSString *path = [NSString stringWithFormat:@"/tracking/v1/pageview?%@", self.tracker.trackingAPIParams];

        GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];

        [self.tracker sendRequest:req completionHandler:^(NSDictionary *data, NSError *error) {
            if (data != nil) {
                NSNumber *index = data[@"index"];

                if (index != nil && ![index isKindOfClass:[NSNull class]]) {
                    [self setPageIndex:[index longLongValue]];
                }
            }
        }];
    });

    if ([self.returning intValue] == 0) {
        self.returning = @1;
        [[NSUserDefaults standardUserDefaults] setObject:self.returning forKey:kGSPageviewTrackerReturningDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark Pinger methods (keeps page view alive)

- (void)ping
{
    if (!self.isValid) return;

    NSDictionary *body = [self generateBodyForPing:YES];

    NSString *path = [NSString stringWithFormat:@"/tracking/v1/ping?%@", self.tracker.trackingAPIParams];
    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];

    [self.tracker sendRequest:req completionHandler:^(NSDictionary *data, NSError *error) {
        if (!error) return;

        if ([error.userInfo[@"code"] isEqualToString:@"visitor_not_online"]) {
            [self track];
        } else if ([error.userInfo[@"code"] isEqualToString:@"max_inactive_time"]) {
            [self track];
        } else if ([error.userInfo[@"code"] isEqualToString:@"max_session_time"]) {
            [self track];
        }
    }];
}

@end
