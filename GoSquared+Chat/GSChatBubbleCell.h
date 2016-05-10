//
//  ChatBubbleCell.h
//  GoSquared
//
//  Created by Edward Wellbrook on 22/01/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSChatMessage.h"
#import "GSChatBubbleContent.h"
#import "GSChatViewController.h"

@interface GSChatBubbleCell : UICollectionViewCell

@property UIImageView *avatarImageView;
@property (nonatomic) GSChatBubbleContent *contentTextView;
@property (nonatomic) GSChatMessage *message;
@property (weak) GSChatViewController *delegate;
@property BOOL isOwn;

@end
