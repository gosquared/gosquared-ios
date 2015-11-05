//
//  GoSquared.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015 Go Squared Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GSTransaction.h"
#import "GSTransactionItem.h"
#import "GSTrackerEvent.h"
#import "GSTracker.h"

@interface GoSquared : NSObject

+ (GSTracker *)sharedTracker;

@end
