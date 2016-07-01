//
//  GSEvent.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSTrackerEvent : NSObject

@property (nonnull) NSString *name;
@property (nullable) NSDictionary *properties;

+ (nonnull instancetype)eventWithName:(nonnull NSString *)name properties:(nullable NSDictionary *)properties;

- (nonnull NSDictionary *)serializeWithVisitorId:(nonnull NSString *)visitorId
                                        personId:(nullable NSString *)personId
                                       pageIndex:(nonnull NSNumber *)pageIndex;

@end
