//
//  GSTransaction.h
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSTransactionItem.h"

@interface GSTransaction : NSObject

@property NSString *transactionID;
@property NSDictionary *properties;

+ (instancetype)transaction:(NSString *)transactionID;
+ (instancetype)transactionWithID:(NSString *)transactionID;
+ (instancetype)transactionWithID:(NSString *)transactionID properties:(NSDictionary *)properties;

- (void)addItem:(GSTransactionItem *)item;
- (void)addItems:(NSArray *)items;

- (NSDictionary *)serializeWithLastTimestamp:(NSNumber *)timestamp;

@end
