//
//  BTModel.h
//  BetterIt
//
//  Created by devMac on 10/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BTUser.h"
#import "BTBusiness.h"
#import "BTMessage.h"
#import "BTMessageSession.h"
#import "BTSubscription.h"
#import "BTIncentive.h"

#import "SynthesizeSingleton.h"




#define Model ((BTModel *)[BTModel sharedInstance])

extern NSString * const ModelSwitchedUserTypeNotification;
extern NSString * const ModelUserUpdatedNotification;
extern NSString * const ModelMessageSessionsUpdatedNotification;
extern NSString * const ModelMessagesUpdatedNotification;
extern NSString * const ModelUserSubscriptionUpdatedNotification;



@interface BTModel : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(BTModel)

@property (assign, nonatomic) BTUserType currentUserType;

- (void)loadModel;
- (void)saveModel;
- (void)setInitialData:(NSDictionary *)initialData;

///////////// Current User //////////////
- (NSString *)currentUserTypeString;

- (BTUser *)currentUser;
- (BTUser *)userForType:(BTUserType)userType;

- (void)setCurrentUser:(BTUser *)currentUser;
- (void)setUser:(BTUser *)user forType:(BTUserType)userType;


///////////// Message Sessions /////////////////

- (void)setMessageSessionsRaw:(NSArray *)JSONArray forType:(BTUserType)userType;
- (void)setMessageSessions:(NSArray *)messageSessions;
- (void)setMessageSessions:(NSArray *)messageSessions forType:(BTUserType)userType;

- (NSMutableArray *)messageSessions;
- (NSMutableArray *)messageSessionsForUser:(BTUserType)userType;

- (BTMessageSession *)messageSessionBySessionId:(NSUInteger)sessionId;
- (BTMessageSession *)messageSessionByBusinessId:(NSUInteger)businessId;
- (BTMessageSession *)messageSessionByUserId:(NSUInteger)userId;

- (void)updateMessageSession:(BTMessageSession *)session;
- (void)updateMessageSession:(BTMessageSession *)session forType:(BTUserType)userType;


///////////// Messages /////////////////

- (NSArray *)getAllMessagesInSession:(NSUInteger)sessionId;
- (void)setMessages:(NSArray *)messages InSession:(NSUInteger)sessionId;
- (void)updateMessages:(NSArray *)messages InSession:(NSUInteger)sessionId;
- (void)removeMessages:(NSArray *)messages InSession:(NSUInteger)sessionId;


//////////// Images ////////////////

- (void)registerImageMessage:(BTMessage *)imageMessage;
- (NSString *)imageNameForMessage:(BTMessage *)imageMessage;
- (void)downloadImageForMessage:(BTMessage *)imageMessage WithBlock:(void(^)(NSString *))completionBlock;


//////////// Business Search ////////////
- (void)fetchBusinessesWithLocation:(CLLocation *)location
                          pageToken:(NSString *)pageToken
                                key:(NSString *)key
                    completionBlock:(void(^)(bool completed, NSString *key, NSArray *results, NSString *nextPageToken))completion;
+ (NSArray *)arraySortedByDistance:(NSArray *)array fromLocation:(CLLocation *)location;
+ (NSArray *)arraySortedByRelevance:(NSArray *)array forSearchKey:(NSString *)inKey fromLocation:(CLLocation *)location;

@end
