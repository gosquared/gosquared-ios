//
//  UIColor+GoSquared.m
//  GoSquared
//
//  Created by Edward Wellbrook on 24/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "UIColor+GoSquared.h"

@implementation UIColor (GoSquared)

+ (UIColor *)gs_ChatBubbleSelfColor
{
    return [[UIColor alloc] initWithHue:.569444444 saturation:.26 brightness:.58 alpha:1];
}

+ (UIColor *)gs_lightGrayColor
{
    return [[UIColor alloc] initWithHue:.555555556 saturation:.03 brightness:.92 alpha:1];
}

+ (UIColor *)gs_connectivityLoadingColor
{
    return [[UIColor alloc] initWithHue:0 saturation:0 brightness:.85 alpha:.96];
}

+ (UIColor *)gs_connectivityConnectedColor
{
    return [[UIColor alloc] initWithHue:.247222222 saturation:.85 brightness:.85 alpha:.96];
}

+ (UIColor *)gs_connectivityDisconnectedColor
{
    return [[UIColor alloc] initWithHue:.980555556 saturation:.85 brightness:.85 alpha:.96];
}

@end
