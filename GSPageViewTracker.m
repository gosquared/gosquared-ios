//
//  GSPageViewTracker.m
//  GoSquared-iOS-Native
//
//  Created by Giles Williams on 15/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//

#import "GSPageViewTracker.h"
#import "GSTracker.h"
#import "GSDevice.h"

#import "GSRequest.h"

dispatch_queue_t GSPageViewTrackerQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.gosquared.pageviewtracker.queue", 0);
    });
    return queue;
}

const float kGSPageViewTrackerDefaultPingInterval = 20.0f;
static NSString * const kGSPageViewTrackerReturningDefaultsKey = @"com.gosquared.pageviewtracker.returning";

@interface GSPageViewTracker()

@property BOOL valid;

@property (retain) NSTimer *timer;

@property (retain) NSString *urlString;
@property (retain) NSString *title;

@property (retain) NSNumber *returning;

@property __weak UIViewController *currentlyTrackedViewController;

@end

@implementation GSPageViewTracker {
    long long pageIndex;
}

- (id)init {
    self = [super init];
    
    if(self) {
        pageIndex = 0;
        
        self.returning = [[NSUserDefaults standardUserDefaults] objectForKey:kGSPageViewTrackerReturningDefaultsKey];
        
        if(!self.returning) {
            self.returning = @0;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}

- (void)setPageIndex:(long long)index {
    pageIndex = index;
}

#pragma mark Lifecycle methods

- (void)appEnteredBackground {
    [self invalidate];
}
- (void)appEnteredForeground {
    if(self.title != nil && self.urlString != nil) {
        [self startWithURLString:self.urlString title:self.title];
    }
}

- (void)startWithURLString:(NSString *)urlString title:(NSString *)title {
    [self invalidate];
    
    self.title = title;
    self.urlString = urlString;
    
    if(self.title == nil) {
        self.title = @"";
    }
    
    self.valid = YES;
    
    [self startTimer];
    [self track];
}

- (void)startTimer {
    self.timer = [NSTimer timerWithTimeInterval:kGSPageViewTrackerDefaultPingInterval target:self selector:@selector(ping) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
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


#pragma mark Track methods (tracks initial page view)

- (NSString *)peopleURLStr {
    if([GSTracker sharedInstance].currentUserID == nil) {
        return @"";
    }
    else {
        return [NSString stringWithFormat:@"/people/%@", [GSTracker sharedInstance].currentUserID];
    }
}

- (void)track {
    if(!self.isValid) return;
    
    // use GCD barrier to force queuing of requests
    dispatch_barrier_async(GSPageViewTrackerQueue(), ^{
        GSDevice *device = [GSDevice currentDevice];
        NSMutableDictionary *body = @{
                               @"character_set": @"UTF-8",
                               @"color_depth": device.colorDepth,
                               @"java_enabled": @0,
                               @"language": device.isoLanguage,
                               @"screen_width": device.screenWidth,
                               @"screen_height": device.screenHeight,
                               @"device_pixel_ratio": device.screenPixelRatio,
                               @"url": self.urlString,
                               @"title": [NSString stringWithFormat:@"iOS: %@", self.title],
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
                               @"previous_page": [NSNumber numberWithLongLong:pageIndex],
                               @"timezone_offset": device.timezoneOffset,
                               @"visitor_id": device.udid,
                               @"tracker_version": @""
                               };

        if([GSTracker sharedInstance].identified) {
          body[@"person_id"] = [GSTracker sharedInstance].currentUserID;
        }

        NSString *path = [NSString stringWithFormat:@"/tracking/v1/pageview?%@", [GSTracker sharedInstance].trackingAPIParams];
        GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
        [req sendSync];
        
        @try {
            NSMutableString *str = [[NSMutableString alloc] initWithData:req.responseData encoding:NSUTF8StringEncoding];
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                          @"([^0-9]+)" options:0 error:nil];
            
            [regex replaceMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@""];
            
            [self setPageIndex:[str longLongValue]];
        }
        @catch(NSException *e) {
            
        }
    });
    
    if([self.returning intValue] == 0) {
        self.returning = @1;
        [[NSUserDefaults standardUserDefaults] setObject:self.returning forKey:kGSPageViewTrackerReturningDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark Pinger methods (keeps page view alive)

- (void)ping {
    if(!self.isValid) return;
    
    GSDevice *device = [GSDevice currentDevice];

    NSMutableDictionary *body = @{
                           @"current_page": [NSNumber numberWithLongLong:pageIndex],
                           @"engaged_time": @0,
                           @"viewport_width": device.screenWidth,
                           @"viewport_width": device.screenWidth,
                           @"viewport_height": device.screenHeight,
                           @"document_width": device.screenWidth,
                           @"document_height": device.screenHeight,
                           @"max_scroll_top": @0,
                           @"max_scroll_left": @0,
                           @"visitor_id": device.udid,
                           @"tracker_version": @""
                           };

     if([GSTracker sharedInstance].identified) {
       body[@"person_id"] = [GSTracker sharedInstance].currentUserID;
     }

    NSString *path = [NSString stringWithFormat:@"/tracking/v1/ping?%@", [GSTracker sharedInstance].trackingAPIParams];
    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [req send];
}

@end
