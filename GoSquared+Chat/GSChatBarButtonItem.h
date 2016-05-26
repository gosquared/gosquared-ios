//
//  GSChatBarButtonItem.h
//  GoSquared
//
//  Created by Edward Wellbrook on 07/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Chat.h"

@interface GSChatBarButtonItem : UIBarButtonItem

@property (nonnull) NSString *buttonText;

+ (nonnull instancetype)buttonWithTitle:(nonnull NSString *)title target:(nullable id<GSChatPresentableViewController>)target;

@end
