//
//  GSRequest.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GSRequestMethod) {
    GSRequestMethodGET,
    GSRequestMethodPUT,
    GSRequestMethodPOST,
    GSRequestMethodDELETE
};

typedef NS_ENUM(NSInteger, GSRequestLogLevel) {
    GSRequestLogLevelSilent,
    GSRequestLogLevelQuiet,
    GSRequestLogLevelDebug
};


@class GSRequest;
typedef void (^GSRequestBlock)(BOOL success, GSRequest * _Nonnull req);

@interface GSRequest : NSObject

@property (nullable) NSHTTPURLResponse *response;
@property (nullable) NSMutableData *responseData;

@property GSRequestLogLevel logLevel;
@property BOOL success;

+ (nonnull instancetype)requestWithMethod:(GSRequestMethod)method path:(nonnull NSString *)path body:(nullable NSDictionary *)body;

- (void)send;
- (void)sendWithCompletionHandler:(nullable GSRequestBlock)completionHandler;

@end
