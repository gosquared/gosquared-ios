//
//  GoSquared.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSTracker.h"
#import "GSTypes.h"
#import "GSTransaction.h"
#import "GSTransactionItem.h"

@interface GoSquared : NSObject

+ (nonnull GSTracker *)sharedTracker;

@end
