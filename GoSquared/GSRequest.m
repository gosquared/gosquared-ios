//
//  GSRequest.m
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import "GSRequest.h"
#import "GSDevice.h"

static NSMutableArray *GSRequestsInProgress;

const float kGSRequestDefaultTimeout = 20.0f;
static NSString * const kGSAPIBase = @"https://api.gosquared.com";


@interface GSRequest()

@property GSRequestMethod method;
@property NSURL *url;
@property NSDictionary *body;

@end

@implementation GSRequest

+ (void)addRequestRetain:(GSRequest *)req
{
    if (!GSRequestsInProgress) {
        GSRequestsInProgress = [[NSMutableArray alloc] init];
    }

    [GSRequestsInProgress addObject:req];
}

+ (void)clearRequestRetain:(GSRequest *)req
{
    if (GSRequestsInProgress) {
        [GSRequestsInProgress removeObject:req];
    }
}

+ (instancetype)requestWithMethod:(GSRequestMethod)method path:(NSString *)path body:(NSDictionary *)body
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kGSAPIBase, path]];
    return [GSRequest requestWithMethod:method URL:URL body:body];
}

+ (instancetype)requestWithMethod:(GSRequestMethod)method URL:(NSURL *)URL body:(NSDictionary *)body
{
    GSRequest *request = [[GSRequest alloc] init];

    if (request) {
        request.logLevel = GSLogLevelQuiet;
        request.method = method;
        request.url = URL;
        request.body = body;
    }
    return request;
}

- (NSString *)description
{
    NSString *methodStr = [self methodString];

    return [NSString stringWithFormat:@"GSRequest: %p\nMethod: %@\nURL: %@\nBody: %@", self, methodStr, self.url, self.body];
}

- (NSString *)methodString
{
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

- (NSURLRequest *)URLRequest
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:kGSRequestDefaultTimeout];

    [request setValue:[GSDevice currentDevice].userAgent forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:[self methodString]];

    if (self.body) {
        if (![NSJSONSerialization isValidJSONObject:self.body]) {
            return nil;
        }

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

- (void)send
{
    [self sendWithCompletionHandler:nil];
}

- (void)sendWithCompletionHandler:(GSRequestCompletionBlock)completionHandler
{
    NSURLRequest *request = [self URLRequest];

    if (request == nil) {
        if (completionHandler == nil) {
            return;
        } else {
            completionHandler(nil, [NSError errorWithDomain:@"com.gosquared" code:-1 userInfo:nil]);
        }
    }

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (completionHandler == nil) {
            return;
        }

        if (error) {
            return completionHandler(nil, error);
        }

        if (!data) {
            return completionHandler(nil, [NSError errorWithDomain:@"com.gosquared" code:-1 userInfo:nil]);
        }

        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        BOOL success = (HTTPResponse.statusCode >= 200 && HTTPResponse.statusCode < 400);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];

        if (error != nil) {
            return completionHandler(nil, error);
        } else if (success) {
            return completionHandler(json, nil);
        } else {
            return completionHandler(nil, [NSError errorWithDomain:@"com.gosquared" code:-1 userInfo:json]);
        }
    }];

    if (self.logLevel == GSLogLevelDebug) {
        NSLog(@"GSRequest::send - %@", self);
    } else if (self.logLevel == GSLogLevelQuiet) {
        NSLog(@"GSRequest sending data");
    }

    [task resume];
}

@end
