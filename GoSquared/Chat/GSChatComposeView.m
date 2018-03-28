//
//  GSChatComposeView.m
//  GoSquared
//
//  Created by Edward Wellbrook on 27/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatComposeView.h"
#import "GSChatComposeTextView.h"

static const CGFloat MAX_INPUT_HEIGHT = 120;

@interface GSChatComposeView()

@property (nonatomic) UIView *hairlineView;
@property GSChatComposeTextView *textView;
@property UIButton *sendButton;
@property UIButton *uploadButton;
@property BOOL uploadButtonHidden;
@property NSLayoutConstraint *heightConstraint;

@end

@implementation GSChatComposeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.textView = [[GSChatComposeTextView alloc] initWithFrame:CGRectZero];
        self.uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];


        NSString* photoAccessAllowed = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"NSPhotoLibraryUsageDescription"];
        BOOL photoPlistEntryRequired = [[UIDevice currentDevice].systemVersion compare:@"10" options:NSNumericSearch] != NSOrderedAscending;

        // Check for NSPhotoLibraryUsageDescription which is required from iOS 10 onwards for images access
        if (photoPlistEntryRequired && photoAccessAllowed == nil) {
            NSLog(@"GoSquared Chat: NSPhotoLibraryUsageDescription must be set in iOS 10+ to allow image uploads to chat");
            self.uploadButtonHidden = true;
            self.uploadButton.hidden = true;
        }

        NSBundle *podBundle = [NSBundle bundleForClass:self.class];
        NSURL *bundlePath = [podBundle URLForResource:@"GSChatEmbed" withExtension:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithURL:bundlePath];

        UIImage *camera = [UIImage imageNamed:@"camera" inBundle:bundle compatibleWithTraitCollection:nil];
        [self.uploadButton setImage:camera forState:UIControlStateNormal];
        [self.uploadButton addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];

        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self.sendButton.titleLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightSemibold]];

        [self addSubview:self.textView];
        [self addSubview:self.uploadButton];
        [self addSubview:self.sendButton];
        [self addSubview:self.hairlineView];

        [self setConstraints];
        self.textView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
        self.textView.delegate = self;

        self.backgroundColor = [UIColor whiteColor];

        [self textViewDidChange:self.textView];
    }
    return self;
}

- (void)setConstraints
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.uploadButton.translatesAutoresizingMaskIntoConstraints = NO;

    NSDictionary *metrics = @{ @"spacer": @10, @"vspacer": @5 };
    NSDictionary *views = @{ @"input": self.textView, @"send": self.sendButton, @"upload": self.uploadButton };

    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1
                                                          constant:self.frame.size.height];

    [self removeConstraints: self.constraints];

    [self addConstraint:self.heightConstraint];

    NSString *horizontalLayoutString = [NSString stringWithFormat:@"H:|%@-(spacer)-[input]-(spacer)-[send]-(spacer)-|", self.uploadButtonHidden ? @"" : @"-(spacer)-[upload]"];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalLayoutString
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(vspacer)-[input]-(vspacer)-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[send]-(7)-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:metrics
                                                                   views:views]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[upload]-(5)-|"
                                                                 options:NSLayoutFormatDirectionLeadingToTrailing
                                                                 metrics:metrics
                                                                   views:views]];


    [self addConstraint:[NSLayoutConstraint
                                      constraintWithItem:self.uploadButton
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.uploadButton
                                      attribute:NSLayoutAttributeHeight
                                      multiplier:1
                                      constant:0]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat height = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)].height + 10;

    if (height > MAX_INPUT_HEIGHT) {
        height = MAX_INPUT_HEIGHT;
    }

    self.heightConstraint.constant = height;
}

- (UIView *)hairlineView
{
    if (!_hairlineView) {
        _hairlineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, 0.5)];
        _hairlineView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        _hairlineView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    return _hairlineView;
}

- (void)sendMessage:(id)sender
{
    [self.textView setSelectedRange:NSMakeRange(0, 0)];

    NSString *message = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.composeViewDelegate didSendMessage:message];

    [self.textView setText:@""];
    [self.textView textChanged:nil];

    [self textViewDidChange:self.textView];
}

- (void)upload:(id)sender
{
    if ([self.composeViewDelegate respondsToSelector:@selector(didRequestUpload)]) {
        [self.composeViewDelegate didRequestUpload];
    }
}

- (void)beginEditing
{
    [self.textView becomeFirstResponder];
}

- (void)endEditing
{
    [self.textView endEditing:YES];
    [self.textView resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.composeViewDelegate respondsToSelector:@selector(didEndEditing)]) {
        [self.composeViewDelegate didEndEditing];
    }
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
    [self layoutSubviews];

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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    self.textView.sizerText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    [self layoutSubviews];

    return YES;
}

@end
