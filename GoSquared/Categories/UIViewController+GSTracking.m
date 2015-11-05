//
//  UIViewController+GSTracking.m
//  GoSquared
//
//  Created by Giles Williams on 16/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <objc/runtime.h>

#import "UIViewController+GSTracking.h"

#import <UIKit/UIKit.h>

#import "GoSquared.h"

static char const * const kGSDoNotTrackViewControllerTag = "kGSDoNotTrackViewControllerTag";
static char const * const kGSTrackingTitleViewControllerTag = "kGSTrackingTitleViewControllerTag";

@implementation UIViewController (GSTracking)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        // swizzle viewDidAppear
        SEL originalVDASelector = @selector(viewDidAppear:);
        SEL swizzledVDASelector = @selector(_gs__viewDidAppear:);

        Method originalVDAMethod = class_getInstanceMethod(class, originalVDASelector);
        Method swizzledVDAMethod = class_getInstanceMethod(class, swizzledVDASelector);

        BOOL didAddVDAMethod =
        class_addMethod(class,
                        originalVDASelector,
                        method_getImplementation(swizzledVDAMethod),
                        method_getTypeEncoding(swizzledVDAMethod));

        if (didAddVDAMethod) {
            class_replaceMethod(class,
                                swizzledVDASelector,
                                method_getImplementation(originalVDAMethod),
                                method_getTypeEncoding(originalVDAMethod));
        } else {
            method_exchangeImplementations(originalVDAMethod, swizzledVDAMethod);
        }
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

    if(number == nil) return NO;

    return [number boolValue];
}

// allows you to override the title in ViewController.title
- (void)setTrackingTitle:(NSString *)trackingTitle
{
    objc_setAssociatedObject(self, kGSTrackingTitleViewControllerTag, trackingTitle, OBJC_ASSOCIATION_RETAIN);
}
- (NSString *)trackingTitle
{
    NSString *trackingTitle = objc_getAssociatedObject(self, kGSTrackingTitleViewControllerTag);

    return trackingTitle;
}


#pragma mark - Method Swizzling

- (void)_gs__viewDidAppear:(BOOL)animated {
    [self _gs__viewDidAppear:animated];

    if([self isKindOfClass:[UINavigationController class]]) {
        // don't track navigation controllers
        return;
    }

    if([self isKindOfClass:[UIPageViewController class]]) {
        // don't track page view controllers
        return;
    }

    if([[NSString stringWithFormat:@"%@", [self class]] isEqualToString:@"UIInputWindowController"]) {
        // don't track the keyboard
        return;
    }

    if([self doNotTrack] == YES) {
        // adhere to the doNotTrack property
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = self.title;
        NSString *trackingTitle = [self trackingTitle];
        if(trackingTitle != nil) {
            title = trackingTitle;
        }

        [[GoSquared sharedTracker] trackViewController:self withTitle:title];
    });
}

@end
