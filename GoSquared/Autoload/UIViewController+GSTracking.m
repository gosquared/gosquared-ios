//
//  UIViewController+GSTracking.m
//  GoSquared
//
//  Created by Giles Williams on 16/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "UIViewController+GSTracking.h"
#import "GoSquared.h"

static char const * const kGSDoNotTrackViewControllerTag = "kGSDoNotTrackViewControllerTag";
static char const * const kGSTrackingTitleViewControllerTag = "kGSTrackingTitleViewControllerTag";


#pragma mark - Method Swizzling

static IMP viewDidAppear_Imp;

void _gs__viewDidAppear(id self, SEL _cmd, bool animated)
{
    // call original viewDidAppear:
    ((void(*)(id,SEL,bool))viewDidAppear_Imp)(self, _cmd, animated);

    // don't track navigation controllers
    if ([self isKindOfClass:[UINavigationController class]]) return;

    // don't track page view controllers
    if ([self isKindOfClass:[UIPageViewController class]]) return;

    // don't track the keyboard
    if ([[NSString stringWithFormat:@"%@", [self class]] isEqualToString:@"UIInputWindowController"]) return;

    // adhere to the doNotTrack property
    if ([self doNotTrack] == YES) return;


    NSString *title = ((UIViewController *)self).title;
    NSString *trackingTitle = [self trackingTitle];

    if (trackingTitle != nil) {
        title = trackingTitle;
    }

    if (title != nil && [title isEqualToString:@""] == NO) {
        [[GoSquared sharedTracker] trackScreenWithTitle:title];
    } else if ([GoSquared sharedTracker].logLevel == GSLogLevelDebug) {
        NSLog(@"UIViewController+GSTracking: Not tracking view controller without title");
    }
}


@implementation UIViewController (GSTracking)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method original = class_getInstanceMethod([self class], @selector(viewDidAppear:));
        viewDidAppear_Imp = method_setImplementation(original, (IMP)_gs__viewDidAppear);
    });
}


#pragma mark - Associated objects

// allows you to not track a particular ViewController
- (void)setDoNotTrack:(BOOL)doNotTrack
{
    NSNumber *number = [NSNumber numberWithBool:doNotTrack];
    objc_setAssociatedObject(self, kGSDoNotTrackViewControllerTag, number, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)doNotTrack
{
    NSNumber *number = objc_getAssociatedObject(self, kGSDoNotTrackViewControllerTag);

    if (number == nil) return NO;

    return [number boolValue];
}

// allows you to override the title in ViewController.title
- (void)setTrackingTitle:(NSString *)trackingTitle
{
    objc_setAssociatedObject(self, kGSTrackingTitleViewControllerTag, trackingTitle, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)trackingTitle
{
    return objc_getAssociatedObject(self, kGSTrackingTitleViewControllerTag);
}

@end
