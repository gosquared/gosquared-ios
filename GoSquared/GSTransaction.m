//
//  GSTransaction.m
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
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

- (NSDictionary *)serializeWithVisitorId:(NSString *)visitorId personId:(NSString *)personId pageIndex:(NSNumber *)pageIndex lastTransactionTimestamp:(NSNumber *)lastTransactionTimestamp
{
    NSMutableDictionary *transaction = [[NSMutableDictionary alloc] init];
    transaction[@"id"] = self.transactionID;

    if (self.properties) {
        transaction[@"opts"] = self.properties;
    }

    if (self.items == nil) {
        self.items = [[NSMutableArray alloc] init];
    }

    NSMutableArray *items = [[NSMutableArray alloc] init];

    for (GSTransactionItem *item in self.items) {
        if ([item isKindOfClass:[GSTransactionItem class]]) {
            [self.items addObject:item.serialize];
        }
    }

    transaction[@"items"] = [NSArray arrayWithArray:items];

    if (!lastTransactionTimestamp) {
        lastTransactionTimestamp = @0;
    }

    transaction[@"previous_transaction_timestamp"] = lastTransactionTimestamp;

    
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"visitor_id": visitorId,
                                                                                @"transaction": transaction
                                                                                }];


    body[@"page"] = @{ @"index": pageIndex };

    if (personId != nil) {
        body[@"person_id"] = personId;
    }

    // detect location from request IP
    body[@"ip"] = @"detect";

    return [NSDictionary dictionaryWithDictionary:body];
}

@end
