//
//  GSDevice.h
//  GoSquared
//
//  Created by Giles Williams on 15/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSDevice : NSObject

@property (retain) NSString *udid;
@property (retain) NSNumber *screenHeight;
@property (retain) NSNumber *screenWidth;
@property (retain) NSNumber *screenPixelRatio;
@property (retain) NSNumber *colorDepth;
@property (retain) NSNumber *timezoneOffset;
@property (retain) NSString *isoLanguage;
@property (retain) NSString *userAgent;

+ (GSDevice *)currentDevice;

@end
