//
//  GSEvent.h
//  GoSquaredTester
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 MCNGoSquaredTester. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSEvent : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSDictionary *properties;

+ (GSEvent *)eventWithName:(NSString *)name;

@end
