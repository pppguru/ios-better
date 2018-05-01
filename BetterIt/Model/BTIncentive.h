//
//  BTIncentive.h
//  BetterIt
//
//  Created by Maikel on 3/23/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTObject.h"

@interface BTIncentive : BTObject

@property (copy, nonatomic, readonly) NSString *couponCode;
@property (copy, nonatomic, readonly) NSString *couponDescription;
@property (copy, nonatomic, readonly) NSDate *expiryDate;
@property (copy, nonatomic, readonly) NSDate *usedDate;
@property (assign, nonatomic) BOOL used;

- (id)initWithCouponCode:(NSString *)couponCode Description:(NSString *)description ExpiryDate:(NSDate *)expiryDate;
- (NSString *)expiryDateString;

//- (NSDictionary *)plist;
@end
