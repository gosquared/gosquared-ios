//
//  GSTypes.h
//  GoSquared
//
//  Created by Edward Wellbrook on 09/05/16.
//  Copyright (c) 2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Verbosity level for logging
typedef NS_ENUM(NSInteger, GSLogLevel) {

    /// Only log errors
    GSLogLevelSilent,

    /// Log high level SDK actions
    GSLogLevelQuiet,

    /// Log detailed implmentation level SDK actions
    GSLogLevelDebug
};

/// String: id dictionary for additional properties in methods
typedef NSDictionary<NSString *, id> GSPropertyDictionary;
