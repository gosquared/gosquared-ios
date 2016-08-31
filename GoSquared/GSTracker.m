//
//  GSTracker.m
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSTracker.h"
#import "GSTrackerDelegate.h"
#import "GSDevice.h"
#import "GSRequest.h"
#import "GSTrackerEvent.h"
#import "GSTransaction.h"
#import "GSTransactionItem.h"
#import "GSTrackerEvent.h"
#import "GSPageview.h"
#import "GSConfig.h"


// tracker default config
static NSString * const kGSTrackerVersion        = @"ios-0.7.4";
static NSString * const kGSTrackerDefaultTitle   = @"Unknown";
static NSString * const kGSTrackerDefaultPath    = @"";
static const float kGSTrackerDefaultPingInterval = 20.0f;

// api endpoint paths
static NSString * const kGSTrackerPageviewPath    = @"/tracking/v1/pageview?%@";
static NSString * const kGSTrackerPingPath        = @"/tracking/v1/ping?%@";
static NSString * const kGSTrackerEventPath       = @"/tracking/v1/event?%@";
static NSString * const kGSTrackerTransactionPath = @"/tracking/v1/transaction?%@";
static NSString * const kGSTrackerIdentifyPath    = @"/tracking/v1/identify?%@";


@interface GSTracker()

@property (weak) id<GSTrackerDelegate> delegate;
@property GSConfig *config;

@property (getter=isIdentified) BOOL identified;
@property (getter=isPageviewPingTimerValid) BOOL pageviewPingTimerValid;

@property GSPageview *pageview;
@property NSTimer *pageviewPingTimer;

@property long engagementOffset;
@property dispatch_queue_t queue;

@end

@implementation GSTracker

#pragma mark Public methods

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.queue = dispatch_queue_create("com.gosquared.pageview.queue", DISPATCH_QUEUE_SERIAL);
        self.logLevel = GSLogLevelQuiet;

        [self addNotificationObservers];
    }

    return self;
}

- (instancetype)initWithToken:(NSString *)token key:(NSString *)key
{
    self = [self init];

    if (self) {
        self.token = token;
        self.key = key;
    }

    return self;
}

- (void)setToken:(NSString *)token
{
    _token = token;

    self.config = [[GSConfig alloc] initWithToken:self.token];

    if (self.personId != nil) {
        self.identified = YES;
    }
}

- (void)setShouldTrackInBackground:(BOOL)shouldTrackInBackground
{
    _shouldTrackInBackground = shouldTrackInBackground;

    if (shouldTrackInBackground == YES) {
        [self removeNotificationObservers];
    } else {
        [self addNotificationObservers];
    }
}

- (NSString *)visitorId
{
    return self.config.visitorId;
}

- (NSString *)personId
{
    return self.config.personId;
}

#pragma mark Private - UIApplication Notification methods

- (void)addNotificationObservers
{
    // ensure there are no notification observers already set
    [self removeNotificationObservers];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)appEnteredBackground
{
    [self invalidatePingTimer];
}

- (void)appEnteredForeground
{
    if (self.pageview != nil) {
        [self startPingTimer];
        [self trackPageview:self.pageview];
    }
}


#pragma mark Public - Pageview tracking

- (void)trackScreenWithTitle:(NSString *)title
{
    [self trackScreenWithTitle:title path:nil];
}

- (void)trackScreenWithTitle:(NSString *)title path:(NSString *)path
{
    [self verifyCredsAreSet];
    [self invalidatePingTimer];

    // set default title if missing or empty
    if ([title isEqual: @""]) {
        title = kGSTrackerDefaultTitle;
    }

    // set default path if missing or empty
    if ([path isEqual:@""]) {
        path = [title isEqual:kGSTrackerDefaultTitle] ? kGSTrackerDefaultPath : title;
    }

    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];

    NSString *os = [GSDevice currentDevice].os;
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *URLString = [NSString stringWithFormat:@"%@://%@/%@", os, bundleId, path];
    NSNumber *pageIndex = self.pageview.index ?: @0;

    self.pageview = [GSPageview pageviewWithTitle:title URLString:URLString index:pageIndex];

    [self startPingTimer];
    [self trackPageview:self.pageview];
}


#pragma mark Private - Pageview tracking

- (void)startPingTimer
{
    self.pageviewPingTimerValid = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        self.engagementOffset = [NSDate new].timeIntervalSince1970;
        self.pageviewPingTimer = [NSTimer scheduledTimerWithTimeInterval:kGSTrackerDefaultPingInterval target:self selector:@selector(ping) userInfo:nil repeats:YES];
    });
}

- (void)invalidatePingTimer
{
    self.pageviewPingTimerValid = NO;

    if (self.pageviewPingTimer) {
        [self.pageviewPingTimer invalidate];
        self.pageviewPingTimer = nil;
        self.engagementOffset = [NSDate new].timeIntervalSince1970;
    }
}

- (void)trackPageview:(GSPageview *)pageview
{
    if (self.isPageviewPingTimerValid == NO) {
        return;
    }

    // use GCD barrier to force queuing of requests
    dispatch_barrier_async(self.queue, ^{
        NSString *path = [NSString stringWithFormat:kGSTrackerPageviewPath, self.trackingAPIParams];

        NSDictionary *body = [pageview serializeWithDevice:[GSDevice currentDevice]
                                                 visitorId:self.config.visitorId
                                                  personId:self.config.personId
                                              lastPageview:self.config.lastPageviewTimestamp
                                                 returning:self.config.isReturning
                                            trackerVersion:kGSTrackerVersion];

        GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];

        __weak typeof(self) weakself = self;
        [self sendRequest:req completionHandler:^(NSDictionary *data, NSError *error) {
            if (data == nil) {
                return;
            }

            NSNumber *index = data[@"index"];

            if (index != nil && [index isKindOfClass:NSNull.class] == NO) {
                weakself.pageview.index = index;

                // call identify with cached properties after initial pageview
                if ([index isEqualToNumber:@0] && weakself.personId != nil) {
                    NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithDictionary:@{ @"id": weakself.personId }];

                    if (weakself.config.personName != nil) {
                        props[@"name"] = weakself.config.personName;
                    }

                    if (weakself.config.personEmail != nil) {
                        props[@"email"] = weakself.config.personEmail;
                    }

                    [weakself identifyWithProperties:props];
                }
            }
        }];
    });

    self.config.returning = YES;
}

- (void)ping
{
    if (self.isPageviewPingTimerValid == NO) return;

    NSString *path = [NSString stringWithFormat:kGSTrackerPingPath, self.trackingAPIParams];

    NSDictionary *body = [self.pageview serializeForPingWithDevice:[GSDevice currentDevice]
                                                         visitorId:self.visitorId
                                                          personId:self.personId
                                                       engagedTime:@(((long)[NSDate new].timeIntervalSince1970 - self.engagementOffset) * 1000)
                                                    trackerVersion:kGSTrackerVersion];

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];

    __weak typeof(self) weakself = self;
    [self sendRequest:req completionHandler:^(NSDictionary *data, NSError *error) {
        if (!error) return;

        NSString *errorCode = [NSString stringWithFormat:@"%@", error.userInfo[@"code"]];

        if ([errorCode isEqualToString:@"visitor_not_online"]) {
            [weakself trackPageview:weakself.pageview];
        } else if ([errorCode isEqualToString:@"max_inactive_time"]) {
            [weakself trackPageview:weakself.pageview];
        } else if ([errorCode isEqualToString:@"max_session_time"]) {
            [weakself trackPageview:weakself.pageview];
        }
    }];

    self.engagementOffset = [NSDate new].timeIntervalSince1970;
    self.config.lastPageviewTimestamp = [NSNumber numberWithLong:(long)[NSDate new].timeIntervalSince1970];
}


#pragma mark Public - Event tracking

- (void)trackEventWithName:(NSString *)name
{
    [self trackEventWithName:name properties:nil];
}

- (void)trackEventWithName:(NSString *)name properties:(GSPropertyDictionary *)properties
{
    [self verifyCredsAreSet];

    NSString *path = [NSString stringWithFormat:kGSTrackerEventPath, self.trackingAPIParams];

    GSTrackerEvent *event = [GSTrackerEvent eventWithName:name properties:properties];

    NSDictionary *body = [event serializeWithVisitorId:self.visitorId
                                              personId:self.personId
                                             pageIndex:self.pageview.index];

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:req];
}


#pragma mark Public - Ecommerce tracking

- (void)trackTransactionWithId:(NSString *)transactionId items:(NSArray *)items
{
    [self trackTransactionWithId:transactionId items:items properties:nil];
}

- (void)trackTransactionWithId:(NSString *)transactionId items:(NSArray *)items properties:(GSPropertyDictionary *)properties
{
    GSTransaction *transaction = [GSTransaction transactionWithId:transactionId properties:properties];
    [transaction addItems:items];

    [self trackTransaction:transaction];
}

- (void)trackTransaction:(GSTransaction *)transaction
{
    [self verifyCredsAreSet];

    NSString *path = [NSString stringWithFormat:kGSTrackerTransactionPath, self.trackingAPIParams];

    NSDictionary *body = [transaction serializeWithVisitorId:self.config.visitorId
                                                    personId:self.config.personId
                                                   pageIndex:self.pageview.index
                                    lastTransactionTimestamp:self.config.lastTransactionTimestamp];

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:req];

    self.config.lastTransactionTimestamp = [NSNumber numberWithLong:(long)[NSDate new].timeIntervalSince1970];
}


#pragma mark Public - People Analytics

- (void)identifyWithProperties:(GSPropertyDictionary *)properties
{
    [self verifyCredsAreSet];

    NSString *personId = properties[@"id"] ?: properties[@"person_id"];
    NSString *personEmail = properties[@"email"];

    if (personId == nil && personEmail == nil) {
        return NSLog(@"id or email must be set in person properties for identify");
    }

    if (personId == nil) {
        personId = [NSString stringWithFormat:@"email:%@", personEmail];
    }

    self.config.personId = personId;
    self.config.personEmail = personEmail;
    self.identified = YES;

    self.config.personName = properties[@"name"];

    if (self.config.personName == nil && properties[@"first_name"] != nil && properties[@"last_name"] != nil) {
        self.config.personName = [NSString stringWithFormat:@"%@ %@", properties[@"first_name"], properties[@"last_name"]];
    }

    NSString *path = [NSString stringWithFormat:kGSTrackerIdentifyPath, self.trackingAPIParams];

    NSDictionary *body = @{
                           @"person_id": self.config.personId,
                           @"visitor_id": self.config.visitorId,
                           @"properties": properties
                           };

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:req];

    [self.delegate didIdentifyPerson];
}

- (void)unidentify
{
    [self verifyCredsAreSet];

    // wipe the current anon ID
    [self.config regenerateVisitorId];

    // wipe the current people ID
    self.config.personId = nil;
    self.config.personName = nil;
    self.config.personEmail = nil;

    self.identified = NO;

    [self.delegate didUnidentifyPerson];
}

#pragma mark Private - Assertion methods

- (void)verifyCredsAreSet
{
    NSAssert((self.token != nil), @"You must set a token before calling any tracking methods");
    NSAssert((self.key != nil), @"You must an API key before calling any tracking methods");
}


#pragma mark Public - URL path builder methods

- (NSString *)trackingAPIParams
{
    return [NSString stringWithFormat:@"site_token=%@&api_key=%@", self.token, self.key];
}


#pragma mark Public - HTTP Request methods

- (void)scheduleRequest:(GSRequest *)request
{
    // NOTE - this is where we'll make the requests durable later to enable offline event sync - not currently working

    [request setLogLevel:self.logLevel];
    [request sendWithCompletionHandler:nil];
}

- (void)sendRequest:(GSRequest *)request completionHandler:(GSRequestCompletionBlock)completionHandler
{
    [request setLogLevel:self.logLevel];
    [request sendWithCompletionHandler:completionHandler];
}


@end
