//
//  GSChatTitleView.m
//  GoSquared
//
//  Created by Edward Wellbrook on 28/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatTitleView.h"

@interface GSChatTitleView()

@property UILabel *titleLabel;
@property UILabel *subTitleLabel;

@end

@implementation GSChatTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];

        [self.titleLabel setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel sizeToFit];

        [self.subTitleLabel setText:@"Powered by GoSquared"];
        [self.subTitleLabel setFont:[UIFont systemFontOfSize:12]];
        [self.subTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.subTitleLabel setTextColor:[UIColor colorWithWhite:0 alpha:.6]];
        [self.subTitleLabel sizeToFit];

        [self addSubview:self.titleLabel];
        [self addSubview:self.subTitleLabel];

        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

        [self.titleLabel sizeToFit];
        [self.subTitleLabel sizeToFit];

        [self setConstraints];
        [self positionFrame];
    }
    return self;
}

- (void)setConstraints
{
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *metrics = @{ @"v_spacer": @2 };
    NSDictionary *views = @{ @"view": self, @"title": self.titleLabel, @"subtitle": self.subTitleLabel };

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title]|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subtitle]|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title][subtitle]|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)positionFrame
{
    CGRect rect = self.frame;
    rect.size = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    self.frame = rect;
}

- (void)setTitle:(NSString *)title
{
    _title = title;

    [self.titleLabel setText:title];
    [self positionFrame];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;

    self.titleLabel.textColor = titleColor;
    self.subTitleLabel.textColor = [titleColor colorWithAlphaComponent:0.6];
}

@end
