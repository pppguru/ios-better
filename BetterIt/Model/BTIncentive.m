//
//  BTIncentive.m
//  BetterIt
//
//  Created by Maikel on 3/23/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTIncentive.h"

@implementation BTIncentive

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"couponCode" : @"coupon_code",
              @"couponDescription" : @"description",
              @"expiryDate" : @"expiry_date",
              @"usedDate" : @"used_date",
              @"used" : @"used"
              }];
}

+ (NSValueTransformer *)expiryDateJSONTransformer {
    return [self dateTransformer];
}

+ (NSValueTransformer *)usedDateJSONTransformer {
    return [self dateTransformer];
}

+ (NSValueTransformer *)usedJSONTransformer {
    return [self numberTransformer];
}



#pragma mark - Initialize

- (id)initWithCouponCode:(NSString *)couponCode Description:(NSString *)description ExpiryDate:(NSDate *)expiryDate {
    self = [super init];
    if (self) {
        _couponCode = couponCode;
        _couponDescription = description;
        _expiryDate = expiryDate;
    }
    
    return self;
}

#pragma mark - Getter

- (NSString *)expiryDateString {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM dd YYYY";
    }
    
    return [dateFormatter stringFromDate:_expiryDate];
}

//- (NSDictionary *)plist {
//    return @{@"coupon_code" : _couponCode,
//             @"description" : _couponDescription,
//             @"expiry_date" : [[BTObject dateFormatter] stringFromDate:_expiryDate]};
//}
@end
