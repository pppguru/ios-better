//
//  BTSubscription.m
//  BetterIt
//
//  Created by Maikel on 3/23/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTSubscription.h"

@implementation BTSubscription

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"businessId" : @"business_id",
              @"customerToken" : @"stripe_customer_token",
              @"subscriptionId" : @"stripe_subscription_id",
              @"subscriptionPlan" : @"plan",
              @"expiryDate" : @"expiry_date",
              @"currentCarrier" : @"current_carrier"
              }];
}

+ (NSValueTransformer *)businessIdJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)expiryDateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:number.longLongValue];
    } reverseBlock:^(NSDate *date) {
        return @([date timeIntervalSince1970]);
    }];
}

@end
