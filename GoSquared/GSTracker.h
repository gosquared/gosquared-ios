//
//  GSTracker.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSTypes.h"
#import "GSTransaction.h"
#import "GSTransactionItem.h"

#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(args)
#endif

@interface GSTracker : NSObject

@property (nonatomic, nullable) NSString *token;
@property (nullable) NSString *key;

@property (nonatomic) BOOL shouldTrackInBackground;
@property GSLogLevel logLevel;

@property (readonly, nullable) NSString *visitorId;
@property (readonly, nullable) NSString *personId;
@property (readonly, getter=isIdentified) BOOL identified;

- (nonnull instancetype)initWithToken:(nonnull NSString *)token key:(nonnull NSString *)key;

// event tracking
- (void)trackEventWithName:(nonnull NSString *)name NS_SWIFT_NAME(trackEvent(name:));
- (void)trackEventWithName:(nonnull NSString *)name properties:(nullable GSPropertyDictionary *)properties NS_SWIFT_NAME(trackEvent(name:properties:));

// pageview tracking - only used if not using the UIViewController+GSTracking category
- (void)trackScreenWithTitle:(nullable NSString *)title NS_SWIFT_NAME(trackScreen(title:));
- (void)trackScreenWithTitle:(nullable NSString *)title path:(nullable NSString *)path NS_SWIFT_NAME(trackScreen(title:path:));

// people
- (void)identifyWithProperties:(nonnull GSPropertyDictionary *)properties NS_SWIFT_NAME(identify(properties:));
- (void)unidentify;

// ecommerce
- (void)trackTransaction:(nonnull GSTransaction *)transaction;
- (void)trackTransactionWithId:(nonnull NSString *)transactionId items:(nonnull NSArray<GSTransactionItem *> *)items NS_SWIFT_NAME(trackTransaction(id:items:));
- (void)trackTransactionWithId:(nonnull NSString *)transactionId items:(nonnull NSArray<GSTransactionItem *> *)items properties:(nullable GSPropertyDictionary *)properties NS_SWIFT_NAME(trackTransaction(id:items:properties:));

@end
