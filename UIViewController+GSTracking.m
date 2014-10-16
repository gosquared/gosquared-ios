//
//  UIViewController+GSTracking.m
//  GoSquaredTester
//
//  Created by Giles Williams on 16/10/2014.
//  Copyright (c) 2014 MCNGoSquaredTester. All rights reserved.
//

#import <objc/runtime.h>

#import "UIViewController+GSTracking.h"

#import <UIKit/UIKit.h>

#import "GoSquared.h"

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
        /*
        // swizzle viewWillDisappear
        SEL originalVWDSelector = @selector(viewWillDisappear:);
        SEL swizzledVWDSelector = @selector(_gs__viewWillDisappear:);
        
        Method originalVWDMethod = class_getInstanceMethod(class, originalVWDSelector);
        Method swizzledVWDMethod = class_getInstanceMethod(class, swizzledVWDSelector);
        
        BOOL didAddVWDMethod =
        class_addMethod(class,
                        originalVWDSelector,
                        method_getImplementation(swizzledVWDMethod),
                        method_getTypeEncoding(swizzledVWDMethod));
        
        if (didAddVWDMethod) {
            class_replaceMethod(class,
                                swizzledVWDSelector,
                                method_getImplementation(originalVWDMethod),
                                method_getTypeEncoding(originalVWDMethod));
        } else {
            method_exchangeImplementations(originalVWDMethod, swizzledVWDMethod);
        }*/
    });
}

#pragma mark - Method Swizzling

- (void)_gs__viewDidAppear:(BOOL)animated {
    [self _gs__viewDidAppear:animated];
    
    if([self isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    if([[NSString stringWithFormat:@"%@", [self class]] isEqualToString:@"UIInputWindowController"]) {
        return;
    }
    
    NSLog(@"viewDidAppear: %@ - %@", self.title, [self class]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GSTracker sharedInstance] trackViewController:self];
    });
    
}
/*
- (void)_gs__viewWillDisappear:(BOOL)animated {
    [self _gs__viewWillDisappear:animated];
    
    NSLog(@"viewWillDissapear: %@", self);
    
    [[GSTracker sharedInstance] trackViewController:self];
}*/

@end
