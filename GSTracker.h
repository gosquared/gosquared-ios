//
//  GSTracker.h
//  GoSquared-iOS-Native
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

@class GSEvent;
@class GSTransaction;
@class GSDevice;

@interface GSTracker : NSObject

@property (strong, nonatomic) NSString *siteToken;

@property (readonly) NSString *currentUserID;

+ (GSTracker *)sharedInstance;

- (void)setSiteToken:(NSString *)siteToken;

// event tracking
- (void)trackEvent:(GSEvent *)event;

// page view tracking - only used if not using the UIViewController+GSTracking category
- (void)trackViewController:(UIViewController *)vc;
- (void)trackViewController:(UIViewController *)vc withTitle:(NSString *)title;
- (void)trackViewController:(UIViewController *)vc withTitle:(NSString *)title urlPath:(NSString *)urlPath;

// people
- (void)identify:(NSString *)userID;
- (void)identify:(NSString *)userID properties:(NSDictionary *)properties;
- (void)unidentify;

// ecommerce
- (void)trackTransaction:(GSTransaction *)transaction;

@end
