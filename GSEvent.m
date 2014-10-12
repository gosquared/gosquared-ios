//
//  GSEvent.m
//  GoSquaredTester
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 MCNGoSquaredTester. All rights reserved.
//

#import "GSEvent.h"

@implementation GSEvent {
    
}

@synthesize name = _name;
@synthesize properties = _properties;

+ (GSEvent *)eventWithName:(NSString *)name {
    GSEvent *e = [[GSEvent alloc] init];
    
    if(e) {
        [e setName:name];
    }
        
    return e;
}

- (void)setName:(NSString *)name {
    _name = name;
}

- (NSString *)name {
    return _name;
}

- (void)setProperties:(NSDictionary *)properties {
    _properties = properties;
}

- (NSDictionary *)properties {
    return _properties;
}

@end
