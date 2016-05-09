//
//  GSTransaction.m
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import "GSTransaction.h"

@interface GSTransaction ()

@property NSMutableArray *items;

@end

@implementation GSTransaction

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.items = [[NSMutableArray alloc] init];
    }

    return self;
}

+ (instancetype)transaction:(NSString *)transactionId
{
    return [GSTransaction transactionWithID:transactionId properties:nil];
}

+ (instancetype)transactionWithID:(NSString *)transactionID
{
    return [GSTransaction transactionWithID:transactionID properties:nil];
}

+ (instancetype)transactionWithID:(NSString *)transactionID properties:(NSDictionary *)properties
{
    GSTransaction *t = [[GSTransaction alloc] init];

    if (t) {
        t.transactionID = transactionID;
        t.properties = properties;
    }

    return t;
}

- (void)addItem:(GSTransactionItem *)item
{
    [self.items addObject:item];
}

- (void)addItems:(NSArray *)items
{
    for (GSTransactionItem *item in items) {
        [self.items addObject:item];
    }
}

- (NSDictionary *)serializeWithLastTimestamp:(NSNumber *)timestamp
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    dict[@"id"] = self.transactionID;

    if (self.properties) {
        dict[@"opts"] = self.properties;
    }

    // make sure we don't attempt to serialize a nil items array
    if (self.items == nil) self.items = [[NSMutableArray alloc] init];

    // serialize items
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (GSTransactionItem *item in self.items) {
        if ([item isKindOfClass:[GSTransactionItem class]]) {
            [items addObject:item.serialize];
        }
    }
    dict[@"items"] = [NSArray arrayWithArray:items];

    if (!timestamp) timestamp = @0;
    dict[@"previous_transaction_timestamp"] = timestamp;

    return [NSDictionary dictionaryWithDictionary:dict];
}


@end
