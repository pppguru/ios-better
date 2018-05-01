//
//  BTMessage.m
//  BetterIt
//
//  Created by devMac on 12/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTMessage.h"
#import "BTModel.h"
#import "AppDelegate.h"




@import CoreLocation;





@interface BTMessage ()
@property (strong, nonatomic) UIImage *image;
@end




@implementation BTMessage

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"sessionId" : @"message_session_id",
              @"userId" : @"user_id",
              @"type" : @"type",
              @"message" : @"text",
              @"imageURL" : @"image_url",
              @"thumbnailURL" : @"thumbnail_url",
              @"imageLocal" : @"image_local",
              @"geoLatitude" : @"geo_lat",
              @"geoLongitude" : @"geo_lng",
              @"image" : [NSNull null],
              @"userFlagStatus" : @"userFlagStatus",
              @"businessFlagStatus" : @"businessFlagStatus",
              }];
}

+ (NSValueTransformer *)userIdJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)sessionIdJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)sessionJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[BTMessageSession class]];
}

+ (NSValueTransformer *)messageJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    } reverseBlock:^(NSString *str) {
        return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }];
}

+ (NSValueTransformer *)imageLocalJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *str) {
        return str;
    } reverseBlock:^id(NSString *str) {
        if (!str) {
            return @"";
        }
        return str;
    }];
}

+ (NSValueTransformer *)incentiveJSONTransformer {
    return [self modelTransformerWithClass:[BTIncentive class]];
}


#pragma mark - Initializer

- (id)initFeedbackMessageWithSubType:(BTMessageFeedbackSubType)type Text:(NSString *)text Image:(NSString *)image {
    self = [super init];
    
    if (self) {
        _sessionId = 0;
        _userId = Model.currentUser.objectId;
        _type = type;
        _message = text;
        _imageLocal = image;
        
//        CLLocation *location = appDelegate.currentLocation;
//        _geoLatitude = @(location.coordinate.latitude);
//        _geoLongitude = @(location.coordinate.longitude);
    }
    
    return self;
}

- (id)initReplyMessageWithSessionId:(NSUInteger)sessionId Text:(NSString *)text Image:(NSString *)image {
    self = [super init];
    
    if (self) {
        _sessionId = sessionId;
        _userId = Model.currentUser.objectId;
        _type = BTMessageTypeReply;
        _message = text;
        _imageLocal = image;
        
//        CLLocation *location = appDelegate.currentLocation;
//        _geoLatitude = @(location.coordinate.latitude);
//        _geoLongitude = @(location.coordinate.longitude);
    }
    
    return self;
}

- (id)initIncentiveMessageWithSessionId:(NSUInteger)sessionId Incentive:(BTIncentive *)incentive {
    self = [super init];
    
    if (self) {
        _sessionId = sessionId;
        _userId = Model.currentUser.objectId;
        _type = BTMessageTypeIncentive;
        _incentive = incentive;
        
//        CLLocation *location = appDelegate.currentLocation;
//        _geoLatitude = @(location.coordinate.latitude);
//        _geoLongitude = @(location.coordinate.longitude);
    }
    
    return self;
}

- (id)initStateMessageWithSessionId:(NSUInteger)sessionId StateType:(BTMessageStateSubType)state {
    self = [super init];
    
    if (self) {
        _sessionId = sessionId;
        _userId = Model.currentUser.objectId;
        _type = (Model.currentUserType == BTUserTypeBusiness ? BTMessageTypeBusinessState : BTMessageTypeUserState) + state;
        
//        CLLocation *location = appDelegate.currentLocation;
//        _geoLatitude = @(location.coordinate.latitude);
//        _geoLongitude = @(location.coordinate.longitude);
    }
    
    return self;
}

- (NSDictionary *)JSONDictionary {
    if (_type == BTMessageTypeIncentive) {
        NSMutableDictionary *JSONDictionary = [MTLJSONAdapter JSONDictionaryFromModel:self].mutableCopy;
        [JSONDictionary removeObjectForKey:@"incentive"];
        [JSONDictionary addEntriesFromDictionary:[MTLJSONAdapter JSONDictionaryFromModel:_incentive]];
        
        return JSONDictionary;
    }

    return [super JSONDictionary];
}



#pragma mark - Getters & Setters

- (CLLocation *)geoLocation {
    return [[CLLocation alloc] initWithLatitude:_geoLatitude.doubleValue longitude:_geoLongitude.doubleValue];
}

- (void)setGeoLocation:(CLLocation *)location {
    _geoLatitude = @(location.coordinate.latitude);
    _geoLongitude = @(location.coordinate.longitude);
}

- (BOOL)isMine {
    return (Model.currentUserType == BTUserTypeNormal) ? [self isUserMessage] : ![self isUserMessage];
}

- (BTMessageSession *)messageSession {
    return [Model messageSessionBySessionId:_sessionId];
}

- (BOOL)isUserMessage {
    return _userId == self.messageSession.userId;
}

- (NSString *)imageLocal {
    if (_imageLocal.length) {
        return _imageLocal;
    }
    
    if (_imageURL.length) {
        if (_sessionId && self.objectId) {
            _imageLocal = [Model imageNameForMessage:self];
            return _imageLocal;
        }
    }
    
    return nil;
}

- (NSString *)localImageNameWithSessionIdAndMessageId {
    return [NSString stringWithFormat:@"%ld_%ld.jpg", (unsigned long)_sessionId, (unsigned long)self.objectId];
}

- (BOOL)hasImage {
    return _imageURL.length || _imageLocal.length || _incentive;
}

- (UIImage *)image {
    if (_image) {
        return _image;
    }
    
    if (_incentive) {
        _image = [UIImage imageNamed:@"chat_reward"];
    } else if (self.imageLocal) {
        NSString *imagePath = [appDelegate.applicationDocumentDirectory stringByAppendingPathComponent:self.imageLocal];
        _image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    return _image;
}

- (NSString *)imageDescription {
    if (_incentive) {
        return _incentive.couponDescription;
    }
    
    return nil;
}

- (BOOL)readStatus {
    if ([self isMine] || self.type > BTMessageTypeBusinessState) {
        return YES;
    }
    
    return _readStatus;
}

- (BOOL)needsReview {
    return ([self isMine] && (Model.currentUserType == BTUserTypeNormal ? self.userFlagStatus.boolValue : self.businessFlagStatus.boolValue));
}

- (void)setNeedsReview:(BOOL)needsReview {
    if ([self isMine]) {
        if (Model.currentUserType == BTUserTypeNormal) {
            self.userFlagStatus = @(needsReview);
        } else {
            self.businessFlagStatus = @(needsReview);
        }
    }
}

#pragma mark - JSQMessageData Protocol

- (NSString *)senderId {
    return [self isUserMessage] ? USERTYPE_NORMAL : USERTYPE_BUSINESS;
}

- (NSString *)senderDisplayName {
    if ([self isUserMessage]) {
        if ([self isMine]) {
            return @"You";
        } else {
            return [self messageSession].user.username;
        }
    } else {
        return [self messageSession].business.name;
    }
}

- (NSDate *)date {
    if (self.createdAt) {
        return self.createdAt;
    } else {
        return [NSDate date];
    }
}

- (BOOL)isMediaMessage {
    return NO;
}

- (NSUInteger)hash {
    return self.objectId;
}

- (NSUInteger)messageHash {
    return self.objectId;
}

- (id<JSQMessageMediaData>)media {
    return nil;
}

- (NSString *)text {
    switch (_type) {
        case BTMessageTypeUserStatePositive:
            return [NSString stringWithFormat:@"%@ said the interaction is going well.", self.senderDisplayName];
            
        case BTMessageTypeUserStateNegative:
            return [NSString stringWithFormat:@"%@ said the interaction is not going well.", self.senderDisplayName];
            
        case BTMessageTypeBusinessStatePositive:
            return [NSString stringWithFormat:@"%@ rated the interaction helpful.", self.senderDisplayName];
            
        case BTMessageTypeBusinessStateNegative:
            return [NSString stringWithFormat:@"%@ rated the interaction not helpful.", self.senderDisplayName];
            
        case BTMessageTypeIncentive:
            return @"";
            
        default:
            return _message;
    }
}
@end
