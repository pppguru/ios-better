//
//  Common.h
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#ifndef BetterIt_Common_h
#define BetterIt_Common_h

#import "BTUserIdentifierHelper.h"
#import "BTSuspendedUserAlertHelper.h"

#define PRODUCTION_BUILD NO

#define IsValidUserType(ut) ([USERTYPE_NORMAL isEqualToString:ut] || [USERTYPE_BUSINESS isEqualToString:ut])

#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]
#define RGB(r, g, b) RGBA(r, g, b, 1.f)

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define DEVICE_TOKEN [BTUserIdentifierHelper userIdentifier]
#define DEVICE_TYPE @"IPHONE"

#define DEFAULT_TEXT_COLOR RGB(108.f, 108.f, 108.f)
#define DEFAULT_GRAY_COLOR RGB(190.f, 195.f, 199.f)
#define DEFAULT_GOLD_COLOR RGB(240.f, 190.f, 17.f)
#define DEFAULT_LIGHT_GRAY_COLOR RGB(246.f, 246.f, 246.f)
#define DEFAULT_LIGHT_GOLD_COLOR RGB(253.f, 251.f, 224.f)
#define DEFAULT_GREEN_COLOR RGB(161.f, 201.f, 0.f)
#define DEFAULT_RED_COLOR   RGB(219.f, 69.f, 0.f)

#define METER_FOR_MILE 1609.34f
#define METER_FOR_FOOT 3.28084

#define MESSAGE_MAX_CHARACTER   350

#define kBetterItProductIdentifier          @"BetterItStandard"
#define kBetterItAndSurveyProductIdentifier @"BetterItPlusSurvey"
#define kBetterItSurveyProductIdentifier    @"BetterItSurveyAddon"


extern NSString * const kGooglePlacesAPIKey;

extern NSString * const NotificationUserLocationDidUpdate;

extern NSString * const NotificationTopNavigationBarDidStartScrolling;
extern NSString * const NotificationTopNavigationBarDidStopScrolling;

extern NSString * const kMessageTemplatesKey;
extern NSString * const kRewardTemplatesKey;

extern NSString * const kLocationQueueKey;





#endif
