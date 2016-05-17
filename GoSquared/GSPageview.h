//
//  GSPageview.h
//  GoSquared
//
//  Created by Ed Wellbrook on 16/05/2016.
//  Copyright (c) 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSDevice.h"

@interface GSPageview : NSObject

@property (nonnull) NSString *title;
@property (nonnull) NSString *URLString;
@property (nonnull) NSNumber *index;

+ (nonnull instancetype)pageviewWithTitle:(nonnull NSString *)title
                                URLString:(nonnull NSString *)URLString
                                    index:(nonnull NSNumber *)index;

- (nonnull NSDictionary *)serializeForPingWithDevice:(nonnull GSDevice *)device
                                           visitorId:(nonnull NSString *)visitorId
                                            personId:(nullable NSString *)personId
                                         engagedTime:(nonnull NSNumber *)engagedTime
                                      trackerVersion:(nonnull NSString *)trackerVersion;

- (nonnull NSDictionary *)serializeWithDevice:(nonnull GSDevice *)device
                                    visitorId:(nonnull NSString *)visitorId
                                     personId:(nullable NSString *)personId
                                 lastPageview:(nullable NSNumber *)lastPageview
                                    returning:(BOOL)returning
                               trackerVersion:(nonnull NSString *)trackerVersion;

@end
