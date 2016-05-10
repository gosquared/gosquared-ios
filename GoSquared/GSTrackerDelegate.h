//
//  GSTrackerDelegate.h
//  GoSquared
//
//  Created by Edward Wellbrook on 10/05/2016.
//  Copyright (c) 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GSTrackerDelegate <NSObject>

- (void)didIdentifyPerson;
- (void)didUnidentifyPerson;

@end
