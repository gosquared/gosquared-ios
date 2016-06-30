//
//  GSRequest.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSTypes.h"

typedef NS_ENUM(NSInteger, GSRequestMethod) {
    GSRequestMethodGET,
    GSRequestMethodPUT,
    GSRequestMethodPOST,
    GSRequestMethodDELETE
};

typedef void (^GSRequestCompletionBlock)(NSDictionary  * _Nullable data, NSError * _Nullable error);


@interface GSRequest : NSObject

@property GSLogLevel logLevel;

+ (nonnull instancetype)requestWithMethod:(GSRequestMethod)method path:(nonnull NSString *)path body:(nullable NSDictionary *)body;
+ (nonnull instancetype)requestWithMethod:(GSRequestMethod)method URL:(nonnull NSURL *)URL body:(nullable NSDictionary *)body;

- (void)sendWithCompletionHandler:(nullable GSRequestCompletionBlock)completionHandler;

@end
