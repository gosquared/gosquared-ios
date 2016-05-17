//
//  GSDevice.m
//  GoSquared
//
//  Created by Giles Williams on 15/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GSDevice.h"

static NSString * const kGSUDIDDefaultsKey = @"com.gosquared.defaults.device.UDID";

@implementation GSDevice

+ (instancetype)currentDevice
{
    static GSDevice *currentDevice = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        currentDevice = [[GSDevice alloc] init];
    });
    return currentDevice;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        // screen
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.screenHeight = [NSNumber numberWithFloat:screenRect.size.height];
        self.screenWidth = [NSNumber numberWithFloat:screenRect.size.width];
        self.screenPixelRatio = [NSNumber numberWithFloat:[UIScreen mainScreen].scale];
        self.colorDepth = @24;

        // device ID
        self.udid = [self deviceIdentifier];

        // timezone
        NSDate *date = [NSDate new];
        NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
        NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

        NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:date];
        NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
        NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
        self.timezoneOffset = [NSNumber numberWithLongLong:(gmtInterval / 60)*-1];

        NSLocale *l = [NSLocale currentLocale];

        // language
        self.isoLanguage = [[[l objectForKey:NSLocaleIdentifier] lowercaseString] stringByReplacingOccurrencesOfString:@"_" withString:@"-"];

        // user agent
        NSArray *versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];

        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];

        NSString *appNameStr = [info objectForKey:@"CFBundleName"];
        NSString *appVersionStr = [info objectForKey:@"CFBundleShortVersionString"];

        NSString *osVersionStr = [versionComponents componentsJoinedByString:@"_"];

        #if TARGET_OS_TV
            NSString *deviceType = @"Apple TV";
            self.os = @"tvOS";
        #else
            NSString *deviceType = [[UIDevice currentDevice].model componentsSeparatedByString:@" "][0];
            self.os = @"iOS";
        #endif

        self.userAgent = [NSString stringWithFormat:@"%@/%@ (%@; CPU OS %@ like Mac OS X)", appNameStr, appVersionStr, deviceType, osVersionStr];
    }

    return self;
}

- (NSString *)deviceIdentifier
{
    NSString *deviceIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kGSUDIDDefaultsKey];

    if (deviceIdentifier == nil) {
        deviceIdentifier = [[NSUUID alloc] init].UUIDString;

        [[NSUserDefaults standardUserDefaults] setObject:deviceIdentifier forKey:kGSUDIDDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return deviceIdentifier;
}

@end
