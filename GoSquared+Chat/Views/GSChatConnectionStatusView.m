//
//  GSChatConnectionIndicator.m
//  GoSquared
//
//  Created by Edward Wellbrook on 28/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatConnectionStatusView.h"
#import "UIColor+GoSquared.h"

@interface GSChatConnectionStatusView()

@property UILabel *statusLabel;

@end

@implementation GSChatConnectionStatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.statusLabel = [[UILabel alloc] initWithFrame:self.frame];
        self.statusLabel.textAlignment = NSTextAlignmentCenter;
        self.statusLabel.textColor = [UIColor whiteColor];
        self.statusLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCallout];
        self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self addSubview:self.statusLabel];
        [self didChageConnectionStatus:GSChatConnectionStatusLoading];
    }
    return self;
}

- (void)didChageConnectionStatus:(GSChatConnectionStatus)status
{
    self.connectionStatus = status;

    BOOL shouldDisappearAfterDisplay = NO;

    switch (self.connectionStatus) {
        case GSChatConnectionStatusLoading:
            self.backgroundColor = [UIColor gs_connectivityLoadingColor];
            self.statusLabel.text = @"Connecting";
            break;
        case GSChatConnectionStatusConnected:
            self.backgroundColor = [UIColor gs_connectivityConnectedColor];
            self.statusLabel.text = @"Connected";
            shouldDisappearAfterDisplay = YES;
            break;
        case GSChatConnectionStatusDisconnected:
            self.backgroundColor = [UIColor gs_connectivityDisconnectedColor];
            self.statusLabel.text = @"Disconnected";
            break;
        default:
            break;
    }

    self.statusLabel.frame = self.bounds;

//    [self showConnectionStatusAndHide:shouldDisappearAfterDisplay];
}

- (void)showConnectionStatusAndHide:(BOOL)shouldHide
{
    self.layer.opacity = 1;

    [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) {
        if (finished && shouldHide) {
            [self hideConnectionStatus];
        }
    }];
}

- (void)hideConnectionStatus
{
    self.transform = CGAffineTransformMakeTranslation(0, 0);

    [UIView animateWithDuration:0.35 delay:2.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -self.frame.size.height);
        self.layer.opacity = 0;
    } completion:nil];
}

@end
