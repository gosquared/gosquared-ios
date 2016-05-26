//
//  ChatBubbleCell.m
//  GoSquared
//
//  Created by Edward Wellbrook on 22/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatBubbleCell.h"
#import "UIColor+GoSquared.h"
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>


@interface GSChatViewController ()

- (void)didRequestContextForMessageCell:(nonnull GSChatBubbleCell *)cell;

@end


@interface GSChatBubbleCell ()

@property UITapGestureRecognizer *tapRecogniser;

@end

@implementation GSChatBubbleCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentTextView = [[GSChatBubbleContent alloc] initWithFrame:CGRectZero];
        self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        
        self.avatarImageView.layer.cornerRadius = 16;
        self.avatarImageView.clipsToBounds = YES;

        self.backgroundColor = [UIColor gs_lightGrayColor];

        self.layer.opaque = YES;
        self.layer.shouldRasterize = YES;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;

        self.tapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:self.tapRecogniser];

        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.contentTextView];
        [self.contentView bringSubviewToFront:self.contentTextView];
    }
    return self;
}

- (void)setMessage:(GSChatMessage *)message
{
    _message = message;

    self.contentTextView.text = message.content;

    if (self.message.sender == GSChatSenderClient) {
        self.contentTextView.textColor = [UIColor whiteColor];
        self.contentTextView.tintColor = [UIColor whiteColor];
        self.contentTextView.backgroundColor = [UIColor gs_ChatBubbleSelfColor];
        self.contentTextView.tailFacesRight = YES;
        self.avatarImageView.frame = CGRectZero;
    } else {
        if (message.avatar) {
            [self.avatarImageView pin_setImageFromURL:message.avatar];
        }
        self.avatarImageView.frame = CGRectMake(-36, self.bounds.size.height - 32, 32, 32);

        self.contentTextView.textColor = [UIColor blackColor];
        self.contentTextView.tintColor = [UIColor gs_ChatBubbleSelfColor];
        self.contentTextView.backgroundColor = [UIColor whiteColor];
        self.contentTextView.tailFacesRight = NO;
    }

    if (self.message.failed) {
        UIColor *color = [UIColor gs_connectivityDisconnectedColor];
        [self.contentTextView setBackgroundColor:[color colorWithAlphaComponent:0.5]];
    } else if (self.message.pending) {
        UIColor *color = self.contentTextView.backgroundColor;
        [self.contentTextView setBackgroundColor:[color colorWithAlphaComponent:0.5]];
    }

    self.contentTextView.frame = self.bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.contentTextView.frame = self.bounds;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    if (self.message.failed) {
        [self.delegate didRequestContextForMessageCell:self];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];

    CGFloat hue = 0;
    CGFloat sat = 0;
    CGFloat bri = 0;
    CGFloat alp = 0;

    [self.contentTextView.backgroundColor getHue:&hue saturation:&sat brightness:&bri alpha:&alp];

    if (selected) {
        self.contentTextView.backgroundColor = [UIColor colorWithHue:hue saturation:sat brightness:bri - .15 alpha:alp];
    } else {
        self.contentTextView.backgroundColor = [UIColor colorWithHue:hue saturation:sat brightness:bri + .15 alpha:alp];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.avatarImageView.frame = CGRectZero;
}

@end
