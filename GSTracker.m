//
//  GSTracker.m
//  GoSquared-iOS-Native
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//

#import "GSTracker.h"

#import "GSRequest.h"
#import "GSEvent.h"
#import "GSTransaction.h"

#import "GSPageViewTracker.h"

#import <UIKit/UIKit.h>

static NSString * const kGSAnonymousUUIDDefaultsKey = @"com.gosquared.defaults.anonUUID";
static NSString * const kGSIdentifiedUUIDDefaultsKey = @"com.gosquared.defaults.identifiedUUID";

static GSTracker *sharedTracker = nil;

@interface GSTracker()

@property (strong, nonatomic) GSPageViewTracker *pageViewTracker;

@property (strong, nonatomic) NSString *currentUserID;

@end

@implementation GSTracker {
    BOOL identified;
    
    NSDictionary *deviceMetrics;
}

- (GSTracker *)init {
    self = [super init];
    
    if(self) {
        NSString *identifiedUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kGSIdentifiedUUIDDefaultsKey];
        if(identifiedUserID) {
            identified = YES;
            self.currentUserID = identifiedUserID;
        }
        else {
            identified = NO;
            self.currentUserID = [self generateUUID:NO];
        }
    }
    
    return self;
}

+ (GSTracker *)sharedInstance {
    if(sharedTracker == nil) {
        sharedTracker = [[GSTracker alloc] init];
    }
    
    return sharedTracker;
}


#pragma mark Public methods

- (void)trackEvent:(GSEvent *)event {
    [self verifyCredsAreSet];

    NSString *path = [NSString stringWithFormat: @"/tracking/v1/event?%@", self.trackingAPIParams];
    NSMutableDictionary *body = @{
      @"visitor_id": self.currentUserID,
      @"event": event
    };

    if(identified) {
      body[@"person_id"] = self.currentUserID;
    }

    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:r];
}

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
    NSString *fakeURL = [NSString stringWithFormat:@"ios-native://%@/%@", [[NSBundle mainBundle] bundleIdentifier], [title stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self trackViewController:vc withTitle:title urlString:fakeURL];
}
- (void)trackViewController:(UIViewController *)vc withTitle:(NSString *)title urlString:(NSString *)urlString {
    if(self.pageViewTracker == nil) {
        self.pageViewTracker = [[GSPageViewTracker alloc] init];
    }
    
    [self.pageViewTracker startWithURLString:urlString title:title];
}

- (void)identify:(NSString *)userID properties:(NSDictionary *)properties {
    [self verifyCredsAreSet];

    NSString *anonymousUserID = nil;
    if(!identified) anonymousUserID = self.currentUserID;
    
    identified = YES;
    self.currentUserID = userID;

    NSString *path = [NSString stringWithFormat: @"/tracking/v1/identify?%@", self.trackingAPIParams];
    NSDictionary *body = @{
      @"visitor_id": anonymousUserID,
      @"person_id": userID,
      @"properties": properties
    };

    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:r];
    
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:kGSIdentifiedUUIDDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)identify:(NSString *)userID {
    [self identify:userID properties:nil];
}

- (void)unidentify {
    [self verifyCredsAreSet];

    // set userID to a new anon ID
    identified = NO;
    self.currentUserID = [self generateUUID:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kGSIdentifiedUUIDDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)trackTransaction:(GSTransaction *)transaction {
    [self verifyCredsAreSet];

    NSString *path = [NSString stringWithFormat: @"/tracking/v1/transaction?%@", self.trackingAPIParams];
    NSMutableDictionary *body = @{
      @"visitor_id": self.currentUserID,
      @"transaction": transaction.serialize
    };

    if(identified) {
      body[@"person_id"] = self.currentUserID;
    }

    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:path body:body];
    [self scheduleRequest:r];
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
    
    if(forceRegenerate || !uuid) {
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


#pragma mark Private - URL path builder methods

- (NSString *)trackingAPIParams {
  return [NSString stringWithFormat:@"site_token=%@&api_key=%@", self.siteToken, self.apiKey];
}



#pragma mark Private - HTTP Request methods

- (void)scheduleRequest:(GSRequest *)request {
    // NOTE - this is where we'll make the requests durable later to enable offline event sync
    [request send];
}




@end
