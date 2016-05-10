//
//  GSTracker+Chat.h
//  GoSquared
//
//  Created by Edward Wellbrook on 07/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import <GoSquared/GoSquared.h>

@interface GSTracker (Chat)

@property (nonnull) NSString *secret;

- (nonnull NSString *)signature;
- (void)setSignature:(nonnull NSString *)signature;

@end
