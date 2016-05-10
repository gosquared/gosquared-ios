//
//  GSTracker+Chat.m
//  GoSquared
//
//  Created by Edward Wellbrook on 07/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSTracker+Chat.h"
#import <CommonCrypto/CommonHMAC.h>
#import <objc/runtime.h>

NSString * const secretKey = @"com.gosquared.chat.secret";
NSString * const userSignature = @"com.gosqured.chat.signature";

@implementation GSTracker (Chat)

- (NSString *)secret
{
    return objc_getAssociatedObject(self, &secretKey);
}

- (void)setSecret:(NSString *)secret
{
    objc_setAssociatedObject(self, &secretKey, secret, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setSignature:(NSString *)signature
{
    objc_setAssociatedObject(self, &userSignature, signature, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)signature {
    NSString *sig = objc_getAssociatedObject(self, &userSignature);

    if (sig == nil) {
        NSData *secret = [self.secret dataUsingEncoding:NSUTF8StringEncoding];
        NSData *person = [self.personId dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];

        CCHmac(kCCHmacAlgSHA256, secret.bytes, secret.length, person.bytes, person.length, hash.mutableBytes);

        sig = [GSTracker hexStringWithData:hash];
    }
    return sig;
}

+ (NSString *)hexStringWithData:(NSData *)data
{
    NSUInteger capacity = data.length * 2;
    NSMutableString *sbuf = [NSMutableString stringWithCapacity:capacity];
    const unsigned char *buf = data.bytes;
    NSInteger i;
    for (i = 0; i < data.length; ++i) {
        [sbuf appendFormat:@"%02X", (unsigned int)buf[i]];
    }
    return [sbuf lowercaseString];
}

@end
