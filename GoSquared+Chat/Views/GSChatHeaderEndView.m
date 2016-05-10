//
//  GSChatHeaderEndView.m
//  GoSquared
//
//  Created by Edward Wellbrook on 10/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatHeaderEndView.h"

@interface GSChatHeaderEndView ()

@property UILabel *label;

@end

@implementation GSChatHeaderEndView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.text = @"This is the begining of your conversation.";
        self.label.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:self.label];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:-4]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.label.text = text;
}

@end
