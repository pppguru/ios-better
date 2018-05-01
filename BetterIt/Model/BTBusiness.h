//
//  BTBusiness.h
//  BetterIt
//
//  Created by devMac on 11/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTObject.h"



typedef enum {
    BTBusinessTypeNormal,
    BTBusinessTypeBrand
} BTBusinessType;



@class CLLocation;
@class BTSubscription;

@interface BTBusiness : BTObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSNumber *geoLatitude;
@property (copy, nonatomic) NSNumber *geoLongitude;
@property (copy, nonatomic) NSString *phoneNumber;
@property (copy, nonatomic) NSString *googlePlaceId;
@property (copy, nonatomic) NSString *photoReference;
@property (copy, nonatomic) NSString *thumbnails;
@property (copy, nonatomic) NSString *businessState;

@property (assign, nonatomic) BTBusinessType type;
@property (copy, nonatomic)   BTSubscription *subscription;

- (id)initWithGooglePlacesSearchResultDictionary:(NSDictionary *)rawData;
+ (id)businessWithGooglePlacesSearchResultDictionary:(NSDictionary *)rawData;

- (CLLocation *)geoLocation;
- (NSString *)imageURL;

- (BOOL)suspended;

@end
