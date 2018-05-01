//
//  BTUser.h
//  BetterIt
//
//  Created by devMac on 10/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTObject.h"



#define USERTYPE_NORMAL @"USER"
#define USERTYPE_BUSINESS @"BUSINESS"

typedef enum {
    BTUserTypeNormal,
    BTUserTypeBusiness
} BTUserType;


@class BTBusiness;

@interface BTUser : BTObject

@property (assign, nonatomic) BTUserType type;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *gender;
@property (copy, nonatomic) NSString *phoneNumber;
@property (copy, nonatomic) NSString *status;

@property (copy, nonatomic) NSString *verificationCode;

@property (copy, nonatomic) NSString *deviceToken;
@property (copy, nonatomic) NSString *deviceType;

@property (assign, nonatomic) NSUInteger age;

@property (assign, nonatomic) NSNumber *isDemo;
@property (assign, nonatomic) NSNumber *allowDemo;

///////// Business User Profile ////////////
@property (copy, nonatomic) BTBusiness *business;
@property (assign, nonatomic) NSUInteger businessId;
@property (copy, nonatomic) NSString *pinCode;
@property (copy, nonatomic) NSString *businessUserRole;

- (BOOL)hasEmail;
- (BOOL)suspended;
- (NSString *)typeString;

+ (BTUser *)userWithBusinessProfile:(NSDictionary *)businessProfile;

@end
