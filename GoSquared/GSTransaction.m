//
//  GSTransaction.m
//  GoSquared
//
//  Created by Giles Williams on 13/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import "GSTransaction.h"

#import "GSTransactionItem.h"

@interface GSTransaction ()

@property (strong, nonatomic) NSMutableArray *items;

@end

@implementation GSTransaction

- (id)init {
    self = [super init];

    if(self) {
        self.items = [[NSMutableArray alloc] init];
    }

    return self;
}

+ (GSTransaction *)transactionWithID:(NSString *)transactionID properties:(NSDictionary *)properties {
    GSTransaction *t = [[GSTransaction alloc] init];

    if(t) {
        t.transactionID = transactionID;
        t.properties = properties;
    }

    return t;
}

+ (GSTransaction *)transactionWithID:(NSString *)transactionID {
    return [GSTransaction transactionWithID:transactionID properties:nil];
}

- (void)addItem:(GSTransactionItem *)item {
    [self.items addObject:item];
}

- (void)addItems:(NSArray *)items {
    for(GSTransactionItem *item in items) {
        [self.items addObject:item];
    }
}

- (NSDictionary *)serialize {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    dict[@"id"] = self.transactionID;

    if(self.properties) {
        dict[@"opts"] = self.properties;
    }

    // make sure we don't attempt to serialize a nil items array
    if(self.items == nil) self.items = [[NSMutableArray alloc] init];

    // serialize items
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for(GSTransactionItem *item in self.items) {
        if([item isKindOfClass:[GSTransactionItem class]]) {
            [items addObject:item.serialize];
        }
    }
    dict[@"items"] = [NSArray arrayWithArray:items];

    return [NSDictionary dictionaryWithDictionary:dict];
}


@end
