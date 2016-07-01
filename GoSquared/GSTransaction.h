//
//  GSTransaction.h
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSTransactionItem.h"

@interface GSTransaction : NSObject

@property (nonnull) NSString *transactionId;
@property (nullable) NSDictionary *properties;

+ (nonnull instancetype)transactionWithId:(nonnull NSString *)transactionId;
+ (nonnull instancetype)transactionWithId:(nonnull NSString *)transactionId properties:(nullable NSDictionary *)properties;

- (void)addItem:(nonnull GSTransactionItem *)item;
- (void)addItems:(nonnull NSArray<GSTransactionItem *> *)items;
- (nonnull NSDictionary *)serializeWithVisitorId:(nonnull NSString *)visitorId
                                        personId:(nullable NSString *)personId
                                       pageIndex:(nullable NSNumber *)pageIndex
                        lastTransactionTimestamp:(nullable NSNumber *)lastTransactionTimestamp;

@end
