//
//  GSChatViewController.h
//  GoSquared
//
//  Created by Edward Wellbrook on 21/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSTracker+Chat.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString * const GSUnreadMessageNotification;
extern NSString * const GSUnreadMessageNotificationCount;

extern NSString * const GSMessageNotification;
extern NSString * const GSMessageNotificationBody;
extern NSString * const GSMessageNotificationAuthor;
extern NSString * const GSMessageNotificationAvatar;
NS_ASSUME_NONNULL_END

@interface GSChatViewController : UICollectionViewController

@property (readonly) NSUInteger numberOfUnreadMessages;

- (nonnull instancetype)initWithTracker:(nonnull GSTracker *)tracker;
- (void)openConnection;
- (void)closeConnection;

@end
