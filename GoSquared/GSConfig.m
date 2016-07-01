//
//  GSConfig.m
//  Pods
//
//  Created by Edward Wellbrook on 01/07/2016.
//
//

#import "GSConfig.h"

static NSString * const kGSVisitorIdKey                = @"com.gosquared.visitor_id";
static NSString * const kGSPeoplePersonIdKey           = @"com.gosquared.people.id";
static NSString * const kGSPeoplePersonNameKey         = @"com.gosquared.people.name";
static NSString * const kGSPeoplePersonEmailKey        = @"com.gosquared.people.email";
static NSString * const kGSPageviewLastTimestampKey    = @"com.gosquared.pageview.last";
static NSString * const kGSPageviewReturningKey        = @"com.gosquared.pageview.returning";
static NSString * const kGSTransactionLastTimestampKey = @"com.gosquared.transaction.last";

@implementation GSConfig

+ (NSString *)visitorIdForToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSVisitorIdKey, token];
    NSString *visitorId = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    if (visitorId == nil) {
        visitorId = [GSConfig generatePersistedUUIDforKey:key];
    }

    return visitorId;
}

+ (NSString *)personIdForToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonIdKey, token];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (NSString *)personNameForToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonNameKey, token];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (NSString *)personEmailForToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonEmailKey, token];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (NSNumber *)lastPageviewTimestampForToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPageviewLastTimestampKey, token];
    NSNumber *timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    if (timestamp == nil) {
        timestamp = @0;
    }

    return timestamp;
}

+ (NSNumber *)lastTransactionTimestampForToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSTransactionLastTimestampKey, token];
    NSNumber *timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    if (timestamp == nil) {
        timestamp = @0;
    }

    return timestamp;
}

+ (BOOL)isReturningForToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPageviewReturningKey, token];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (void)setPersonId:(NSString *)personId forToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonIdKey, token];
    [[NSUserDefaults standardUserDefaults] setObject:personId forKey:key];
}

+ (void)setPersonName:(NSString *)name forToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonNameKey, token];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:key];
}

+ (void)setPersonEmail:(NSString *)email forToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonEmailKey, token];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:key];
}

+ (void)setLastPageviewTimestamp:(NSNumber *)timestamp forToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPageviewLastTimestampKey, token];
    [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:key];
}

+ (void)setLastTransactionTimestamp:(NSNumber *)timestamp forToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSTransactionLastTimestampKey, token];
    [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:key];
}

+ (void)setReturning:(BOOL)isReturning forToken:(NSString *)token
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPageviewReturningKey, token];
    [[NSUserDefaults standardUserDefaults] setBool:isReturning forKey:key];
}

+ (NSString *)generatePersistedUUIDforKey:(NSString *)key
{
    NSString *UUID = [[NSUUID alloc] init].UUIDString;
    [[NSUserDefaults standardUserDefaults] setObject:UUID forKey:key];
    return UUID;
}

@end
