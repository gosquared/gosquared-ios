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


typedef void (^GSRequestBlock)(BOOL success, NSData * _Nullable data);

@interface GSRequest : NSObject

@property GSRequestLogLevel logLevel;

+ (nonnull instancetype)requestWithMethod:(GSRequestMethod)method path:(nonnull NSString *)path body:(nullable NSDictionary *)body;

- (void)send;
- (void)sendWithCompletionHandler:(nullable GSRequestBlock)completionHandler;

@end
