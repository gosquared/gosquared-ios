//
//  GSDevice.m
//  GoSquaredTester
//
//  Created by Giles Williams on 15/10/2014.
//  Copyright (c) 2014 MCNGoSquaredTester. All rights reserved.
//

#import "GSDevice.h"

#import <UIKit/UIKit.h>

static NSString * const kGSUDIDDefaultsKey = @"com.gosquared.defaults.device.UDID";

static GSDevice *currentGSDevice = nil;

@implementation GSDevice

+ (GSDevice *)currentDevice {
    if(currentGSDevice == nil) {
        currentGSDevice = [[GSDevice alloc] init];
    }
    
    return currentGSDevice;
}

- (GSDevice *)init {
    self = [super init];
    
    if(self) {
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
    }
    
    return self;
}

- (NSString *)deviceIdentifier {
    NSString *deviceIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:kGSUDIDDefaultsKey];
    
    if(deviceIdentifier == nil) {
        deviceIdentifier = [self createUUID];
        
        [[NSUserDefaults standardUserDefaults] setObject:deviceIdentifier forKey:kGSUDIDDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return deviceIdentifier;
}

- (NSString *)createUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}


@end
