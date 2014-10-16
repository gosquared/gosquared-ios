//
//  GSPageViewTracker.m
//  GoSquared-iOS-Native
//
//  Created by Giles Williams on 15/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//

const float kGSPageViewTrackerDefaultPingInterval = 25.0f;

#import "GSPageViewTracker.h"
#import "GSTracker.h"
#import "GSDevice.h"

#import "GSRequest.h"

@interface GSPageViewTracker()

@property BOOL valid;

@property (retain) NSTimer *timer;

@property (retain) NSString *urlString;
@property (retain) NSString *title;

@property __weak UIViewController *currentlyTrackedViewController;

@end

@implementation GSPageViewTracker {
    long pageIndex;
}

- (id)init {
    self = [super init];
    
    return self;
}

#pragma mark Lifecycle methods

- (void)startWithURLString:(NSString *)urlString title:(NSString *)title {
    self.title = title;
    self.urlString = urlString;
    
    if(self.title == nil) {
        self.title = @"";
    }
    
    //self.currentlyTrackedViewController = vc;
    
    self.valid = YES;
    
    self.timer = [NSTimer timerWithTimeInterval:kGSPageViewTrackerDefaultPingInterval target:self selector:@selector(ping) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    [self track];
}

- (void)invalidate {
    self.valid = NO;
    
    if(self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (BOOL)isValid {
    return self.valid;
}


#pragma mark Shared methods

- (NSNumber *)returning {
    return @1;
}


#pragma mark Track methods (tracks initial page view)

- (void)track {
    if(!self.isValid) return;
    
    GSDevice *device = [GSDevice currentDevice];
    
    NSDictionary *body = @{
                           @"character_set": @"UTF-8",
                           @"color_depth": device.colorDepth,
                           //@"flash_version": @"",
                           @"java_enabled": @0,
                           @"language": device.isoLanguage,
                           @"screen_width": device.screenWidth,
                           @"screen_height": device.screenHeight,
                           @"device_pixel_ratio": device.screenPixelRatio,
                           @"url": self.urlString,
                           @"title": self.title,
                           @"internal_referrer": @0,
                           @"referrer": @"-",
                           @"returning": self.returning,
                           @"last_pageview": @"",
                           @"viewport_width": device.screenWidth,
                           @"viewport_height": device.screenHeight,
                           @"document_width": device.screenWidth,
                           @"document_height": device.screenHeight,
                           @"scroll_top": @0,
                           @"scroll_left": @0,
                           @"previous_page": @"",
                           @"timezone_offset": device.timezoneOffset,
                           @"anonymous_id": device.udid,
                           @"tracker_version": @""
                           };
    
    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:[NSString stringWithFormat:@"/%@/v1/pageview", [GSTracker sharedInstance].siteToken] body:body];
    [req send];
}


#pragma mark Pinger methods (keeps page view alive)

- (void)ping {
    if(!self.isValid) return;
    
    GSDevice *device = [GSDevice currentDevice];
    
    NSDictionary *body = @{
                           @"current_page": [NSNumber numberWithLongLong:pageIndex],
                           @"engaged_time": @0,
                           @"viewport_width": device.screenWidth,
                           @"viewport_width": device.screenWidth,
                           @"viewport_height": device.screenHeight,
                           @"document_width": device.screenWidth,
                           @"document_height": device.screenHeight,
                           @"max_scroll_top": @0,
                           @"max_scroll_left": @0,
                           @"anonymous_id": device.udid,
                           @"tracker_version": @""
                           };
    
    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:[NSString stringWithFormat:@"/%@/v1/ping", [GSTracker sharedInstance].siteToken] body:body];
    [req send];
}

@end
