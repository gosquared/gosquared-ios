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

@property NSString *udid;
@property NSNumber *screenHeight;
@property NSNumber *screenWidth;
@property NSNumber *screenPixelRatio;
@property NSNumber *colorDepth;
@property NSNumber *timezoneOffset;
@property NSString *isoLanguage;
@property NSString *userAgent;

+ (GSDevice *)currentDevice;

@end
