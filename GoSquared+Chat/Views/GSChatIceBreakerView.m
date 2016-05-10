//
//  GSChatIceBreakerView.m
//  GoSquared
//
//  Created by Edward Wellbrook on 08/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatIceBreakerView.h"

@interface GSChatIceBreakerView ()

@property UITextView *messageTextView;

@end

@implementation GSChatIceBreakerView

+ (instancetype)iceBreakerViewWithMessage:(NSString *)message
{
    GSChatIceBreakerView *iceBreaker = [[GSChatIceBreakerView alloc] initWithFrame:CGRectZero];
    iceBreaker.message = message;

    return iceBreaker;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.messageTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        self.messageTextView.textAlignment = NSTextAlignmentCenter;
        self.messageTextView.scrollEnabled = NO;
        self.messageTextView.backgroundColor = [UIColor clearColor];
        self.messageTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.messageTextView.textColor = [UIColor colorWithWhite:0 alpha:.6];
        self.messageTextView.selectable = NO;
        self.messageTextView.editable = NO;
        self.messageTextView.translatesAutoresizingMaskIntoConstraints = NO;

        [self addSubview:self.messageTextView];

        NSDictionary *views = @{ @"message": self.messageTextView };

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[message]-30-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:views]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.messageTextView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
    }
    return self;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    self.messageTextView.text = message;
}

@end
