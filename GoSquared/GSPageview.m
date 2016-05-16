//
//  GSPageview.m
//  GoSquared
//
//  Created by Ed Wellbrook 16/05/2016.
//  Copyright (c) 2016 Go Squared Ltd. All rights reserved.
//

#import "GSPageview.h"

@implementation GSPageview

+ (NSDictionary *)generateBodyForPingWithTitle:(NSString *)title
                                           URL:(NSString *)URL
                                        device:(GSDevice *)device
                                     visitorId:(NSString *)visitorId
                                      personId:(NSString *)personId
                                     pageIndex:(NSNumber *)pageIndex
                                trackerVersion:(NSString *)trackerVersion
{
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"visitor_id": visitorId,
                                                                                @"page": @{ @"index": pageIndex },
                                                                                @"user_agent": device.userAgent,
                                                                                @"engaged_time": @0,
                                                                                @"document": @{
                                                                                        @"height": device.screenHeight,
                                                                                        @"width": device.screenWidth
                                                                                        },
                                                                                @"viewport": @{
                                                                                        @"height": device.screenHeight,
                                                                                        @"width": device.screenWidth
                                                                                        },
                                                                                @"scroll": @{
                                                                                        @"top": @0,
                                                                                        @"left": @0
                                                                                        },
                                                                                @"tracker_version": trackerVersion
                                                                                }];


    if (personId != nil) {
        body[@"person_id"] = personId;
    }

    return [NSDictionary dictionaryWithDictionary:body];
}

+ (NSDictionary *)generateBodyForPageviewWithTitle:(NSString *)title
                                               URL:(NSString *)URL
                                            device:(GSDevice *)device
                                         visitorId:(NSString *)visitorId
                                          personId:(NSString *)personId
                                         pageIndex:(NSNumber *)pageIndex
                                      lastPageview:(NSNumber *)lastPageview
                                         returning:(BOOL)returning
                                    trackerVersion:(NSString *)trackerVersion
{
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"timestamp": @([NSDate new].timeIntervalSince1970),
                                                                                @"visitor_id": visitorId,
                                                                                @"page": @{
                                                                                        @"url": URL,
                                                                                        @"title": [NSString stringWithFormat:@"%@: %@", device.os, title],
                                                                                        @"previous": pageIndex
                                                                                        },
                                                                                @"character_set": @"UTF-8",
                                                                                @"ip": @"detect",
                                                                                @"language": device.isoLanguage,
                                                                                @"user_agent": device.userAgent,
                                                                                @"returning": @(returning),
                                                                                @"engaged_time": @0,
                                                                                @"screen": @{
                                                                                        @"height": device.screenHeight,
                                                                                        @"width": device.screenWidth,
                                                                                        @"pixel_ratio": device.screenPixelRatio,
                                                                                        @"depth": device.colorDepth,
                                                                                        },
                                                                                @"document": @{
                                                                                        @"height": device.screenHeight,
                                                                                        @"width": device.screenWidth
                                                                                        },
                                                                                @"viewport": @{
                                                                                        @"height": device.screenHeight,
                                                                                        @"width": device.screenWidth
                                                                                        },
                                                                                @"scroll": @{
                                                                                        @"top": @0,
                                                                                        @"left": @0
                                                                                        },
                                                                                @"location": @{
                                                                                        @"timezone_offset": device.timezoneOffset
                                                                                        },
                                                                                @"tracker_version": trackerVersion,
                                                                                @"last_pageview": lastPageview
                                                                                }];


    if (personId != nil) {
        body[@"person_id"] = personId;
    }

    return [NSDictionary dictionaryWithDictionary:body];
}

@end
