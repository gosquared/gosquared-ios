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
    long long currentPageIndex;
}

- (id)init {
    self = [super init];
    
    if(self) {
        currentPageIndex = 0;
        
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
    currentPageIndex = index;
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

- (NSDictionary *)generateBodyForPing:(BOOL)isForPing {
    GSDevice *device = [GSDevice currentDevice];
    
    NSMutableDictionary *page = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"url": self.urlString,
                                                                                @"title": [NSString stringWithFormat:@"iOS: %@", self.title]
                                                                                }];
    
    if(isForPing) {
        page[@"index"] = [NSNumber numberWithLongLong:currentPageIndex];
    }
    else {
        page[@"previous"] = [NSNumber numberWithLongLong:currentPageIndex];
    }
    
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"timestamp": [NSNumber numberWithLong:(long)[NSDate new].timeIntervalSince1970],
                                                                                @"visitor_id": [GSTracker sharedInstance].anonID,
                                                                                @"page": page,
                                                                                @"character_set": @"UTF-8",
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
                                                                                @"tracker_version": [GSTracker sharedInstance].trackerVersion
                                                                                }];
    
    if([GSTracker sharedInstance].currentPersonID != nil) {
        body[@"person_id"] = [GSTracker sharedInstance].currentPersonID;
    }
    
    return [NSDictionary dictionaryWithDictionary:body];
}

- (void)track {
    if(!self.isValid) return;
    
    // use GCD barrier to force queuing of requests
    dispatch_barrier_async(GSPageViewTrackerQueue(), ^{
        
        NSDictionary *body = [self generateBodyForPing:NO];

        NSString *path = [NSString stringWithFormat:@"/tracking/v1/pageview?%@", [GSTracker sharedInstance].trackingAPIParams];
        GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
        [req sendSync];
        
        @try {
            NSError *localError;
            NSDictionary *parsedResponse = [NSJSONSerialization JSONObjectWithData:req.responseData options:0 error:&localError];
            
            if(parsedResponse != nil) {
                NSNumber *index = parsedResponse[@"index"];
                
                if(index != nil && ![index isKindOfClass:[NSNull class]]) {
                    [self setPageIndex:[index longLongValue]];
                }
            }
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

    NSDictionary *body = [self generateBodyForPing:YES];
    
    NSString *path = [NSString stringWithFormat:@"/tracking/v1/ping?%@", [GSTracker sharedInstance].trackingAPIParams];
    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [req send];
}

@end
