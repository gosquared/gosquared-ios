//
//  GSPageview.m
//  GoSquared
//
//  Created by Ed Wellbrook 16/05/2016.
//  Copyright (c) 2016 Go Squared Ltd. All rights reserved.
//

#import "GSPageview.h"

@implementation GSPageview

+ (instancetype)pageviewWithTitle:(NSString *)title URLString:(NSString *)URLString index:(NSNumber *)index
{
    GSPageview *pageview = [[GSPageview alloc] init];

    pageview.title = title;
    pageview.URLString = URLString;
    pageview.index = index;

    return pageview;
}

- (NSDictionary *)serializeForPingWithDevice:(GSDevice *)device
                                   visitorId:(NSString *)visitorId
                                    personId:(NSString *)personId
                                 engagedTime:(nonnull NSNumber *)engagedTime
                              trackerVersion:(NSString *)trackerVersion
{
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"visitor_id": visitorId,
                                                                                @"page": @{ @"index": self.index },
                                                                                @"user_agent": device.userAgent,
                                                                                @"engaged_time": engagedTime,
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

- (NSDictionary *)serializeWithDevice:(GSDevice *)device
                            visitorId:(NSString *)visitorId
                             personId:(NSString *)personId
                         lastPageview:(NSNumber *)lastPageview
                            returning:(BOOL)returning
                       trackerVersion:(NSString *)trackerVersion
{
    NSString *formattedTitle = [NSString stringWithFormat:@"%@: %@", device.os, self.title];

    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"timestamp": @([NSDate new].timeIntervalSince1970),
                                                                                @"visitor_id": visitorId,
                                                                                @"page": @{
                                                                                        @"title": formattedTitle,
                                                                                        @"url": self.URLString,
                                                                                        @"previous": self.index
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
