//
//  GSTransactionItem.m
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import "GSTransactionItem.h"

@implementation GSTransactionItem

- (id)init {
    self = [super init];

    if(self) {
        self.categories = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)setCategory:(NSString *)category {
    self.categories = [NSMutableArray arrayWithObject:category];
}

- (NSDictionary *)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    if(self.name != nil) dict[@"name"] = self.name;
    if(self.categories != nil) dict[@"categories"] = self.categories;
    if(self.revenue != nil) dict[@"revenue"] = self.revenue;
    if(self.quantity != nil) dict[@"quantity"] = self.quantity;
    if(self.price != nil) dict[@"price"] = self.price;

    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
