//
//  GSTransaction.h
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSTransactionItem;

@interface GSTransaction : NSObject

@property (strong, nonatomic) NSString *transactionID;
@property (strong, nonatomic) NSDictionary *properties;

+ (GSTransaction *)transactionWithID:(NSString *)transactionID properties:(NSDictionary *)properties;
+ (GSTransaction *)transactionWithID:(NSString *)transactionID;

- (void)addItem:(GSTransactionItem *)item;
- (void)addItems:(NSArray *)items;

- (NSDictionary *)serialize;

@end
