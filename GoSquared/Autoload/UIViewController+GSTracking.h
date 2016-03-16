//
//  UIViewController+GSTracking.h
//  GoSquared
//
//  Created by Giles Williams on 16/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (GSTracking)

@property (readwrite) BOOL doNotTrack;
@property (readwrite) NSString *trackingTitle;

@end
