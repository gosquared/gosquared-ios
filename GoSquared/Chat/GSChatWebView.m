//
//  GSChatWebView.m
//  Pods
//
//  Created by Edward Wellbrook on 09/08/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatWebView.h"
#import <WebKit/WKWebsiteDataStore.h>
#import <objc/runtime.h>

BOOL _gs__canBecomeFirstResponder(id self, SEL _cmd)
{
    return NO;
}

@implementation GSChatWebView

+ (void)clearStorage {
    if ([WKWebsiteDataStore class] != nil) {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[
                                                        WKWebsiteDataTypeLocalStorage,
                                                        WKWebsiteDataTypeCookies,
                                                        WKWebsiteDataTypeSessionStorage
                                                        ]];
        
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        
        }];
    } else {
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self disableContentGestures];
}

- (void)disableContentGestures
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView *contentView;

        // find web page content view
        for (UIView *view in self.scrollView.subviews) {
            if ([view.class.description hasPrefix:@"WKContent"]) {
                contentView = view;
            }
        }

        // replace canBecomeFirstResponder with our own method that always returns NO
        Method original = class_getInstanceMethod([contentView class], @selector(canBecomeFirstResponder));
        method_setImplementation(original, (IMP)_gs__canBecomeFirstResponder);
    });
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;
}

@end
