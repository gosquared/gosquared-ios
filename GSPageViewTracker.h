//
//  GSPageViewTracker.h
//  GoSquared-iOS-Native
//
//  Created by Giles Williams on 15/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSTracker;

@class UIViewController;

@interface GSPageViewTracker : NSObject

- (void)startWithURLString:(NSString *)urlString title:(NSString *)title;

- (BOOL)isValid;

@property (readonly) __weak UIViewController *currentlyTrackedViewController;

@end
