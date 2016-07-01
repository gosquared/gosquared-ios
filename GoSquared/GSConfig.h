//
//  GSConfig.h
//  Pods
//
//  Created by Edward Wellbrook on 01/07/2016.
//
//

#import <Foundation/Foundation.h>

@interface GSConfig : NSObject

+ (nonnull NSString *)visitorIdForToken:(nonnull NSString *)token;
+ (nullable NSString *)personIdForToken:(nonnull NSString *)token;
+ (nullable NSString *)personNameForToken:(nonnull NSString *)token;
+ (nullable NSString *)personEmailForToken:(nonnull NSString *)token;
+ (nonnull NSNumber *)lastPageviewTimestampForToken:(nonnull NSString *)token;
+ (nonnull NSNumber *)lastTransactionTimestampForToken:(nonnull NSString *)token;
+ (BOOL)isReturningForToken:(nonnull NSString *)token;

+ (void)setPersonId:(nullable NSString *)personId forToken:(nonnull NSString *)token;
+ (void)setPersonName:(nullable NSString *)name forToken:(nonnull NSString *)token;
+ (void)setPersonEmail:(nullable NSString *)email forToken:(nonnull NSString *)token;
+ (void)setLastPageviewTimestamp:(nonnull NSNumber *)timestamp forToken:(nonnull NSString *)token;
+ (void)setLastTransactionTimestamp:(nonnull NSNumber *)timestamp forToken:(nonnull NSString *)token;
+ (void)setReturning:(BOOL)isReturning forToken:(nonnull NSString *)token;

@end
