//
//  UIViewController+Chat.h
//  GoSquared
//
//  Created by Edward Wellbrook on 08/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSChatPresentableViewController <NSObject>

- (void)gs_presentChatViewController;
- (void)gs_presentChatViewController:(nullable id)sender;

@end

@interface UIViewController (Chat) <GSChatPresentableViewController>

@end
