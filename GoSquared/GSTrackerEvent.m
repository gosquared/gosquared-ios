//
//  GSEvent.m
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import "GSTrackerEvent.h"

@implementation GSTrackerEvent

+ (GSTrackerEvent *)eventWithName:(NSString *)name
{
    GSTrackerEvent *e = [[GSTrackerEvent alloc] init];

    if (e) {
        [e setName:name];
    }

    return e;
}

- (NSDictionary *)serialize
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    if (self.name != nil && [self.name isKindOfClass:[NSString class]]) {
        dict[@"name"] = self.name;
    }
    if (self.properties) {
        dict[@"data"] = self.properties;
    }

    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
