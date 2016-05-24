//
//  GSChatComposeView.m
//  GoSquared
//
//  Created by Edward Wellbrook on 27/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatComposeView.h"
#import "GSChatComposeTextView.h"

@interface GSChatComposeView()

@property GSChatComposeTextView *textView;
@property UIButton *sendButton;
@property NSLayoutConstraint *heightConstraint;

@end

@implementation GSChatComposeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.textView = [[GSChatComposeTextView alloc] initWithFrame:CGRectZero];
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];

        [self addSubview:self.textView];

        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self.sendButton.titleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold]];
        [self addSubview:self.sendButton];

        [self setConstraints];
        [self.sendButton.titleLabel sizeToFit];

        [self.textView setDelegate:self];
        [self textViewDidChange:self.textView];
    }
    return self;
}

- (void)setConstraints
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.sendButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSDictionary *metrics = @{ @"h_spacer": @10, @"v_spacer": @5 };
    NSDictionary *views = @{ @"input": self.textView, @"button": self.sendButton };

    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1
                                                          constant:self.frame.size.height];

    [self addConstraint:self.heightConstraint];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(h_spacer)-[input]-(h_spacer)-[button]-(h_spacer)-|"
                                                                 options:NSLayoutFormatAlignAllBottom
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(v_spacer)-[input]-(v_spacer)-|"
                                                                 options:NSLayoutFormatAlignAllBottom
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button]-(v_spacer)-|"
                                                                 options:NSLayoutFormatAlignAllBottom
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)sendMessage:(id)sender
{
    if (self.composeViewDelegate != nil) {
        BOOL shouldBecomeFirstResponder = self.textView.isFirstResponder;

        [self.textView resignFirstResponder];
        NSString *message = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.composeViewDelegate didSendMessage:message];

        if (shouldBecomeFirstResponder) {
            [self.textView becomeFirstResponder];
        }
    }

    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    [self.textView setText:@""];
    [self.textView textChanged:nil];

    [self textViewDidChange:self.textView];
}

- (void)endEditing
{
    [self.textView endEditing:YES];
    [self.textView resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.composeViewDelegate didEndEditing];
}


#pragma mark UITextViewDelegate methods

- (NSArray *)keyCommands
{
    UIKeyCommand *cmdEnter = [UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:UIKeyModifierCommand action:@selector(sendMessage:)];
    return @[ cmdEnter ];
}

- (void)textViewDidChange:(GSChatComposeTextView *)textView
{
    [self.sendButton setEnabled:[textView hasUsableText]];

    [self.heightConstraint setConstant: MIN([textView heightForContents] + 11, 120)];
    [textView layoutIfNeeded];

    if ([self.composeViewDelegate respondsToSelector:@selector(didEditText)]) {
        [self.composeViewDelegate didEditText];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.composeViewDelegate respondsToSelector:@selector(didBeginEditing)]) {
        [self.composeViewDelegate didBeginEditing];
    }
}


@end
