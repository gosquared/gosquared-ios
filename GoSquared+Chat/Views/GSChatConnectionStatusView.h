//
//  GSChatConnectionIndicator.h
//  GoSquared
//
//  Created by Edward Wellbrook on 28/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GSChatConnectionStatus) {
    GSChatConnectionStatusLoading,
    GSChatConnectionStatusConnected,
    GSChatConnectionStatusDisconnected
};

@interface GSChatConnectionStatusView : UIView

@property GSChatConnectionStatus connectionStatus;

- (void)didChageConnectionStatus:(GSChatConnectionStatus)status;

@end
