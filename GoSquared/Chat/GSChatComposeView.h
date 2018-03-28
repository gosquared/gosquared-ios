//
//  GSChatComposeView.h
//  GoSquared
//
//  Created by Edward Wellbrook on 27/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSChatComposeTextView.h"
#import "GSChatComposeViewDelegate.h"

@interface GSChatComposeView : UIView <UITextViewDelegate>

@property id<GSChatComposeViewDelegate> composeViewDelegate;

- (void)beginEditing;
- (void)endEditing;

@end
