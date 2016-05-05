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

@interface GSRequest () <NSURLConnectionDelegate>

@property (nonatomic, copy) GSRequestBlock requestCB;

@property GSRequestMethod method;
@property NSURL *url;
@property NSDictionary *body;
@property NSMutableURLRequest *request;

@end

@implementation GSRequest {
    NSURLConnection *connection;
}

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

- (void)prepareRequest {
    self.request = [NSMutableURLRequest requestWithURL:self.url
                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:kGSRequestDefaultTimeout];

    [self.request setValue:[GSDevice currentDevice].userAgent forHTTPHeaderField:@"User-Agent"];
    [self.request setHTTPMethod:[self methodString]];

    if (self.body) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.body
                                                           options:kNilOptions
                                                             error:&error];

        if (error != nil || !jsonData) {
            NSLog(@"GSRequest - error serialising body params to json: %@", error);
        } else {

            if (self.logLevel == GSRequestLogLevelDebug) {
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"GSRequest body - %@", jsonStr);
            }

            [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [self.request setHTTPBody:jsonData];
        }
    }
}

- (void)sendWithCompletionHandler:(GSRequestBlock)completionHandler {

    if (self.logLevel == GSRequestLogLevelDebug) {
        NSLog(@"GSRequest::send - %@", self);
    } else if (self.logLevel == GSRequestLogLevelQuiet) {
        NSLog(@"GSRequest sending data");
    }

    [self prepareRequest];

    _requestCB = completionHandler;

    [GSRequest addRequestRetain:self];
    connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
}

- (void)send {
    [self sendWithCompletionHandler:nil];
}


- (void)sendSync {
    [self prepareRequest];

    NSError *error;
    NSURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:self.request returningResponse:&response error:&error];
    self.responseData = [NSMutableData dataWithData:responseData];
    self.response = (NSHTTPURLResponse *)response;

    if (self.logLevel == GSRequestLogLevelDebug) {
        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"GSRequest::sendSync response - %@", responseStr);
    } else if (self.logLevel == GSRequestLogLevelQuiet) {
        NSLog(@"GSRequest data sent");
    }

    return;
}

- (void)finished {
    [GSRequest clearRequestRetain:self];

    if (_requestCB == nil) return;

    _requestCB(self.success, self);
}


#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = (NSHTTPURLResponse *)response;

    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"GSRequest::didFailWithError - %@", error);

    [self finished];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.logLevel == GSRequestLogLevelDebug) {
        NSString *string = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"GSRequest received responseData: \n%@", string);
    } else if (self.logLevel == GSRequestLogLevelQuiet) {
        NSLog(@"GSRequest data sent");
    }

    // ignore for now

    NSArray *errorCodes = [NSArray arrayWithObjects:@400, @401, @402, @404, @409, @500, nil];
    self.success = ![errorCodes containsObject:[NSNumber numberWithInteger:[self.response statusCode]]];

    [self finished];
}

@end
