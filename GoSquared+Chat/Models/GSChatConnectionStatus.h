//
//  GSChatConnectionStatus.h
//  GoSquared
//
//  Created by Edward Wellbrook on 20/05/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GSChatConnectionStatus) {
    GSChatConnectionStatusLoading,
    GSChatConnectionStatusConnected,
    GSChatConnectionStatusDisconnected
};
