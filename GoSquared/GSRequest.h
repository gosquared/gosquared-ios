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
typedef void (^GSRequestBlock)(bool success, GSRequest *req);

@interface GSRequest : NSObject

@property (strong, nonatomic) NSHTTPURLResponse *response;
@property (strong, nonatomic) NSMutableData *responseData;

@property GSRequestLogLevel logLevel;
@property BOOL success;

+ (GSRequest *)requestWithMethod:(GSRequestMethod)method path:(NSString *)path body:(NSDictionary *)body;

- (void)sendWithCompletionHandler:(GSRequestBlock)cb;
- (void)send;
- (void)sendSync;

@end
