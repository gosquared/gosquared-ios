//
//  GSTransactionItem.m
//  GoSquared-iOS-Native
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
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
    
    if(self.name) dict[@"name"] = self.name;
    if(self.categories) dict[@"categories"] = self.categories;
    if(self.revenue) dict[@"revenue"] = self.revenue;
    if(self.quantity) dict[@"quantity"] = self.quantity;
    if(self.price) dict[@"price"] = self.price;
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
