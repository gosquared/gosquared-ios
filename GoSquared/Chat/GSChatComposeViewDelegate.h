//
//  GSChatComposeViewDelegate.h
//  GoSquared
//
//  Created by Edward Wellbrook on 18/08/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GSChatComposeViewDelegate <NSObject>

@optional
- (void)didSendMessage:(NSString *)message;
- (void)didRequestUpload;
- (void)didBeginEditing;
- (void)didEditText;
- (void)didEndEditing;

@end
