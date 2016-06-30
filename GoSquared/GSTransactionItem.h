//
//  GSTransactionItem.h
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSTransactionItem : NSObject

@property (nonnull) NSString *name;
@property (nonnull) NSMutableArray<NSString *> *categories;
@property (nonnull) NSNumber *quantity;
@property (nonnull) NSNumber *price;
@property (nullable) NSNumber *revenue;

+ (nonnull instancetype)transactionItemWithName:(nonnull NSString *)name
                                          price:(nonnull NSNumber *)price
                                       quantity:(nonnull NSNumber *)quantity;

- (void)setCategory:(nonnull NSString *)category;
- (nonnull NSDictionary *)serialize;

@end
