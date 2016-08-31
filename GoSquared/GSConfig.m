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

- (instancetype)initWithToken:(NSString *)token
{
    self = [super init];
    if (self) {
        self.token = token;
    }
    return self;
}

- (NSString *)visitorId
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSVisitorIdKey, self.token];
    NSString *visitorId = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    if (visitorId == nil) {
        visitorId = [GSConfig generatePersistedUUIDforKey:key];
    }

    return visitorId;
}

- (NSString *)personId
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonIdKey, self.token];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setPersonId:(NSString *)personId
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonIdKey, self.token];
    [[NSUserDefaults standardUserDefaults] setObject:personId forKey:key];
}

- (NSString *)personName
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonNameKey, self.token];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setPersonName:(NSString *)name
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonNameKey, self.token];
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:key];
}

- (NSString *)personEmail
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonEmailKey, self.token];
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setPersonEmail:(NSString *)email
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPeoplePersonEmailKey, self.token];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:key];
}

- (NSNumber *)lastPageviewTimestamp
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPageviewLastTimestampKey, self.token];
    NSNumber *timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    if (timestamp == nil) {
        timestamp = @0;
    }

    return timestamp;
}

- (void)setLastPageviewTimestamp:(NSNumber *)timestamp
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPageviewLastTimestampKey, self.token];
    [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:key];
}

- (NSNumber *)lastTransactionTimestamp
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSTransactionLastTimestampKey, self.token];
    NSNumber *timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    if (timestamp == nil) {
        timestamp = @0;
    }

    return timestamp;
}

- (void)setLastTransactionTimestamp:(NSNumber *)timestamp
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSTransactionLastTimestampKey, self.token];
    [[NSUserDefaults standardUserDefaults] setObject:timestamp forKey:key];
}

- (BOOL)returning
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPageviewReturningKey, self.token];
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

- (void)setReturning:(BOOL)returning
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSPageviewReturningKey, self.token];
    [[NSUserDefaults standardUserDefaults] setBool:returning forKey:key];
}

+ (NSString *)generatePersistedUUIDforKey:(NSString *)key
{
    NSString *UUID = [[NSUUID alloc] init].UUIDString;
    [[NSUserDefaults standardUserDefaults] setObject:UUID forKey:key];
    return UUID;
}

- (nonnull NSString *)generateVisitorId
{
    NSString *key = [NSString stringWithFormat:@"%@.%@", kGSVisitorIdKey, self.token];
    [GSConfig generatePersistedUUIDforKey:key];
}

@end
