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
    [self verifySiteTokenIsSet];
    
    NSString *urlPath = [self pathForEvent:event];
    
    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:urlPath body:event.properties];
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
    [self verifySiteTokenIsSet];
    
    NSString *anonymousUserID = nil;
    if(!identified) anonymousUserID = self.currentUserID;
    
    identified = YES;
    self.currentUserID = userID;
    
    NSString *urlPath = [self pathForIdentify:userID anonymousUserID:anonymousUserID];
    
    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:urlPath body:properties];
    [self scheduleRequest:r];
    
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:kGSIdentifiedUUIDDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)identify:(NSString *)userID {
    [self identify:userID properties:nil];
}

- (void)unidentify {
    [self verifySiteTokenIsSet];
    
    // set userID to a new anon ID
    identified = NO;
    self.currentUserID = [self generateUUID:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kGSIdentifiedUUIDDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)trackTransaction:(GSTransaction *)transaction {
    [self verifySiteTokenIsSet];
    
    NSString *urlPath = [self pathForTransaction:transaction];
    
    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST path:urlPath body:transaction.serialize];
    [self scheduleRequest:r];
}


#pragma mark Private - Assertion methods

- (void)verifySiteTokenIsSet {
    NSAssert((self.siteToken != nil), @"You must call setSiteToken: before any tracking methods");
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

- (NSString *)pathForEvent:(GSEvent *)event {
    // build URL parts
    NSString *versionString = @"v1";
    NSString *escapedEventName = [event.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *escapedUserID = [self.currentUserID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // build URL
    return [NSString stringWithFormat:@"/%@/%@/event?name=%@&userID=%@", self.siteToken, versionString, escapedEventName, escapedUserID];
}

- (NSString *)pathForTransaction:(GSTransaction *)transaction {
    // build URL parts
    NSString *versionString = @"v1";
    NSString *escapedUserID = [self.currentUserID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // build URL
    return [NSString stringWithFormat:@"/%@/%@/transaction?userID=%@", self.siteToken, versionString, escapedUserID];
}

- (NSString *)pathForIdentify:(NSString *)userID anonymousUserID:(NSString *)anonymousUserID {
    // build URL parts
    NSString *versionString = @"v1";
    NSString *escapedUserID = [userID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // build URL
    if(anonymousUserID == nil) {
        return [NSString stringWithFormat:@"/%@/%@/people/%@/identify", self.siteToken, versionString, escapedUserID];
    }
    else {
        NSString *escapedAnonymousUserID = [anonymousUserID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"/%@/%@/people/%@/identify/%@", self.siteToken, versionString, escapedAnonymousUserID, escapedUserID];
    }
}



#pragma mark Private - HTTP Request methods

- (void)scheduleRequest:(GSRequest *)request {
    // NOTE - this is where we'll make the requests durable later to enable offline event sync
    [request send];
}




@end
