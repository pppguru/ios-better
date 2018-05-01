//
//  BTBusiness.m
//  BetterIt
//
//  Created by devMac on 11/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTBusiness.h"
#import "BTSubscription.h"
#import "Common.h"


@import CoreLocation;


@implementation BTBusiness

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"name" : @"name",
              @"address" : @"address",
              @"geoLatitude" : @"geo_lat",
              @"geoLongitude" : @"geo_lng",
              @"phoneNumber" : @"phone_number",
              @"googlePlaceId" : @"google_place_id",
              @"type" : @"type",
              @"thumbnails" : @"thumbnails",
              @"photoReference" : [NSNull null],
              @"subscription" : @"subscription",
              @"businessState" : @"business_state"
              }];
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"BUSINESS": @(BTBusinessTypeNormal),
                                                                           @"BRAND": @(BTBusinessTypeBrand)
                                                                           }];
}

+ (NSValueTransformer *)businessIdJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)subscriptionJSONTransformer {
    return [self modelTransformerWithClass:[BTSubscription class]];
}




#pragma mark - Initializeer

- (id)initWithGooglePlacesSearchResultDictionary:(NSDictionary *)rawData {
    self = [super init];
    if (self) {
        self.objectId = 0;
        _name = rawData[@"name"];
        _address = rawData[@"vicinity"];
        _geoLatitude = rawData[@"geometry"][@"location"][@"lat"];
        _geoLongitude = rawData[@"geometry"][@"location"][@"lng"];
        _phoneNumber = nil;
        _googlePlaceId = rawData[@"place_id"];
        
        NSArray *photos = rawData[@"photos"];
        if (photos.count) {
            _photoReference = photos[0][@"photo_reference"];
        }

        _type = BTBusinessTypeNormal;
        _subscription = nil;
    }
    
    return self;
}

+ (id)businessWithGooglePlacesSearchResultDictionary:(NSDictionary *)rawData {
    return [[BTBusiness alloc] initWithGooglePlacesSearchResultDictionary:rawData];
}


#pragma mark - Getters

- (CLLocation *)geoLocation {
    return [[CLLocation alloc] initWithLatitude:[_geoLatitude doubleValue] longitude:[_geoLongitude doubleValue]];
}

- (NSString *)imageURL {
    if (!_photoReference) {
        if ([_thumbnails respondsToSelector:@selector(length)] && _thumbnails.length > 2) {
            NSArray *split = [_thumbnails componentsSeparatedByString:@"photoreference="];
            if (split.count > 1) {
                _photoReference = split[1];
                _photoReference = [_photoReference componentsSeparatedByString:@"&"].firstObject;
            } else {
                NSArray *urls = [_thumbnails componentsSeparatedByString:@"\""];
                if (urls.count > 1) {
                    return urls[1];
                }
            }
        }
    }
    
    if (!_photoReference) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=140&photoreference=%@&key=%@", _photoReference, kGooglePlacesAPIKey];
}

- (BOOL)suspended {
    return [self.businessState isEqualToString:@"SUSPENDED"];
}

@end
