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

/**
 GSTransaction manages an ecommerce transaction. Once initialised, you can add
 items to the transaction before tracking it on GoSquared.
 */
@interface GSTransaction : NSObject

/// The unique id for the transaction
@property (nonnull) NSString *transactionId;

/// Optional additional properties for the transaction
@property (nullable) NSDictionary *properties;

/**
 Creates and returns a new transaction with the specified transaction id
 
 @param transactionId The unique id for the transaction
 
 @return The new GSTransaction
 */
+ (nonnull instancetype)transactionWithId:(nonnull NSString *)transactionId;

/**
 Creates and returns a new transaction with the specified transaction id and additional properties
 
 @param transactionId The unique id for the transaction
 @param properties Optional additional properties for the transaction
 
 @return The new GSTransaction
 */
+ (nonnull instancetype)transactionWithId:(nonnull NSString *)transactionId properties:(nullable NSDictionary *)properties;

/**
 Adds a GSTransactionItem to the transaction
 
 @param item The item to add to the transaction
 */
- (void)addItem:(nonnull GSTransactionItem *)item;

/**
 Adds an array of GSTransactionItems to the transaction
 
 @param items An array of GSTransactionItems to add to the transaction
 */
- (void)addItems:(nonnull NSArray<GSTransactionItem *> *)items;

/**
 Serialise object into a JSON-valid NSDictionary
 
 @param visitorId The visitor id of the user making the transaction
 @param personId Your own id for the user making the transaction
 @param pageIndex The index of the screen the user is on when making the transaction
 @param lastTransactionTimestamp The unix timestamp of the last transaction

 @return JSON-valid NSDictonary
 */
- (nonnull NSDictionary *)serializeWithVisitorId:(nonnull NSString *)visitorId
                                        personId:(nullable NSString *)personId
                                       pageIndex:(nullable NSNumber *)pageIndex
                        lastTransactionTimestamp:(nullable NSNumber *)lastTransactionTimestamp;

@end
