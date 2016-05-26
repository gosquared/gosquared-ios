//
//  GSChatIceBreakerView.h
//  GoSquared
//
//  Created by Edward Wellbrook on 08/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSChatIceBreakerView : UIView

@property (nonnull, nonatomic) NSString *message;

+ (nonnull instancetype)iceBreakerViewWithMessage:(nonnull NSString *)message;

@end
