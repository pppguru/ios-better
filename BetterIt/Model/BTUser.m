//
//  BTUser.m
//  BetterIt
//
//  Created by devMac on 10/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTUser.h"
#import "BTMessageSession.h"
#import "BTBusiness.h"




@implementation BTUser

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
             @"type" : @"type",
             @"username" : @"name",
             @"age" : @"age",
             @"email" : @"email",
             @"gender" : @"gender",
             @"phoneNumber" : @"phone_no",
             @"status" : @"status",
             @"verificationCode" : @"verification_code",
             @"deviceToken" : @"device_token",
             @"deviceType" : @"device_type",
             @"business" : @"business",
             @"businessId" : @"business_id",
             @"pinCode" : @"pincode",
             @"businessUserRole" : @"role",
             @"isDemo" : @"is_demo",
             @"allowDemo" : @"allow_demo"
             }];
}

#pragma mark Transformer

+ (NSValueTransformer *)businessJSONTransformer {
    return [BTObject modelTransformerWithClass:[BTBusiness class]];
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           USERTYPE_NORMAL: @(BTUserTypeNormal),
                                                                           USERTYPE_BUSINESS: @(BTUserTypeBusiness)
                                                                           }];
}

+ (NSValueTransformer *)ageJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)businessIdJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)isDemoJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)allowDemoJSONTransformer {
    return [self numberTransformer];
}

#pragma mark - Initializer

+ (BTUser *)userWithBusinessProfile:(NSDictionary *)businessProfile {
    NSError *error = nil;
    BTUser *businessUser = [MTLJSONAdapter modelOfClass:[BTUser class] fromJSONDictionary:businessProfile error:&error];
    
    if (error) {
        //NSLog(@"Error while parsing business profile - %@\nError - %@", businessProfile, error);
        return nil;
    }
    
    businessUser.username = businessUser.business.name;
    businessUser.type = BTUserTypeBusiness;
    businessUser.business.businessState = businessProfile[@"business_state"];
    return businessUser;
}

#pragma mark - MISC

- (BOOL)hasEmail {
    return [_email isKindOfClass:[NSString class]] && _email.length > 0;
}

- (BOOL)suspended {
    return [self.status isEqualToString:@"SUSPENDED"];
}

- (NSString *)typeString {
    if (_type == BTUserTypeBusiness) {
        return USERTYPE_BUSINESS;
    } else {
        return USERTYPE_NORMAL;
    }
}

@end
