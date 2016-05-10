//
//  GSChatHeaderLoadingView.m
//  GoSquared
//
//  Created by Edward Wellbrook on 04/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatHeaderLoadingView.h"

@interface GSChatHeaderLoadingView ()

@property UIActivityIndicatorView *spinner;

@end

@implementation GSChatHeaderLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.spinner.translatesAutoresizingMaskIntoConstraints = NO;

        [self.spinner startAnimating];

        [self addSubview:self.spinner];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.spinner
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
    }
    return self;
}

@end
