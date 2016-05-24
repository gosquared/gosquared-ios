//
//  GSChatComposeView.h
//  GoSquared
//
//  Created by Edward Wellbrook on 27/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSChatComposeViewDelegate <NSObject>

- (void)didSendMessage:(NSString *)message;

@optional
- (void)didBeginEditing;
- (void)didEditText;
- (void)didEndEditing;

@end


@interface GSChatComposeView : UIToolbar <UITextViewDelegate>

@property id<GSChatComposeViewDelegate> composeViewDelegate;

- (void)endEditing;

@end
