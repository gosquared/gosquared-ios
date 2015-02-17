//
//  GSEvent.h
//  GoSquared-iOS-Native
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSEvent : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSDictionary *properties;

+ (GSEvent *)eventWithName:(NSString *)name;
- (NSDictionary *)serialize;

@end
