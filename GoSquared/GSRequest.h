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

/**
 The available HTTP method types for a GSRequest
 */
typedef NS_ENUM(NSInteger, GSRequestMethod) {

    /// HTTP GET method
    GSRequestMethodGET,

    /// HTTP PUT method
    GSRequestMethodPUT,

    /// HTTP POST method
    GSRequestMethodPOST,

    /// HTTP DELETE method
    GSRequestMethodDELETE
};

/**
 The signature for a GSRequest completion block
 */
typedef void (^GSRequestCompletionBlock)(NSDictionary  * _Nullable data, NSError * _Nullable error);


/**
 Wrapper around NSURLRequest for API requests
 */
@interface GSRequest : NSObject

/// The verbosity level of log for the request
@property GSLogLevel logLevel;

/**
 Create and return a new GSRequest with given config
 
 @param method HTTP method to use for the request
 @param path The path to the API endpoint for the request
 @param body Optional HTTP request body for POST/PUT requests
 
 @return The new GSRequest
 */
+ (nonnull instancetype)requestWithMethod:(GSRequestMethod)method path:(nonnull NSString *)path body:(nullable NSDictionary *)body;

/**
 Perform the request with a completion handler
 
 @param completionHandler Block to handle the response from the HTTP request
 */
- (void)sendWithCompletionHandler:(nullable GSRequestCompletionBlock)completionHandler;

@end
