//
//  GSTransactionItem.h
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSTransactionItem : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSNumber *revenue;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSNumber *price;

- (void)setCategory:(NSString *)category;

- (NSDictionary *)serialize;

@end
