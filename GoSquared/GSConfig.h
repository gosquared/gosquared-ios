//
//  GSConfig.h
//  Pods
//
//  Created by Edward Wellbrook on 01/07/2016.
//
//

#import <Foundation/Foundation.h>

@interface GSConfig : NSObject

@property (nonnull) NSString *token;
@property (nonnull, readonly, nonatomic) NSString *visitorId;
@property (nullable, nonatomic) NSString *personId;
@property (nullable, nonatomic) NSString *personName;
@property (nullable, nonatomic) NSString *personEmail;
@property (nonnull, nonatomic) NSNumber *lastPageviewTimestamp;
@property (nonnull, nonatomic) NSNumber *lastTransactionTimestamp;
@property (nonatomic, getter=isReturning) BOOL returning;

- (nonnull instancetype)initWithToken:(nonnull NSString *)token;
- (void)regenerateVisitorId;

@end
