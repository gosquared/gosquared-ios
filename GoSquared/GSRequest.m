//
//  GSRequest.m
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import "GSRequest.h"
#import "GSDevice.h"

#import <UIKit/UIKit.h>

static NSMutableArray *GSRequestsInProgress;

const float kGSRequestDefaultTimeout = 20.0f;
static NSString * const kGSAPIBase = @"https://api.gosquared.com";

static NSString *staticUserAgent = nil;

@interface GSRequest()

@property GSRequestMethod method;
@property NSURL *url;
@property NSDictionary *body;
@property NSMutableURLRequest *request;

@end

@implementation GSRequest

+ (void)addRequestRetain:(GSRequest *)req {
    if (!GSRequestsInProgress) {
        GSRequestsInProgress = [[NSMutableArray alloc] init];
    }

    [GSRequestsInProgress addObject:req];
}

+ (void)clearRequestRetain:(GSRequest *)req {
    if (GSRequestsInProgress) {
        [GSRequestsInProgress removeObject:req];
    }
}

+ (instancetype)requestWithMethod:(GSRequestMethod)method path:(NSString *)path body:(NSDictionary *)body {
    GSRequest *request = [[GSRequest alloc] init];

    if (request) {
        request.logLevel = GSRequestLogLevelQuiet;
        request.method = method;
        request.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kGSAPIBase, path]];
        request.body = body;
    }
    return request;
}

- (NSString *)description {
    NSString *methodStr = [self methodString];

    return [NSString stringWithFormat:@"GSRequest: %p\nMethod: %@\nURL: %@\nBody: %@", self, methodStr, self.url, self.body];
}

- (NSString *)methodString {
    switch (self.method) {
        case GSRequestMethodPUT:
            return @"PUT";
        case GSRequestMethodPOST:
            return @"POST";
        case GSRequestMethodDELETE:
            return @"DELETE";
        default:
            return @"GET";
    }
}

- (NSURLRequest *)URLRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:kGSRequestDefaultTimeout];

    [request setValue:[GSDevice currentDevice].userAgent forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:[self methodString]];

    if (self.body) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.body options:kNilOptions error:&error];

        if (error != nil || !jsonData) {
            [NSException raise:@"Failed to encode request body" format: @"Failed to encode request body"];
        }

        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:jsonData];
    }

    return request;
}

- (void)send {
    [self sendWithCompletionHandler:nil];
}

- (void)sendWithCompletionHandler:(GSRequestBlock)completionHandler
{
    NSURLRequest *request = [self URLRequest];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;

        if (completionHandler == nil) {
            return;
        }

        if (error || !data) {
            return completionHandler(NO, data);
        }

        BOOL success = (HTTPResponse.statusCode > 200 && HTTPResponse.statusCode < 400);

        completionHandler(success, data);
    }];

    if (self.logLevel == GSRequestLogLevelDebug) {
        NSLog(@"GSRequest::send - %@", self);
    } else if (self.logLevel == GSRequestLogLevelQuiet) {
        NSLog(@"GSRequest sending data");
    }

    [task resume];
}

@end
