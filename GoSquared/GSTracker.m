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

#import "GSPageViewTracker.h"

#import <UIKit/UIKit.h>

static NSString * const kGSTrackerVersion = @"ios_0.2";

static NSString * const kGSAnonymousUUIDDefaultsKey = @"com.gosquared.defaults.anonUUID";
static NSString * const kGSIdentifiedUUIDDefaultsKey = @"com.gosquared.defaults.identifiedUUID";

@interface GSTracker()

@property (strong, nonatomic) GSPageViewTracker *pageViewTracker;

@property (strong, nonatomic) NSString *currentPersonID;
@property (strong, nonatomic) NSString *anonID;

@end

@implementation GSTracker {
    BOOL identified;

    NSDictionary *deviceMetrics;
}


#pragma mark Public methods

- (GSTracker *)init {
    self = [super init];

    if(self) {
        // grab a saved anon UDID or generate on if it doesn't exist
        self.anonID = [self generateUUID:NO];

        // grab a saved People Analytics user ID if one is saved
        NSString *identifiedPersonID = [[NSUserDefaults standardUserDefaults] objectForKey:kGSIdentifiedUUIDDefaultsKey];
        if(identifiedPersonID) {
            self.currentPersonID = identifiedPersonID;
        }
    }

    return self;
}

- (NSString *)trackerVersion {
    return kGSTrackerVersion;
}


#pragma mark Public - Page view tracking

- (void)trackViewController:(UIViewController *)vc {
    NSString *title = vc.title;

    if(title == nil) {
        if(vc.navigationItem.title != nil) {
            title = vc.navigationItem.title;
        }
        else if(vc.navigationController.title != nil) {
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
    if(self.pageViewTracker == nil) {
        self.pageViewTracker = [[GSPageViewTracker alloc] initWithTracker: self];
    }

    [self.pageViewTracker startWithURLString:urlPath title:title];
}


#pragma mark Public - Event tracking

- (void)trackEvent:(GSTrackerEvent *)event {
    [self verifyCredsAreSet];

    NSString *path = [NSString stringWithFormat: @"/tracking/v1/event?%@", self.trackingAPIParams];
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"visitor_id": self.anonID, // anonymous user ID
                                                                                @"event": event.serialize // json object for event
                                                                                }];

    if(self.pageViewTracker != nil) {
        body[@"page"] = @{
                          @"index": [self.pageViewTracker pageIndex]
                          };
    }

    if(self.currentPersonID != nil) {
        body[@"person_id"] = self.currentPersonID;
    }

    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:r];
}


#pragma mark Public - Ecommerce tracking

- (void)trackTransaction:(GSTransaction *)transaction {
    [self verifyCredsAreSet];

    NSString *path = [NSString stringWithFormat: @"/tracking/v1/transaction?%@", self.trackingAPIParams];
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
        @"visitor_id": self.anonID, // anonymous UDID
        @"transaction": transaction.serialize
    }];

    if(self.currentPersonID != nil) {
        body[@"person_id"] = self.currentPersonID;
    }

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

    if(properties != nil) {
        body[@"properties"] = properties;
    }
    if(self.anonID != nil) {
        body[@"visitor_id"] = self.anonID; // anonymous user ID for stiching
    }

    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:r];

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

    if(forceRegenerate || uuid == nil) {
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


#pragma mark Private - HTTP Request methods

- (void)scheduleRequest:(GSRequest *)request {
    // NOTE - this is where we'll make the requests durable later to enable offline event sync
    [request send];
}


@end
