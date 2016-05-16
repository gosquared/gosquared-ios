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

+ (nonnull NSDictionary *)generateBodyForPingWithTitle:(nonnull NSString *)title
                                                   URL:(nonnull NSString *)URL
                                                device:(nonnull GSDevice *)device
                                             visitorId:(nonnull NSString *)visitorId
                                              personId:(nullable NSString *)personId
                                             pageIndex:(nonnull NSNumber *)pageIndex
                                        trackerVersion:(nonnull NSString *)trackerVersion;

+ (nonnull NSDictionary *)generateBodyForPageviewWithTitle:(nonnull NSString *)title
                                                       URL:(nonnull NSString *)URL
                                                    device:(nonnull GSDevice *)device
                                                 visitorId:(nonnull NSString *)visitorId
                                                  personId:(nullable NSString *)personId
                                                 pageIndex:(nonnull NSNumber *)pageIndex
                                              lastPageview:(nullable NSNumber *)lastPageview
                                                 returning:(BOOL)returning
                                            trackerVersion:(nonnull NSString *)trackerVersion;

@end
