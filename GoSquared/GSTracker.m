//
//  GSTracker.m
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import "GSTracker.h"

#import "GSRequest.h"
#import "GSTrackerEvent.h"
#import "GSTransaction.h"
#import "GSTransactionItem.h"

#import "GSPageviewTracker.h"

#import <UIKit/UIKit.h>

static NSString * const kGSTrackerVersion = @"ios-0.0.10";
static NSString * const kGSTrackerDefaultTitle = @"Unknown";
static NSString * const kGSTrackerDefaultPath = @"";

static NSString * const kGSAnonymousUUIDDefaultsKey = @"com.gosquared.defaults.anonUUID";
static NSString * const kGSIdentifiedUUIDDefaultsKey = @"com.gosquared.defaults.identifiedUUID";

static NSString * const kGSTransactionLastTimestamp = @"com.gosquared.transaction.last";

@interface GSTracker()

@property (strong, nonatomic) GSPageviewTracker *pageviewTracker;

@property (strong, nonatomic) NSString *currentPersonID;
@property (strong, nonatomic) NSString *anonID;

@end

@implementation GSTracker {
    BOOL identified;

    NSNumber *lastTransaction;
}


#pragma mark Public methods

- (GSTracker *)init {
    self = [super init];

    if (self) {
        // grab a saved anon UDID or generate on if it doesn't exist
        self.anonID = [self generateUUID:NO];

        // set default log level
        self.logLevel = GSRequestLogLevelQuiet;

        // grab a saved People Analytics user ID if one is saved
        NSString *identifiedPersonID = [[NSUserDefaults standardUserDefaults] objectForKey:kGSIdentifiedUUIDDefaultsKey];
        if (identifiedPersonID) {
            self.currentPersonID = identifiedPersonID;
            identified = true;
        }

        lastTransaction = [[NSUserDefaults standardUserDefaults] objectForKey:kGSTransactionLastTimestamp];
        if (!lastTransaction) {
            lastTransaction = @0;
        }
    }

    return self;
}

- (NSString *)trackerVersion {
    return kGSTrackerVersion;
}


#pragma mark Public - Page view tracking

- (void)trackScreen:(NSString *)title {
    [self trackScreen:title withPath:nil];
}

- (void)trackScreen:(NSString *)title withPath:(NSString *)path {
    [self verifyCredsAreSet];

    // set default title if missing or empty
    if (title == nil || [title isEqual: @""]) {
        title = kGSTrackerDefaultTitle;
    }

    // set default path if missing or empty
    if (path == nil || [path isEqual:@""]) {
        path = [title isEqual:kGSTrackerDefaultTitle] ? kGSTrackerDefaultPath : title;
    }

    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];

    NSString *os = @"ios";

    #if TARGET_OS_TV
        os = @"tvos";
    #endif

    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *url = [NSString stringWithFormat:@"%@://%@/%@", os, bundleId, path];

    if (self.pageviewTracker == nil) {
        self.pageviewTracker = [[GSPageviewTracker alloc] initWithTracker: self];
    }

    [self.pageviewTracker startWithURLString:url title:title];
}


- (void)trackViewController:(UIViewController *)vc {
    NSString *title = vc.title;

    if (title == nil) {
        if(vc.navigationItem.title != nil) {
            title = vc.navigationItem.title;
        } else if (vc.navigationController.title != nil) {
            title = vc.navigationController.title;
        }
    }

    [self trackViewController:vc withTitle:title];
}

- (void)trackViewController:(UIViewController *)vc withTitle:(NSString *)title {
    NSString *fakeURL = [NSString stringWithFormat:@"%@://%@", [[NSBundle mainBundle] bundleIdentifier], [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self trackViewController:vc withTitle:title urlPath:fakeURL];
}

- (void)trackViewController:(UIViewController *)vc withTitle:(NSString *)title urlPath:(NSString *)urlPath {
    if(self.pageviewTracker == nil) {
        self.pageviewTracker = [[GSPageviewTracker alloc] initWithTracker: self];
    }

    [self.pageviewTracker startWithURLString:urlPath title:title];
}


#pragma mark Public - Event tracking

- (void)trackEvent:(GSTrackerEvent *)event {
    [self trackEvent:event.name withProperties:event.properties];
}

- (void)trackEvent:(NSString *)name withProperties:(NSDictionary *)properties {
    [self verifyCredsAreSet];

    NSMutableDictionary *event = [[NSMutableDictionary alloc] init];
    event[@"name"] = name;

    if (properties != nil) {
        event[@"data"] = properties;
    }

    NSString *path = [NSString stringWithFormat: @"/tracking/v1/event?%@", self.trackingAPIParams];
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"visitor_id": self.anonID, // anonymous user ID
                                                                                @"event": event             // json object for event
                                                                                }];

    if (self.pageviewTracker != nil) {
        body[@"page"] = @{ @"index": [self.pageviewTracker pageIndex] };
    }

    if (self.currentPersonID != nil) {
        body[@"person_id"] = self.currentPersonID;
    }

    // detect location from request IP
    body[@"ip"] = @"detect";

    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:r];
}


#pragma mark Public - Ecommerce tracking

- (void)trackTransaction:(NSString *)transactionID items:(NSArray *)items {
    [self trackTransaction:transactionID items:items properties:nil];
}

- (void)trackTransaction:(NSString *)transactionID items:(NSArray *)items properties:(NSDictionary *)properties {
    GSTransaction *tx = [GSTransaction transactionWithID:transactionID properties:properties];
    [tx addItems:items];

    [self trackTransaction:tx];
}

- (void)trackTransaction:(GSTransaction *)transaction {
    [self verifyCredsAreSet];

    NSDictionary *tx = [transaction serializeWithLastTimestamp:lastTransaction];

    NSString *path = [NSString stringWithFormat: @"/tracking/v1/transaction?%@", self.trackingAPIParams];
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
        @"visitor_id": self.anonID, // anonymous UDID
        @"transaction": tx
    }];

    if (self.currentPersonID != nil) {
        body[@"person_id"] = self.currentPersonID;
    }

    body[@"ip"] = @"detect";

    lastTransaction = [NSNumber numberWithLong:(long)[NSDate new].timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setObject:lastTransaction forKey:kGSTransactionLastTimestamp];

    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:r];
}


#pragma mark Public - People Analytics

- (void)identify:(NSString *)userID {
    [self identify:userID properties:nil];
}

- (void)identify:(NSString *)userID properties:(NSDictionary *)properties {
    [self verifyCredsAreSet];

    self.currentPersonID = userID;

    NSString *path = [NSString stringWithFormat: @"/tracking/v1/identify?%@", self.trackingAPIParams];
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"person_id": self.currentPersonID
                                                                                }];

    if (properties != nil) {
        body[@"properties"] = properties;
    }
    if (self.anonID != nil) {
        body[@"visitor_id"] = self.anonID; // anonymous user ID for stiching
    }

    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:r];

    identified = true;

    // save the identified People user id for later app launches
    [[NSUserDefaults standardUserDefaults] setObject:self.currentPersonID forKey:kGSIdentifiedUUIDDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)unidentify {
    [self verifyCredsAreSet];

    // wipe the current anon ID
    self.anonID = [self generateUUID:YES];

    // wipe the current people ID
    self.currentPersonID = nil;

    identified = false;

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kGSIdentifiedUUIDDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)identified {
    return identified;
}


#pragma mark Private - Assertion methods

- (void)verifyCredsAreSet {
    NSAssert((self.siteToken != nil), @"You must call setSiteToken: before any tracking methods");
    NSAssert((self.apiKey != nil), @"You must call setApiKey: before any tracking methods");
}


#pragma mark Private - UUID methods

- (NSString *)generateUUID:(BOOL)forceRegenerate {
    // set forceRegenerate to NO to simply pick up the existing UUID
    NSString *uuid = [[NSUserDefaults standardUserDefaults] objectForKey:kGSAnonymousUUIDDefaultsKey];

    if (forceRegenerate || uuid == nil) {
        // need to generate a UUID
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        uuid = (__bridge NSString *)string;

        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:kGSAnonymousUUIDDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return uuid;
}


#pragma mark Public - URL path builder methods

- (NSString *)trackingAPIParams {
    return [NSString stringWithFormat:@"site_token=%@&api_key=%@", self.siteToken, self.apiKey];
}


#pragma mark Public - HTTP Request methods

- (void)scheduleRequest:(GSRequest *)request {
    // NOTE - this is where we'll make the requests durable later to enable offline event sync - not currently working.

    [request setLogLevel:self.logLevel];
    [request send];
}

- (void)sendRequestSync:(GSRequest *)request {
    [request setLogLevel:self.logLevel];
    [request sendSync];
}


@end
