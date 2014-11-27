//
//  UIViewController+GSTracking.h
//  GoSquaredTester
//
//  Created by Giles Williams on 16/10/2014.
//  Copyright (c) 2014 MCNGoSquaredTester. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (GSTracking)

@property (readwrite) BOOL doNotTrack;
@property (readwrite) NSString *trackingTitle;

@end
