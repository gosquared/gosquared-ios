//
//  GSChatViewController.h
//  GoSquared
//
//  Created by Edward Wellbrook on 21/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSTracker.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString * const GSUnreadMessageNotification;
extern NSString * const GSUnreadMessageNotificationCount;

extern NSString * const GSMessageNotification;
extern NSString * const GSMessageNotificationBody;
extern NSString * const GSMessageNotificationAuthor;
extern NSString * const GSMessageNotificationAvatar;
NS_ASSUME_NONNULL_END

@interface GSChatViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/// The number of unread messages in the current tracked user's chat
@property (readonly) NSUInteger numberOfUnreadMessages;

/// If YES the client will fetch the latest JS every time, regardless of version
/// (this is only recommended useful for debugging / testing)
@property BOOL forceUpdate;

/**
 Initialise a new GSChatViewController with your a GSTracker instance.

 @param tracker A valid GSTracker instance

 @return New GSChatViewController which responds to GSTracker changes
 */
- (nonnull instancetype)initWithTracker:(nonnull GSTracker *)tracker;

/**
 Loads Chat and opens a connection to the GoSquared service to listen for incoming
 messages. This is called automatically if needed on presenting the GSChatViewController
  */
- (void)openConnection;

/**
 Forces the WebView to reload with the latest cached chat.js
 */
- (void)forceReload;

@end
