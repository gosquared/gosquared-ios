//
//  GSTracker.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSRequest.h"

@class UIViewController;

@class GSTrackerEvent;
@class GSTransaction;
@class GSTransactionItem;
@class GSDevice;

@interface GSTracker : NSObject

@property (nonnull) NSString *token;
@property (nonnull) NSString *key;

@property (readonly, nonnull) NSString *anonID;
@property (readonly, nullable) NSString *currentPersonID;

@property GSRequestLogLevel logLevel;

@property (readonly, nonnull) NSString *trackerVersion;

- (nonnull NSString *)trackingAPIParams;

- (void)scheduleRequest:(nonnull GSRequest *)request;
- (void)sendRequestSync:(nonnull GSRequest *)request;

// event tracking
- (void)trackEvent:(GSTrackerEvent * _Null_unspecified)event __attribute__((deprecated("Use trackEvent:withProperties: instead")));
- (void)trackEvent:(nonnull NSString *)name withProperties:(nullable NSDictionary *)properties;

// page view tracking - only used if not using the UIViewController+GSTracking category
- (void)trackViewController:(UIViewController * _Null_unspecified)vc __attribute__((deprecated("Use trackScreen: instead")));
- (void)trackViewController:(UIViewController * _Null_unspecified)vc withTitle:(NSString * _Null_unspecified)title __attribute__((deprecated("Use trackScreen: instead")));
- (void)trackViewController:(UIViewController * _Null_unspecified)vc withTitle:(NSString * _Null_unspecified)title urlPath:(NSString * _Null_unspecified)urlPath __attribute__((deprecated("Use trackScreen:withPath: instead")));

- (void)trackScreen:(nullable NSString *)title;
- (void)trackScreen:(nullable NSString *)title withPath:(nullable NSString *)path;

// people
- (void)identify:(nonnull NSString *)userID;
- (void)identify:(nonnull NSString *)userID properties:(nullable NSDictionary *)properties;
- (void)unidentify;
- (BOOL)identified;

// ecommerce
- (void)trackTransaction:(nonnull GSTransaction *)transaction;
- (void)trackTransaction:(nonnull NSString *)transactionID items:(nonnull NSArray *)items;
- (void)trackTransaction:(nonnull NSString *)transactionID items:(nonnull NSArray *)items properties:(nullable NSDictionary *)properties;

@end
