//
//  GSChatViewLayout.h
//  GoSquared
//
//  Created by Edward Wellbrook on 02/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSChatViewLayoutDelegate <NSObject>

- (BOOL)messageIsOwnAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface GSChatViewLayout : UICollectionViewFlowLayout

@property (weak) id<GSChatViewLayoutDelegate> chatLayoutDelegate;

@end
