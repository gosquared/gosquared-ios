//
//  GSChatViewController.h
//  GoSquared
//
//  Created by Edward Wellbrook on 21/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSTracker+Chat.h"

// get rid of all of these
@class GSChatBubbleCell;

NS_ASSUME_NONNULL_BEGIN
extern NSString * const GSUnreadMessageNotification;
extern NSString * const GSUnreadMessageNotificationCount;
NS_ASSUME_NONNULL_END

@interface GSChatViewController : UICollectionViewController

@property (nonnull, readonly) NSNumber *unreadMessageCount;

- (nonnull instancetype)initWithTracker:(nonnull GSTracker *)tracker;
- (void)didRequestContextForMessageCell:(nonnull GSChatBubbleCell *)cell;
- (void)openConnection;
- (void)closeConnection;

@end
