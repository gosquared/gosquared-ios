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
        self.layer.cornerRadius = 4;
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
