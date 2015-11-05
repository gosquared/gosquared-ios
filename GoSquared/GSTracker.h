//
//  GSTracker.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

@class GSTrackerEvent;
@class GSTransaction;
@class GSDevice;

@interface GSTracker : NSObject

@property (strong, nonatomic) NSString *siteToken;
@property (strong, nonatomic) NSString *apiKey;

@property (strong, readonly) NSString *currentPersonID;
@property (strong, readonly) NSString *anonID;

- (NSString *)trackerVersion;

- (NSString *)trackingAPIParams;

// event tracking
- (void)trackEvent:(GSTrackerEvent *)event;

// page view tracking - only used if not using the UIViewController+GSTracking category
- (void)trackViewController:(UIViewController *)vc;
- (void)trackViewController:(UIViewController *)vc withTitle:(NSString *)title;
- (void)trackViewController:(UIViewController *)vc withTitle:(NSString *)title urlPath:(NSString *)urlPath;

// people
- (void)identify:(NSString *)userID;
- (void)identify:(NSString *)userID properties:(NSDictionary *)properties;
- (void)unidentify;
- (BOOL)identified;

// ecommerce
- (void)trackTransaction:(GSTransaction *)transaction;

@end
