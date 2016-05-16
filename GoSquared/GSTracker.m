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
#import "GSDevice.h"
#import "GSRequest.h"
#import "GSTrackerEvent.h"
#import "GSTransaction.h"
#import "GSTransactionItem.h"
#import "GSTrackerEvent.h"
#import "GSPageview.h"


dispatch_queue_t GSPageviewTrackerQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.gosquared.pageviewtracker.queue", 0);
    });
    return queue;
}


// tracker default config
static NSString * const kGSTrackerVersion        = @"ios-0.2.0";
static NSString * const kGSTrackerDefaultTitle   = @"Unknown";
static NSString * const kGSTrackerDefaultPath    = @"";
static const float kGSTrackerDefaultPingInterval = 20.0f;

// person / visitor UUIDs
static NSString * const kGSAnonymousUUIDDefaultsKey  = @"com.gosquared.defaults.anonUUID";
static NSString * const kGSIdentifiedUUIDDefaultsKey = @"com.gosquared.defaults.identifiedUUID";

// tracker saved properties
static NSString * const kGSTransactionLastTimestamp = @"com.gosquared.transaction.last";
static NSString * const kGSPageviewTrackerReturningDefaultsKey = @"com.gosquared.pageviewtracker.returning";
static NSString * const kGSPageviewLastTimestamp = @"com.gosquared.pageview.last";

// api endpoint paths
static NSString * const kGSTrackerPageviewPath    = @"/tracking/v1/pageview?%@";
static NSString * const kGSTrackerPingPath        = @"/tracking/v1/ping?%@";
static NSString * const kGSTrackerEventPath       = @"/tracking/v1/event?%@";
static NSString * const kGSTrackerTransactionPath = @"/tracking/v1/transaction?%@";
static NSString * const kGSTrackerIdentifyPath    = @"/tracking/v1/identify?%@";


@interface GSTracker()

@property NSString *personId;
@property NSString *visitorId;

@property (readwrite) BOOL identified;
@property (getter=isReturning) BOOL returning;

@property (getter=isValid) BOOL valid;

@property NSTimer *pageviewPingTimer;

@property NSString *pageviewURLString;
@property NSString *pageviewTitle;
@property NSNumber *pageviewPageIndex;

@property NSNumber *lastPageview;
@property NSNumber *lastTransaction;

@end

@implementation GSTracker

#pragma mark Public methods

- (instancetype)init
{
    self = [super init];

    if (self) {
        // grab a saved anon UDID or generate on if it doesn't exist
        self.visitorId = [self generateUUID:NO];

        // set default log level
        self.logLevel = GSLogLevelQuiet;

        // grab a saved People user ID if one is saved
        NSString *identifiedPersonID = [[NSUserDefaults standardUserDefaults] objectForKey:kGSIdentifiedUUIDDefaultsKey];
        if (identifiedPersonID) {
            self.personId = identifiedPersonID;
            self.identified = true;
        }

        self.lastTransaction = [[NSUserDefaults standardUserDefaults] objectForKey:kGSTransactionLastTimestamp];
        if (!self.lastTransaction) {
            self.lastTransaction = @0;
        }

        self.lastPageview = [[NSUserDefaults standardUserDefaults] objectForKey:kGSPageviewLastTimestamp];
        if (!self.lastPageview) {
            self.lastPageview = @0;
        }
        
        self.returning = [[NSUserDefaults standardUserDefaults] boolForKey:kGSPageviewTrackerReturningDefaultsKey];

        if (!self.shouldTrackInBackground) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnteredForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
        }
    }

    return self;
}


#pragma mark Public - Pageview tracking

- (void)trackScreen:(NSString *)title
{
    [self trackScreen:title withPath:nil];
}

- (void)trackScreen:(NSString *)title withPath:(NSString *)path
{
    [self verifyCredsAreSet];
    [self invalidatePingTimer];

    // set default title if missing or empty
    if (title == nil || [title isEqual: @""]) {
        title = kGSTrackerDefaultTitle;
    }

    // set default path if missing or empty
    if (path == nil || [path isEqual:@""]) {
        path = [title isEqual:kGSTrackerDefaultTitle] ? kGSTrackerDefaultPath : title;
    }

    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];

    NSString *os = [GSDevice currentDevice].os;
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];

    self.pageviewTitle = title;
    self.pageviewURLString = [NSString stringWithFormat:@"%@://%@/%@", os, bundleId, path];
    self.valid = YES;

    [self startPingTimer];
    [self track];
}


#pragma mark Private - Pageview tracking

- (void)appEnteredBackground
{
    [self invalidatePingTimer];
}

- (void)appEnteredForeground
{
    if (self.pageviewTitle != nil && self.pageviewURLString != nil) {
        [self trackScreen:self.pageviewTitle withPath:self.pageviewURLString];
    }
}

- (void)startPingTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pageviewPingTimer = [NSTimer scheduledTimerWithTimeInterval:kGSTrackerDefaultPingInterval target:self selector:@selector(ping) userInfo:nil repeats:YES];
    });
}

- (void)invalidatePingTimer
{
    self.valid = NO;

    if (self.pageviewPingTimer) {
        [self.pageviewPingTimer invalidate];
        self.pageviewPingTimer = nil;
    }
}

- (void)track
{
    if (!self.isValid) return;

    // use GCD barrier to force queuing of requests
    dispatch_barrier_async(GSPageviewTrackerQueue(), ^{
        NSString *path = [NSString stringWithFormat:kGSTrackerPageviewPath, self.trackingAPIParams];

        NSDictionary *body = [GSPageview generateBodyForPageviewWithTitle:self.pageviewTitle
                                                                      URL:self.pageviewURLString
                                                                   device:[GSDevice currentDevice]
                                                                visitorId:self.visitorId
                                                                 personId:self.personId
                                                                pageIndex:self.pageviewPageIndex
                                                             lastPageview:self.lastPageview
                                                                returning:self.isReturning
                                                           trackerVersion:kGSTrackerVersion];

        GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];

        [self sendRequest:req completionHandler:^(NSDictionary *data, NSError *error) {
            if (data == nil) {
                return;
            }

            NSNumber *index = data[@"index"];

            if (index != nil && ![index isKindOfClass:[NSNull class]]) {
                self.pageviewPageIndex = index;
            }
        }];
    });

    self.returning = YES;

    [[NSUserDefaults standardUserDefaults] setBool:self.isReturning forKey:kGSPageviewTrackerReturningDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)ping
{
    if (!self.isValid) return;

    NSString *path = [NSString stringWithFormat:kGSTrackerPingPath, self.trackingAPIParams];

    NSDictionary *body = [GSPageview generateBodyForPingWithTitle:self.pageviewTitle
                                                              URL:self.pageviewURLString
                                                           device:[GSDevice currentDevice]
                                                        visitorId:self.visitorId
                                                         personId:self.personId
                                                        pageIndex:self.pageviewPageIndex
                                                   trackerVersion:kGSTrackerVersion];

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];

    [self sendRequest:req completionHandler:^(NSDictionary *data, NSError *error) {
        if (!error) return;

        if ([error.userInfo[@"code"] isEqualToString:@"visitor_not_online"]) {
            [self track];
        } else if ([error.userInfo[@"code"] isEqualToString:@"max_inactive_time"]) {
            [self track];
        } else if ([error.userInfo[@"code"] isEqualToString:@"max_session_time"]) {
            [self track];
        }
    }];

    self.lastPageview = [NSNumber numberWithLong:(long)[NSDate new].timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastPageview forKey:kGSPageviewLastTimestamp];
}


#pragma mark Public - Event tracking

- (void)trackEvent:(NSString *)name
{
    [self trackEvent:name properties:nil];
}

- (void)trackEvent:(NSString *)name properties:(NSDictionary *)properties
{
    [self verifyCredsAreSet];

    NSString *path = [NSString stringWithFormat:kGSTrackerEventPath, self.trackingAPIParams];

    GSTrackerEvent *event = [GSTrackerEvent eventWithName:name properties:properties];

    NSDictionary *body = [event serializeWithVisitorId:self.visitorId
                                              personId:self.personId
                                             pageIndex:self.pageviewPageIndex];

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:req];
}


#pragma mark Public - Ecommerce tracking

- (void)trackTransaction:(NSString *)transactionID items:(NSArray *)items
{
    [self trackTransaction:transactionID items:items properties:nil];
}

- (void)trackTransaction:(NSString *)transactionID items:(NSArray *)items properties:(NSDictionary *)properties
{
    GSTransaction *transaction = [GSTransaction transactionWithID:transactionID properties:properties];
    [transaction addItems:items];

    [self trackTransaction:transaction];
}

- (void)trackTransaction:(GSTransaction *)transaction
{
    [self verifyCredsAreSet];

    NSString *path = [NSString stringWithFormat:kGSTrackerTransactionPath, self.trackingAPIParams];

    NSDictionary *body = [transaction serializeWithVisitorId:self.visitorId
                                                    personId:self.personId
                                                   pageIndex:self.pageviewPageIndex
                                    lastTransactionTimestamp:self.lastTransaction];

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:req];

    self.lastTransaction = [NSNumber numberWithLong:(long)[NSDate new].timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setObject:self.lastTransaction forKey:kGSTransactionLastTimestamp];
}


#pragma mark Public - People Analytics

- (void)identify:(NSString *)userID
{
    [self identify:userID properties:nil];
}

- (void)identify:(NSString *)userID properties:(NSDictionary *)properties
{
    [self verifyCredsAreSet];

    self.personId = userID;

    NSString *path = [NSString stringWithFormat:kGSTrackerIdentifyPath, self.trackingAPIParams];

    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{ @"person_id": self.personId }];

    if (properties != nil) {
        body[@"properties"] = properties;
    }

    if (self.visitorId != nil) {
        body[@"visitor_id"] = self.visitorId; // anonymous user ID for stitching
    }

    GSRequest *req = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:req];

    self.identified = true;

    // save the identified person id for future app launches
    [[NSUserDefaults standardUserDefaults] setObject:self.personId forKey:kGSIdentifiedUUIDDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)unidentify
{
    [self verifyCredsAreSet];

    // wipe the current anon ID
    self.visitorId = [self generateUUID:YES];

    // wipe the current people ID
    self.personId = nil;

    self.identified = false;

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kGSIdentifiedUUIDDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Private - Assertion methods

- (void)verifyCredsAreSet
{
    NSAssert((self.token != nil), @"You must set a token before calling any tracking methods");
    NSAssert((self.key != nil), @"You must an API key before calling any tracking methods");
}


#pragma mark Private - UUID methods

- (NSString *)generateUUID:(BOOL)forceRegenerate
{
    // set forceRegenerate to NO to simply pick up the existing UUID
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:kGSAnonymousUUIDDefaultsKey];

    if (forceRegenerate || uuid == nil) {
        uuid = [[NSUUID alloc] init].UUIDString;

        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:kGSAnonymousUUIDDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return uuid;
}


#pragma mark Public - URL path builder methods

- (NSString *)trackingAPIParams
{
    return [NSString stringWithFormat:@"site_token=%@&api_key=%@", self.token, self.key];
}


#pragma mark Public - HTTP Request methods

- (void)scheduleRequest:(GSRequest *)request
{
    // NOTE - this is where we'll make the requests durable later to enable offline event sync - not currently working.

    [request setLogLevel:self.logLevel];
    [request send];
}

- (void)sendRequest:(GSRequest *)request completionHandler:(GSRequestCompletionBlock)completionHandler
{
    [request setLogLevel:self.logLevel];
    [request sendWithCompletionHandler:completionHandler];
}


@end
