//
//  GSChatComposeTextView.m
//  GoSquared
//
//  Created by Edward Wellbrook on 25/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatComposeTextView.h"

@interface GSChatComposeTextView()

@property UILabel *placeholder;
@property UITextView *sizerView;

@end

IB_DESIGNABLE
@implementation GSChatComposeTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.sizerView = [[UITextView alloc] initWithFrame:frame];
        self.sizerView.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:self.bounds];
        placeholderLabel.text = @"Type a message...";

        self.textContainerInset = UIEdgeInsetsMake(8, 4, 8, 4);

        self.placeholder = placeholderLabel;
        self.placeholder.frame = CGRectInset(self.bounds, self.textContainerInset.left, self.textContainerInset.top);

        [self addSubview:self.placeholder];
        [self sendSubviewToBack:self.placeholder];

        self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.placeholder.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.placeholder.textColor = [UIColor lightGrayColor];
        self.backgroundColor = [UIColor whiteColor];
        self.showsHorizontalScrollIndicator = NO;

        self.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.cornerRadius = 5;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

- (NSString *)sizerText
{
    return self.sizerView.text;
}

- (void)setSizerText:(NSString *)sizerText
{
    self.sizerView.text = sizerText;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.placeholder.frame = CGRectInset(self.bounds, self.textContainerInset.left + 6, self.textContainerInset.top);
}

- (BOOL)hasUsableText
{
    NSString *contents = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (contents != nil && contents.length > 0);
}

- (void)textChanged:(NSNotification *)notification
{
    self.placeholder.hidden = [self hasText];
    self.sizerView.text = self.text;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    self.sizerView.font = self.font;
    self.sizerView.contentInset = self.contentInset;
    self.sizerView.textContainerInset = self.textContainerInset;
    self.sizerView.showsHorizontalScrollIndicator = self.showsHorizontalScrollIndicator;
    self.sizerView.scrollEnabled = self.scrollEnabled;

    return [self.sizerView sizeThatFits:size];
}

- (BOOL)canResignFirstResponder
{
    return YES;
}

@end
