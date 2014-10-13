//
//  GSRequest.m
//  GoSquared-iOS-Native
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//

#import "GSRequest.h"

#import <UIKit/UIKit.h>

const float kGSRequestDefaultTimeout = 20.0f;

static NSString *staticUserAgent = nil;

@interface GSRequest () <NSURLConnectionDelegate>

@property enum GSRequestMethod method;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSDictionary *body;

@property (strong, nonatomic) NSMutableData *responseData;

@end

@implementation GSRequest {
    NSMutableURLRequest *request;
    NSURLConnection *connection;
}

+ (GSRequest *)requestWithMethod:(enum GSRequestMethod)method url:(NSURL *)url body:(NSDictionary *)body {
    GSRequest *r = [[GSRequest alloc] init];
    
    if(r) {
        r.method = method;
        r.url = url;
        r.body = body;
    }
    
    return r;
}

- (NSString *)description {
    NSString *methodStr = [self methodString];
    
    return [NSString stringWithFormat:@"GSRequest: %p\nMethod: %@\nURL: %@\nBody: %@", self, methodStr, self.url, self.body];
}

- (NSString *)methodString {
    switch(self.method) {
        case GSRequestMethodPUT:
            return @"PUT";
            break;
        case GSRequestMethodPOST:
            return @"POST";
            break;
        case GSRequestMethodDELETE:
            return @"DELETE";
            break;
            
        default:
            return @"GET";
    }
}

- (void)send {
    request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kGSRequestDefaultTimeout];
    [request setHTTPMethod:[self methodString]];
    
    if(staticUserAgent == nil) {
        NSArray *versionComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
                                      
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        
        NSString *appNameStr = [info objectForKey:@"CFBundleName"];
        NSString *appVersionStr = [info objectForKey:@"CFBundleShortVersionString"];
        NSString *idiomStr = @"iPhone";
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) idiomStr = @"iPad";
        NSString *iOSVersionStr = [versionComponents componentsJoinedByString:@"_"];
        
        staticUserAgent = [NSString stringWithFormat:@"%@/%@ (%@; CPU iPhone OS %@ like Mac OS X)", appNameStr, appVersionStr, idiomStr, iOSVersionStr];
    }
    
    [request setValue:staticUserAgent forHTTPHeaderField:@"User-Agent"];
    
    if(self.body) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.body
                                                           options:kNilOptions
                                                             error:&error];
        
        if (!jsonData) {
            NSLog(@"GSRequest - error serialising body params to json: %@", error);
        } else {
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:jsonData];
        }
    }
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)finished {
    connection = nil;
    request = nil;
}


#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // ignore for now
    
    self.responseData = [[NSMutableData alloc]init];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // ignore for now
    [self.responseData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // ignore for now
    NSLog(@"GSRequest::didFailWithError - %@", error);
    
    [self finished];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // ignore for now
    
#ifdef DEBUG
    NSString *string = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    NSLog(@"GSRequest received responseData: \n%@", string);
#endif
    
    [self finished];
}

@end
