//
//  GSTracker.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSLogLevel.h"
#import "GSTransaction.h"
#import "GSTransactionItem.h"

@interface GSTracker : NSObject

@property (nonnull) NSString *token;
@property (nonnull) NSString *key;

@property (nonatomic) BOOL shouldTrackInBackground;
@property GSLogLevel logLevel;

@property (readonly, nonnull) NSString *visitorId;
@property (readonly, nullable) NSString *personId;
@property (readonly, getter=isIdentified) BOOL identified;


// event tracking
- (void)trackEvent:(nonnull NSString *)name;
- (void)trackEvent:(nonnull NSString *)name properties:(nullable NSDictionary *)properties;

// pageview tracking - only used if not using the UIViewController+GSTracking category
- (void)trackScreen:(nullable NSString *)title;
- (void)trackScreen:(nullable NSString *)title withPath:(nullable NSString *)path;

// people
- (void)identifyWithProperties:(nonnull NSDictionary *)properties;
- (void)unidentify;

// ecommerce
- (void)trackTransaction:(nonnull GSTransaction *)transaction;
- (void)trackTransaction:(nonnull NSString *)transactionID items:(nonnull NSArray<GSTransactionItem *> *)items;
- (void)trackTransaction:(nonnull NSString *)transactionID items:(nonnull NSArray<GSTransactionItem *> *)items properties:(nullable NSDictionary *)properties;

@end
