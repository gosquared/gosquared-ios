//
//  GSDevice.h
//  GoSquared
//
//  Created by Giles Williams on 15/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSDevice : NSObject

@property (nonnull) NSString *udid;
@property (nonnull) NSNumber *screenHeight;
@property (nonnull) NSNumber *screenWidth;
@property (nonnull) NSNumber *screenPixelRatio;
@property (nonnull) NSNumber *colorDepth;
@property (nonnull) NSNumber *timezoneOffset;
@property (nonnull) NSString *isoLanguage;
@property (nonnull) NSString *userAgent;
@property (nonnull) NSString *os;

+ (nonnull instancetype)currentDevice;

@end
