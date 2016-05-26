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

@end

IB_DESIGNABLE
@implementation GSChatComposeTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:self.bounds];
        placeholderLabel.text = @"Type a message...";

        self.placeholder = placeholderLabel;
        self.placeholder.frame = CGRectInset(self.bounds, 8, 0);

        [self addSubview:self.placeholder];
        [self sendSubviewToBack:self.placeholder];

        self.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.placeholder.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.placeholder.textColor = [UIColor lightGrayColor];

        [self setBackgroundColor:[UIColor clearColor]];
        [self setShowsHorizontalScrollIndicator:NO];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    self.placeholder.frame = CGRectInset(self.bounds, 8, 0);
}

- (BOOL)hasUsableText
{
    NSString *contents = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (contents != nil && contents.length > 0);
}

- (void)textChanged:(NSNotification *)notification
{
    self.placeholder.hidden = [self hasText];
}

- (CGFloat)heightForContents
{
    return [self sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)].height;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

@end
