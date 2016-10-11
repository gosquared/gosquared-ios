//
//  GSTransactionItem.h
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 GSTransactionItem stores the information about a product in a transaction. You
 can specify information such as the product's name, categories and the quantity
 being bought.
 */
@interface GSTransactionItem : NSObject

/// The name of the product
@property (nonnull) NSString *name;

/// An array of categories this product belongs to
@property (nonnull) NSMutableArray<NSString *> *categories;

/// The number of items type
@property (nonnull) NSNumber *quantity;

/// The cost for a single product item
@property (nonnull) NSNumber *price;

/// Optional override for the total revenue from this item. Useful when applying
/// discounts (e.g. bulk discount)
@property (nullable) NSNumber *revenue;

/**
 Create and return a new GSTransactionItem with specified properties
 
 @param name Name of the product
 @param price The cost for a single product item
 @param quantity The number of items of a product for a transaction
 
 @return The new GSTransactionItem
 */
+ (nonnull instancetype)transactionItemWithName:(nonnull NSString *)name
                                          price:(nonnull NSNumber *)price
                                       quantity:(nonnull NSNumber *)quantity;

/**
 Serialise object into a JSON-valid NSDictionary
 
 @return JSON-valid NSDictonary
 */
- (nonnull NSDictionary *)serialize;

@end
