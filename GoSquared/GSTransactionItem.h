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

@property NSString *name;
@property NSMutableArray<NSString *> *categories;
@property NSNumber *revenue;
@property NSNumber *quantity;
@property NSNumber *price;

+ (instancetype)transactionItemWithName:(NSString *)name price:(NSNumber *)price quantity:(NSNumber *)quantity;

- (void)setCategory:(NSString *)category;

- (NSDictionary *)serialize;

@end
