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

+ (GSTrackerEvent *)eventWithName:(NSString *)name properties:(NSDictionary *)properties
{
    GSTrackerEvent *event = [[GSTrackerEvent alloc] init];

    event.name = name;
    event.properties = properties;

    return event;
}

- (NSDictionary *)serializeWithVisitorId:(NSString *)visitorId personId:(NSString *)personId pageIndex:(NSNumber *)pageIndex;
{
    NSMutableDictionary *event = [[NSMutableDictionary alloc] init];

    event[@"name"] = self.name;

    if (self.properties) {
        event[@"data"] = self.properties;
    }

    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"visitor_id": visitorId, // anonymous user ID
                                                                                @"event": event           // json object for event
                                                                                }];


    if (pageIndex != nil) {
        body[@"page"] = @{ @"index": pageIndex };
    }

    if (personId != nil) {
        body[@"person_id"] = personId;
    }

    // detect location from request IP
    body[@"ip"] = @"detect";

    return [NSDictionary dictionaryWithDictionary:body];
}

@end
