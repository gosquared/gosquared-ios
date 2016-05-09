//
//  GSEvent.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

__attribute__((deprecated))
@interface GSTrackerEvent : NSObject

@property NSString *name;
@property NSDictionary *properties;

+ (GSTrackerEvent *)eventWithName:(NSString *)name;
- (NSDictionary *)serialize;

@end
