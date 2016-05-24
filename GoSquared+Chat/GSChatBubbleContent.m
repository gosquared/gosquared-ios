//
//  GSChatBubbleContent.m
//  GoSquared
//
//  Created by Edward Wellbrook on 16/02/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatBubbleContent.h"

@interface GSChatBubbleContent()

@end

@implementation GSChatBubbleContent

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.layer.opaque = YES;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;

        self.textContainerInset = UIEdgeInsetsMake(10, 8, 10, 8);
        self.editable = NO;
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        self.userInteractionEnabled = NO;
        self.linkTextAttributes = @{ NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle) };
        self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    return self;
}

// TODO: refactor this mess
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    static float bigRadius = 8;
    static float smallRadius = 3;

    CGPoint topLeft = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint topRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGPoint bottomRight = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGPoint bottomLeft = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));

    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(topLeft.x + bigRadius, topLeft.y)];

    [path addLineToPoint:CGPointMake(topRight.x - bigRadius, topLeft.y)];
    [path addArcWithCenter:CGPointMake(topRight.x - bigRadius, topLeft.y + bigRadius) radius:bigRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];

    if (self.tailFacesRight) {
        [path addLineToPoint:CGPointMake(bottomRight.x, bottomRight.y - smallRadius)];
        [path addArcWithCenter:CGPointMake(bottomRight.x - smallRadius, bottomRight.y - smallRadius) radius:smallRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];

        [path addLineToPoint:CGPointMake(bottomLeft.x + bigRadius, bottomRight.y)];
        [path addArcWithCenter:CGPointMake(bottomLeft.x + bigRadius, bottomLeft.y - bigRadius) radius:bigRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    } else {
        [path addLineToPoint:CGPointMake(bottomRight.x, bottomRight.y - bigRadius)];
        [path addArcWithCenter:CGPointMake(bottomRight.x - bigRadius, bottomRight.y - bigRadius) radius:bigRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];

        [path addLineToPoint:CGPointMake(bottomLeft.x + smallRadius, bottomRight.y)];
        [path addArcWithCenter:CGPointMake(bottomLeft.x + smallRadius, bottomLeft.y - smallRadius) radius:smallRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    }

    [path addLineToPoint:CGPointMake(topLeft.x, topLeft.y + bigRadius)];
    [path addArcWithCenter:CGPointMake(topLeft.x + bigRadius, topLeft.y + bigRadius) radius:bigRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];

    [path closePath];

    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.path = path.CGPath;

    self.layer.mask = mask;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return ((UITapGestureRecognizer *)gestureRecognizer).numberOfTapsRequired != 2;
    }

    CGPoint point = [gestureRecognizer locationInView:self];
    point.y -= self.textContainerInset.top;

    NSUInteger idx = [self.layoutManager characterIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:nil];

    // attr will be non-null if idx is within a link
    NSString *attr = [self.attributedText attribute:NSLinkAttributeName atIndex:idx effectiveRange:nil];

    BOOL isLongPressWithLink = ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && attr != nil);
    isLongPressWithLink = YES;

    return ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] || isLongPressWithLink);
}

@end
