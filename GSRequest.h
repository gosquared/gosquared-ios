//
//  GSRequest.h
//  GoSquared-iOS-Native
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//

#import <Foundation/Foundation.h>

enum GSRequestMethod {
    GSRequestMethodGET,
    GSRequestMethodPUT,
    GSRequestMethodPOST,
    GSRequestMethodDELETE
};

@interface GSRequest : NSObject

+ (GSRequest *)requestWithMethod:(enum GSRequestMethod)method url:(NSURL *)url body:(NSDictionary *)body;

@end
