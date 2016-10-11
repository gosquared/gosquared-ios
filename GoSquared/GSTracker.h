//
//  GSTracker.h
//  GoSquared
//
//  Created by Giles Williams on 12/10/2014.
//  Copyright (c) 2014 Urban Massage. All rights reserved.
//  Copyright (c) 2015-2016 Go Squared Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSTypes.h"
#import "GSTransaction.h"
#import "GSTransactionItem.h"

#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(args)
#endif

/**
 Provides methods for interacting with the GoSquared API. Manages state and
 request handling.
 */
@interface GSTracker : NSObject

/// Your project token.
@property (nonatomic, nullable) NSString *token;

/// Your API key.
@property (nullable) NSString *key;

/// Your generated secret to be used for generating a signature for an identified user
@property (nullable) NSString *secret;

/// The signature for the identified user, usually passed from your an authenticated server
@property (nonatomic, nullable) NSString *signature;

/// Allow pinging to continue when your app is in a background state. Useful for
/// apps which can run in the background (e.g. a podcast app). Defaults to NO.
@property (nonatomic) BOOL shouldTrackInBackground;

/// The verbosity of logging for the SDK. Defaults to Quiet.
@property GSLogLevel logLevel;

/// GoSquared's internal identifier for the current user.
@property (readonly, nullable) NSString *visitorId;

/// Your own identifier for the current user.
@property (readonly, nullable) NSString *personId;

/// YES if the current user has been identified with your own person id.
@property (readonly, getter=isIdentified) BOOL identified;
@property (readonly, nullable) NSDictionary *currentPageviewData;


/**
 Initialise a new GSTracker with your project token and API key.
 
 @param token Your project token
 @param key Your API key

 @return New GSTracker configured with your token and API key
 */
- (nonnull instancetype)initWithToken:(nonnull NSString *)token key:(nonnull NSString *)key;

/**
 Assert that a project token and API key have been set.

 @warning This method will cause your app to crash if credentials have not been
          correctly set. Use should be avoided in production apps.
 */
- (void)assertCredentialsSet;

/// ---------------------
/// @name Chat
/// ---------------------

/**
 Get the current version of the cached JS chat code.
 */
+ (nonnull NSString *)chatVersion;

/**
 Prepares the necessary base files and moves them to the documents directory
 */
+ (void)prepareDocumentsDirectory;

/**
 Gets the most recent available version number for the JS chat
 
 @param completionHandler The block to be executed with the fetched version string
 */
+ (void)checkAvailableChatVersionWithCompletionHandler:(nonnull void (^)(NSString * _Nullable version))completionHandler;

/**
 Downloads the specified JS chat version and stores it in the correct location.
 
 @param version The version to update to
 */
+ (void)updateChatClientWithVersion:(nonnull NSString *)version;

/**
 Downloads a specified JS and stores it in the correct location.
 
 @param urlString           The url download
 @param completionHandler   Called on a successful update
 */
+ (void)updateChatClientWithUrlString:(nonnull NSString *)urlString completionHandler:(nullable void (^)())completionHandler;



/// ---------------------
/// @name Event analytics
/// ---------------------

/**
 Track an event with a given event name.

 @param name The name of the event being tracked
 */
- (void)trackEventWithName:(nonnull NSString *)name NS_SWIFT_NAME(trackEvent(name:));

/**
 Track an event with a given event name and optionally additional event properties.
 
 @param name The name of the event being tracked
 @param properties Additional properties for the event being tracked
 */
- (void)trackEventWithName:(nonnull NSString *)name properties:(nullable GSPropertyDictionary *)properties NS_SWIFT_NAME(trackEvent(name:properties:));


/// --------------------------
/// @name Navigation analytics
/// --------------------------

/**
 Track an app screen with a given name.
 
 @param title The title of the screen being tracked
 */
- (void)trackScreenWithTitle:(nullable NSString *)title NS_SWIFT_NAME(trackScreen(title:));

/**
 Track an app screen with a given name and optionally a path to group screens by.
 
 @param title The title of the screen being tracked
 @param path An optional path for the screen to be grouped by
 */
- (void)trackScreenWithTitle:(nullable NSString *)title path:(nullable NSString *)path NS_SWIFT_NAME(trackScreen(title:path:));


/// --------------------------
/// @name People configuration
/// --------------------------

/**
 Identify the current user with properties (e.g. id, name, email, etc.)
 
 @param properties A dictonary of properties about the current user
 
 @warning For the identify to be valid, there must be either a value for "id" or "email" in the properties dictionary
 */
- (void)identifyWithProperties:(nonnull GSPropertyDictionary *)properties NS_SWIFT_NAME(identify(properties:));

/**
 Reset the saved properties for the current user.
 */
- (void)unidentify;


/// -------------------------
/// @name Ecommerce analytics
/// -------------------------

/**
 Track an ecommerce transaction.
 
 @param transaction A prebuilt GSTransaction object to track
 */
- (void)trackTransaction:(nonnull GSTransaction *)transaction;

/**
 Track an ecommerce transaction with an id, and items.
 
 @param transactionId A unique id for the transaction being tracked
 @param items An array of GSTransactionItems for the transaction being tracked
 */
- (void)trackTransactionWithId:(nonnull NSString *)transactionId items:(nonnull NSArray<GSTransactionItem *> *)items NS_SWIFT_NAME(trackTransaction(id:items:));

/**
 Track an ecommerce transaction with an id, items and optionally additional properties/
 
 @param transactionId A unique id for the transaction being tracked
 @param items An array of GSTransactionItems for the transaction being tracked
 @param properties An optional NSDictionary of properties for the transaction bring tracked
 */
- (void)trackTransactionWithId:(nonnull NSString *)transactionId items:(nonnull NSArray<GSTransactionItem *> *)items properties:(nullable GSPropertyDictionary *)properties NS_SWIFT_NAME(trackTransaction(id:items:properties:));

@end
