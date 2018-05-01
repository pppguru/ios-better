//
//  BTMessage.h
//  BetterIt
//
//  Created by devMac on 12/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTObject.h"
#import <JSQMessages.h>

typedef enum {
    BTMessageFeedbackSubTypePositive = 1,
    BTMessageFeedbackSubTypeNegative = 2,
    BTMessageFeedbackSubTypeIdea = 3
} BTMessageFeedbackSubType;

typedef enum {
    BTMessageStateSubTypePositive = 1,
    BTMessageStateSubTypeNegative = 2
} BTMessageStateSubType;

typedef enum {
    BTMessageTypeUnknown = 0,
    BTMessageTypeFeedbackPositive = 1,
    BTMessageTypeFeedbackNegative = 2,
    BTMessageTypeFeedbackIdea = 3,
    BTMessageTypeReply = 10,
    BTMessageTypeIncentive = 20,
    BTMessageTypeUserState = 30,
    BTMessageTypeUserStatePositive = 31,
    BTMessageTypeUserStateNegative = 32,
    BTMessageTypeBusinessState = 40,
    BTMessageTypeBusinessStatePositive = 41,
    BTMessageTypeBusinessStateNegative = 42
} BTMessageType;




@class CLLocation;
@class BTMessageSession;
@class BTIncentive;

@interface BTMessage : BTObject <JSQMessageData>

@property (assign, nonatomic) NSUInteger sessionId;
@property (assign, nonatomic, readonly) NSUInteger userId;
@property (assign, nonatomic, readonly) NSUInteger type;
@property (copy, nonatomic, readonly) NSString *message;
@property (copy, nonatomic, readonly) NSString *imageURL;
@property (copy, nonatomic, readonly) NSString *thumbnailURL;

@property (copy, nonatomic) NSNumber *userFlagStatus;
@property (copy, nonatomic) NSNumber *businessFlagStatus;
@property (copy, nonatomic) NSString *imageLocal;

@property (copy, nonatomic, readonly) NSNumber *geoLatitude;
@property (copy, nonatomic, readonly) NSNumber *geoLongitude;
@property (copy, nonatomic, readonly) BTIncentive *incentive;

@property (assign, nonatomic) BOOL readStatus;
@property (assign, nonatomic) BOOL needsReview;

// message creation
- (id)initFeedbackMessageWithSubType:(BTMessageFeedbackSubType)type Text:(NSString *)text Image:(NSString *)image;
- (id)initReplyMessageWithSessionId:(NSUInteger)sessionId Text:(NSString *)text Image:(NSString *)image;
- (id)initIncentiveMessageWithSessionId:(NSUInteger)sessionId Incentive:(BTIncentive *)incentive;
- (id)initStateMessageWithSessionId:(NSUInteger)sessionId StateType:(BTMessageStateSubType)state;



- (CLLocation *)geoLocation;
- (void)setGeoLocation:(CLLocation *)location;

- (BOOL)isUserMessage;
- (BOOL)isMine;
- (NSString *)localImageNameWithSessionIdAndMessageId;

- (BOOL)hasImage;
- (UIImage *)image;
- (NSString *)imageDescription;
@end
