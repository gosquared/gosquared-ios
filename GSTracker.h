//
//  GSTracker.h
//  GoSquaredTester
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 MCNGoSquaredTester. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSEvent;

@interface GSTracker : NSObject

+ (GSTracker *)sharedInstance;

- (void)setSiteToken:(NSString *)siteToken;

// tracking
- (void)trackEvent:(GSEvent *)event;
- (void)trackScreenView:(NSString *)screenName;

// people
- (void)identify:(NSString *)userID;
- (void)identify:(NSString *)userID properties:(NSDictionary *)properties;
- (void)unidentify;

@end
