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
#import "GSTransaction.h"

@interface GSTracker : NSObject

@property (nonnull) NSString *token;
@property (nonnull) NSString *key;

@property (readonly, nonnull) NSString *visitorId;
@property (readonly, nullable) NSString *personId;
@property (readonly, getter=isIdentified) BOOL identified;

@property GSLogLevel logLevel;

@property (readonly, nonnull) NSString *trackerVersion;

- (nonnull NSString *)trackingAPIParams;

- (void)scheduleRequest:(nonnull GSRequest *)request;
- (void)sendRequest:(nonnull GSRequest *)request completionHandler:(nonnull GSRequestCompletionBlock)completionHandler;

// event tracking
- (void)trackEvent:(nonnull NSString *)name withProperties:(nullable NSDictionary *)properties;

// pageview tracking - only used if not using the UIViewController+GSTracking category
- (void)trackScreen:(nullable NSString *)title;
- (void)trackScreen:(nullable NSString *)title withPath:(nullable NSString *)path;

// people
- (void)identify:(nonnull NSString *)userID;
- (void)identify:(nonnull NSString *)userID properties:(nullable NSDictionary *)properties;
- (void)unidentify;

// ecommerce
- (void)trackTransaction:(nonnull GSTransaction *)transaction;
- (void)trackTransaction:(nonnull NSString *)transactionID items:(nonnull NSArray *)items;
- (void)trackTransaction:(nonnull NSString *)transactionID items:(nonnull NSArray *)items properties:(nullable NSDictionary *)properties;

@end
