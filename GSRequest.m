//
//  GSRequest.m
//  GoSquaredTester
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 MCNGoSquaredTester. All rights reserved.
//

#import "GSRequest.h"

@interface GSRequest ()

@property enum GSRequestMethod method;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSDictionary *body;

@end

@implementation GSRequest

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
    NSString *methodStr = nil;
    
    switch(self.method) {
        case GSRequestMethodGET:
            methodStr = @"GET";
            break;
        case GSRequestMethodPUT:
            methodStr = @"PUT";
            break;
        case GSRequestMethodPOST:
            methodStr = @"POST";
            break;
        case GSRequestMethodDELETE:
            methodStr = @"DELETE";
            break;
            
        default:
            methodStr = @"<unknown>";
    }
    
    return [NSString stringWithFormat:@"GSRequest: %p\nMethod: %@\nURL: %@\nBody: %@", self, methodStr, self.url, self.body];
}

@end
