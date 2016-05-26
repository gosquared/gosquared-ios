//
//  GSChatComposeTextView.h
//  GoSquared
//
//  Created by Edward Wellbrook on 25/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GSChatViewController.h"

@interface GSChatComposeTextView : UITextView <UITextViewDelegate>

- (void)textChanged:(NSNotification *)notification;
- (CGFloat)heightForContents;
- (BOOL)hasUsableText;

@end
