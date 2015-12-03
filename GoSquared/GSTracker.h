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
@class GSTransactionItem;
@class GSDevice;

@interface GSTracker : NSObject

@property (strong, nonatomic) NSString *siteToken;
@property (strong, nonatomic) NSString *apiKey;

@property (strong, readonly) NSString *currentPersonID;
@property (strong, readonly) NSString *anonID;

- (NSString *)trackerVersion;

- (NSString *)trackingAPIParams;

// event tracking
- (void)trackEvent:(GSTrackerEvent *)event __attribute__((deprecated("Use trackEvent:withProperties: instead")));

- (void)trackEvent:(NSString *)name withProperties:(NSDictionary *)properties;

// page view tracking - only used if not using the UIViewController+GSTracking category
- (void)trackViewController:(UIViewController *)vc __attribute__((deprecated("Use trackScreen: instead")));
- (void)trackViewController:(UIViewController *)vc withTitle:(NSString *)title __attribute__((deprecated("Use trackScreen: instead")));
- (void)trackViewController:(UIViewController *)vc withTitle:(NSString *)title urlPath:(NSString *)urlPath __attribute__((deprecated("Use trackScreen:withPath: instead")));

- (void)trackScreen:(NSString *)title;
- (void)trackScreen:(NSString *)title withPath:(NSString *)path;

// people
- (void)identify:(NSString *)userID;
- (void)identify:(NSString *)userID properties:(NSDictionary *)properties;
- (void)unidentify;
- (BOOL)identified;

// ecommerce
- (void)trackTransaction:(GSTransaction *)transaction;
- (void)trackTransaction:(NSString *)transactionID items:(NSArray *)items;
- (void)trackTransaction:(NSString *)transactionID items:(NSArray *)items properties:(NSDictionary *)properties;

@end
