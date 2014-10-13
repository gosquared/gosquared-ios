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

static NSString * const kGSAPIBase = @"https://data.gosquared.com";
static NSString * const kGSAnonymousUUIDDefaultsKey = @"com.gosquared.defaults.anonUUID";
static NSString * const kGSIdentifiedUUIDDefaultsKey = @"com.gosquared.defaults.identifiedUUID";

static GSTracker *sharedTracker = nil;

@interface GSTracker()

@property (strong, nonatomic) NSString *_siteToken;

@end

@implementation GSTracker {
    BOOL identified;
    NSString *currentUserID;
}

- (GSTracker *)init {
    self = [super init];
    
    if(self) {
        NSString *identifiedUserID = [[NSUserDefaults standardUserDefaults] objectForKey:kGSIdentifiedUUIDDefaultsKey];
        if(identifiedUserID) {
            identified = YES;
            currentUserID = identifiedUserID;
        }
        else {
            identified = NO;
            currentUserID = [self generateUUID:NO];
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

- (void)setSiteToken:(NSString *)siteToken {
    self._siteToken = siteToken;
}

- (void)trackEvent:(GSEvent *)event {
    [self verifySiteTokenIsSet];
    
    NSURL *url = [self urlForEvent:event];
    
    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST url:url body:event.properties];
    [self scheduleRequest:r];
}

- (void)trackScreenView:(NSString *)screenName {
    // NOTE - this method needs input from the GS team to determine if we should track a fake page view or an event
    [self verifySiteTokenIsSet];
    
    GSEvent *e = [GSEvent eventWithName:[NSString stringWithFormat:@"Screen: %@", screenName]];
    
    NSURL *url = [self urlForEvent:e];
    
    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST url:url body:e.properties];
    [self scheduleRequest:r];
}

- (void)identify:(NSString *)userID properties:(NSDictionary *)properties {
    [self verifySiteTokenIsSet];
    
    NSString *anonymousUserID = nil;
    if(!identified) anonymousUserID = currentUserID;
    
    identified = YES;
    currentUserID = userID;
    
    NSURL *url = [self urlForIdentify:userID anonymousUserID:anonymousUserID];
    
    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST url:url body:properties];
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
    currentUserID = [self generateUUID:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kGSIdentifiedUUIDDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)trackTransaction:(GSTransaction *)transaction {
    [self verifySiteTokenIsSet];
    
    NSURL *url = [self urlForTransaction:transaction];
    
    GSRequest *r = [GSRequest requestWithMethod:GSRequestMethodPOST url:url body:transaction.serialize];
    [self scheduleRequest:r];
}


#pragma mark Private - Assertion methods

- (void)verifySiteTokenIsSet {
    NSAssert((self._siteToken != nil), @"You must call setSiteToken: before any tracking methods");
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


#pragma mark Private - URL builder methods

- (NSURL *)urlForEvent:(GSEvent *)event {
    // build URL parts
    NSString *versionString = @"v1";
    NSString *escapedEventName = [event.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *escapedUserID = [currentUserID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // build URL
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/event?name=%@&userID=%@", kGSAPIBase, self._siteToken, versionString, escapedEventName, escapedUserID];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)urlForTransaction:(GSTransaction *)transaction {
    // build URL parts
    NSString *versionString = @"v1";
    NSString *escapedUserID = [currentUserID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // build URL
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/transaction?userID=%@", kGSAPIBase, self._siteToken, versionString, escapedUserID];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)urlForIdentify:(NSString *)userID anonymousUserID:(NSString *)anonymousUserID {
    // build URL parts
    NSString *versionString = @"v1";
    NSString *escapedUserID = [userID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // build URL
    NSString *urlString;
    if(anonymousUserID == nil) {
        urlString = [NSString stringWithFormat:@"%@/%@/%@/identify?userID=%@", kGSAPIBase, self._siteToken, versionString, escapedUserID];
    }
    else {
        NSString *escapedAnonymousUserID = [anonymousUserID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        urlString = [NSString stringWithFormat:@"%@/%@/%@/identify?userID=%@&anonymousID=%@", kGSAPIBase, self._siteToken, versionString, escapedUserID, escapedAnonymousUserID];
    }
    return [NSURL URLWithString:urlString];
}



#pragma mark Private - HTTP Request methods

- (void)scheduleRequest:(GSRequest *)request {
    // NOTE - this is where we'll add the requests to a queue later to enable offline event sync
    NSLog(@"GSTracker::scheduleRequest - %@", request);
    
    [request send];
}


@end
