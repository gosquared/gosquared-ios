//
//  GSPageViewTracker.h
//  GoSquared
//
//  Created by Giles Williams on 15/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSTracker;

@class UIViewController;

@interface GSPageViewTracker : NSObject

- (id)initWithTracker:(GSTracker *)tracker;
- (void)startWithURLString:(NSString *)urlString title:(NSString *)title;
- (BOOL)isValid;
- (NSNumber *)pageIndex;

@property (readonly) __weak UIViewController *currentlyTrackedViewController;

@end
