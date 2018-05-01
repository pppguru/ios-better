//
//  BTModel.m
//  BetterIt
//
//  Created by devMac on 10/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTModel.h"
#import "Common.h"
#import "BTConfig.h"
#import "AppDelegate.h"
#import "NSArray+Plist.h"
#import <AFNetworking.h>
#import <FTGooglePlacesAPI.h>



NSString * const ModelSwitchedUserTypeNotification        = @"modelSwitchedUserType";
NSString * const ModelUserUpdatedNotification             = @"modelUserUpdated";
NSString * const ModelMessageSessionsUpdatedNotification  = @"modelMessageSessionsUpdated";
NSString * const ModelMessagesUpdatedNotification         = @"modelMessagesUpdated";
NSString * const ModelUserSubscriptionUpdatedNotification = @"modelUserSubscriptionUpdated";



NSString * const kConfigUserCurrentType = @"UserCurrentType";

NSString * const kUserCacheFileName = @"users_cache";
NSString * const kMessageSessionsCacheFileName = @"message_sessions_cache";
NSString * const kMessagesCacheFileName = @"messages_cache";
NSString * const kImagesCacheFileName = @"images_cache";




@interface BTModel ()

@property (strong, nonatomic) BTUser *normalUser;
@property (strong, nonatomic) BTUser *businessUser;

@property (strong, nonatomic) NSMutableArray *userMessageSessions;
@property (strong, nonatomic) NSMutableArray *businessMessageSessions;

@property (strong, nonatomic) NSMutableDictionary *messages;
@property (strong, nonatomic) NSMutableDictionary *images;
@property (strong, nonatomic) NSMutableDictionary *incentives;
@end




@implementation BTModel


SYNTHESIZE_SINGLETON_FOR_CLASS(BTModel)

#pragma mark - Initialize

+ (void)resetSingletonInstance {
    Model.normalUser = nil;
    Model.businessUser = nil;
    Model.userMessageSessions = nil;
    Model.businessMessageSessions = nil;
    Model.messages = nil;
    Model.messages = nil;
    Model.images = [NSMutableDictionary dictionary];
    Model.incentives = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self loadModel];
    }
    return self;
}

- (void)loadModel {
    _currentUserType = (BTUserType)[[BTConfig objectForKey:kConfigUserCurrentType] integerValue];
    
    NSArray *users = [NSArray bt_readFromPlistFile:kUserCacheFileName];
    if (users.count > 0) {
        _normalUser = users[0];
        if (users.count > 1) {
            _businessUser = users[1];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ModelUserUpdatedNotification object:nil];
    }
    
    NSArray *sessions = [NSArray bt_readFromPlistFile:kMessageSessionsCacheFileName];
    if (sessions.count > 0) {
        _userMessageSessions = [NSMutableArray arrayWithArray:sessions[0]];
        if (sessions.count > 1) {
            _businessMessageSessions = [NSMutableArray arrayWithArray:sessions[1]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ModelMessageSessionsUpdatedNotification object:nil];
    }
    
    _messages = [NSMutableDictionary dictionaryWithDictionary:[NSArray bt_readFromPlistFile:kMessagesCacheFileName].firstObject];
    _images = [NSMutableDictionary dictionaryWithDictionary:[BTConfig objectForKey:kImagesCacheFileName]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelMessagesUpdatedNotification object:nil];
}

- (void)saveModel {
    // save users
    NSArray *users = [NSArray arrayWithObjects:_normalUser, _businessUser, nil];
    [users bt_writeToPlistFile:kUserCacheFileName];
    
    // save message sessions
    NSArray *sessions = [NSArray arrayWithObjects:_userMessageSessions, _businessMessageSessions, nil];
    [sessions bt_writeToPlistFile:kMessageSessionsCacheFileName];
    
    // save messages
    NSArray *messages = [NSArray arrayWithObjects:_messages, nil];
    [messages bt_writeToPlistFile:kMessagesCacheFileName];
}

- (void)setInitialData:(NSDictionary *)initialData {
    
    [BTModel resetSingletonInstance];
    
    // save user
    [self setUser:[BTUser objectWithJSONDictionary:initialData[@"user"]] forType:BTUserTypeNormal];
    
    // save user sessions
    [self setMessageSessionsRaw:initialData[@"user"][@"sessions"] forType:BTUserTypeNormal];

    // save business user
    NSDictionary *businessProfile = initialData[@"businessProfile"];
    if (businessProfile && ![businessProfile isEqual:[NSNull null]] && ![@"" isEqual:businessProfile]) {
        [self setUser:[BTUser userWithBusinessProfile:businessProfile] forType:BTUserTypeBusiness];
        
        // save business user sessions
        [self setMessageSessionsRaw:businessProfile[@"sessions"] forType:BTUserTypeBusiness];
    }
    
    [self saveModel];
}

#pragma mark - User
#pragma mark User Type

- (void)setCurrentUserType:(BTUserType)userType {
    _currentUserType = userType;
    
    [BTConfig setObject:@(_currentUserType) forKey:kConfigUserCurrentType];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelSwitchedUserTypeNotification object:nil];
}

- (NSString *)currentUserTypeString {
    if (BTUserTypeBusiness == _currentUserType) {
        return USERTYPE_BUSINESS;
    } else {
        return USERTYPE_NORMAL;
    }
}

#pragma mark User

- (BTUser *)currentUser {
    return [self userForType:_currentUserType];
}

- (BTUser *)userForType:(BTUserType)userType {
    if (userType == BTUserTypeBusiness) {
        return _businessUser;
    } else {
        return _normalUser;
    }
    return nil;
}

- (void)setUser:(BTUser *)currentUser forType:(BTUserType)userType {
    if (userType == BTUserTypeBusiness) {
        _businessUser = currentUser;
    } else if (userType == BTUserTypeNormal) {
        _normalUser = currentUser;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelUserUpdatedNotification object:nil];
}

- (void)setCurrentUser:(BTUser *)currentUser {
    [self setUser:currentUser forType:currentUser.type];
}





#pragma mark - Message Session
#pragma mark Create

- (void)setMessageSessionsRaw:(NSArray *)JSONArray forType:(BTUserType)userType {
    if ([JSONArray isKindOfClass:[NSArray class]] && JSONArray.count) {
        NSArray *sessionObjects = [BTMessageSession objectsWithJSONArray:JSONArray];
        [self setMessageSessions:sessionObjects forType:userType];
        
        for (int i = 0; i < JSONArray.count; i++) {
            BTMessageSession *sessionObject = sessionObjects[i];
            NSDictionary *session = JSONArray[i];
            
            [self updateMessages:[BTMessage objectsWithJSONArray:session[@"messages"]] InSession:sessionObject.objectId shouldNotify:NO];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelMessageSessionsUpdatedNotification object:nil];
}

- (void)setMessageSessions:(NSArray *)messageSessions {
    [self setMessageSessions:messageSessions forType:self.currentUserType];
}

- (void)setMessageSessions:(NSArray *)messageSessions forType:(BTUserType)userType {
    if (BTUserTypeNormal == userType) {
        _userMessageSessions = [NSMutableArray arrayWithArray:messageSessions];
        
    } else if (BTUserTypeBusiness == userType) {
        _businessMessageSessions = [NSMutableArray arrayWithArray:messageSessions];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelMessageSessionsUpdatedNotification object:nil];
}

#pragma mark Read

- (NSMutableArray *)messageSessions {
    return [self messageSessionsForUser:self.currentUserType];
}

- (NSMutableArray *)messageSessionsForUser:(BTUserType)userType {
    if (userType == BTUserTypeBusiness) {
        return _businessMessageSessions;
    } else if (userType == BTUserTypeNormal) {
        return _userMessageSessions;
    }
    return nil;
}

- (BTMessageSession *)messageSessionBySessionId:(NSUInteger)sessionId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", @(sessionId)];

    return [self.messageSessions filteredArrayUsingPredicate:predicate].firstObject;
}

- (BTMessageSession *)messageSessionByBusinessId:(NSUInteger)businessId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"businessId == %@", @(businessId)];

    return [self.messageSessions filteredArrayUsingPredicate:predicate].firstObject;
}

- (BTMessageSession *)messageSessionByUserId:(NSUInteger)userId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", @(userId)];

    return [self.messageSessions filteredArrayUsingPredicate:predicate].firstObject;
}

#pragma mark Update

- (void)updateMessageSession:(BTMessageSession *)session {
    [self updateMessageSession:session forType:self.currentUserType];
}

- (void)updateMessageSession:(BTMessageSession *)session forType:(BTUserType)userType {
    if (userType == BTUserTypeNormal) {
        
        if (!_userMessageSessions) {
            _userMessageSessions = [NSMutableArray new];
        }
        
        [_userMessageSessions addObject:session];
        
    } else if (userType == BTUserTypeBusiness) {
        
        if (!_businessMessageSessions) {
            _businessMessageSessions = [NSMutableArray new];
        }
        
        [_businessMessageSessions addObject:session];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelMessageSessionsUpdatedNotification object:nil];
}



#pragma mark - Messages

- (NSArray *)getAllMessagesInSession:(NSUInteger)sessionId {
    if (!_messages || !_messages[NSStringFromObjectId(sessionId)])
        return [NSArray array];
    
    return [NSArray arrayWithArray:_messages[NSStringFromObjectId(sessionId)]];
}

- (void)setMessages:(NSArray *)messages InSession:(NSUInteger)sessionId {
    [self setMessages:messages InSession:sessionId shouldNotify:YES];
}

- (void)setMessages:(NSArray *)messages InSession:(NSUInteger)sessionId shouldNotify:(BOOL)shouldNotify {
    if (!_messages) {
        _messages = [NSMutableDictionary new];
    }

    // save in cache
    [_messages setObject:messages forKey:NSStringFromObjectId(sessionId)];
    
    if (shouldNotify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ModelMessagesUpdatedNotification object:nil];
    }
}

- (void)updateMessages:(NSArray *)messages InSession:(NSUInteger)sessionId {
    [self updateMessages:messages InSession:sessionId shouldNotify:YES];
}

- (void)updateMessages:(NSArray *)messages InSession:(NSUInteger)sessionId shouldNotify:(BOOL)shouldNotify {

    // remove messages if already exist
    [self removeMessages:messages InSession:sessionId];
    
    // add messages
    NSMutableArray *messagesInSession = [_messages[NSStringFromObjectId(sessionId)] mutableCopy];
    
    if (!messagesInSession) {
        messagesInSession = [NSMutableArray new];
    }

    [messagesInSession addObjectsFromArray:messages];
    
    // save in cache
    [self setMessages:messagesInSession InSession:sessionId shouldNotify:shouldNotify];
}

- (void)removeMessages:(NSArray *)messages InSession:(NSUInteger)sessionId {
    NSMutableArray *messagesInSession = [_messages[NSStringFromObjectId(sessionId)] mutableCopy];
    
    if (!messagesInSession) {
        return;
    }
    
    NSMutableArray *messageIds = [NSMutableArray new];
    
    // build message ids array
    for (id message in messages) {
        
        if ([message isMemberOfClass:[BTMessage class]]) {
            [messageIds addObject:@([message objectId])];
            
        } else if ([message isKindOfClass:[NSNumber class]]) {
            [messageIds addObject:message];
            
        } else {
            [messageIds addObject:message];
            
        }
        
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId in %@", messageIds];
    NSArray *messagesToRemove = [messagesInSession filteredArrayUsingPredicate:predicate];
    [messagesInSession removeObjectsInArray:messagesToRemove];

    [_messages setObject:messagesInSession forKey:NSStringFromObjectId(sessionId)];
}




#pragma mark - Images

- (void)registerImageMessage:(BTMessage *)imageMessage {
    if (!imageMessage.objectId || !imageMessage.sessionId || !imageMessage.imageLocal) {
        return;
    }
    
    [_images setObject:imageMessage.imageLocal forKey:imageMessage.localImageNameWithSessionIdAndMessageId];
    
    if (_images) {
        [BTConfig setObject:_images forKey:kImagesCacheFileName];
    }
}

- (NSString *)imageNameForMessage:(BTMessage *)imageMessage {
    return [_images objectForKey:imageMessage.localImageNameWithSessionIdAndMessageId];
}

- (void)downloadImageForMessage:(BTMessage *)imageMessage WithBlock:(void(^)(NSString *))completionBlock {
    if (!imageMessage.thumbnailURL || imageMessage.imageLocal) {
        if (completionBlock) {
            completionBlock(imageMessage.imageLocal);
        }
        
        return;
    }
    
    if (!imageMessage.sessionId || !imageMessage.objectId) {
        if (completionBlock) {
            completionBlock(nil);
        }
        
        return;
    }
    
    NSURL *thumbnailURL = [NSURL URLWithString:imageMessage.thumbnailURL];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:thumbnailURL]];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        if (responseObject) {
            NSData *imageData = UIImageJPEGRepresentation(responseObject, .5f);
            NSString *imageName = imageMessage.localImageNameWithSessionIdAndMessageId;
            NSString *imageFilePath = [appDelegate.applicationDocumentDirectory stringByAppendingPathComponent:imageName];
            
            [imageData writeToFile:imageFilePath atomically:YES];
            
            imageMessage.imageLocal = imageName;
            [self registerImageMessage:imageMessage];
            
            if (completionBlock) {
                completionBlock(imageName);
            }
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Image error: %@", error);
    }];
    
    [requestOperation start];
}




#pragma mark - Business Search
- (void)fetchBusinessesWithLocation:(CLLocation *)location
                          pageToken:(NSString *)pageToken
                                key:(NSString *)key
                    completionBlock:(void(^)(bool completed, NSString *key, NSArray *results, NSString *nextPageToken))completion
{
    static NSMutableDictionary *resultsCache;
    
    static NSArray *unfilteredCachedResults;
    NSArray *filteredCacheResults;
    
    if (!pageToken) {
        if (!location) {
            if (completion) {
                completion(YES, key, nil, nil);
            }
            return;
        }
        
        NSArray *cachedBusinesses = resultsCache.allValues;
        if (key.length) {
            NSArray *keyParts = [key componentsSeparatedByString:@" "];
            NSMutableArray *namePredicates = [NSMutableArray array];
            NSMutableArray *addressPredicates = [NSMutableArray array];
            
            for (NSString *keyPart in keyParts) {                
                [namePredicates addObject:[NSPredicate predicateWithFormat:@"name contains[cd] %@", keyPart]];
                [addressPredicates addObject:[NSPredicate predicateWithFormat:@"address contains[cd] %@", keyPart]];
            }
            
            NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[
                                                                                         [NSCompoundPredicate andPredicateWithSubpredicates:namePredicates],
                                                                                         [NSCompoundPredicate andPredicateWithSubpredicates:addressPredicates]
                                                                                         ]];
            cachedBusinesses = [cachedBusinesses filteredArrayUsingPredicate:predicate];
        }
        
        cachedBusinesses = [[BTModel arraySortedByDistance:cachedBusinesses fromLocation:location] subarrayWithRange:NSMakeRange(0, MIN(20, cachedBusinesses.count))];
        
        NSMutableDictionary *resultsToReturn = [NSMutableDictionary dictionary];
        for (BTBusiness *business in cachedBusinesses) {
            [resultsToReturn setObject:business forKey:business.googlePlaceId];
        }
        
        filteredCacheResults = resultsToReturn.allValues;
        
        if (completion) {
            completion(NO, key, [BTModel arraySortedByRelevance:resultsToReturn.allValues forSearchKey:key fromLocation:location], nil);
        }
    }
    
    //  Create request searching nearest galleries and museums
    FTGooglePlacesAPINearbySearchRequest *request;
    if (pageToken) {
        request = [[FTGooglePlacesAPINearbySearchRequest alloc] init];
        request.pageToken = pageToken;
    } else {
        request = [[FTGooglePlacesAPINearbySearchRequest alloc] initWithLocationCoordinate:location.coordinate];
        request.rankBy = FTGooglePlacesAPIRequestParamRankByDistance;
        request.types = @[@"establishment"];
        
        if (key && ![key isEqualToString:@""]) {
            request.names = @[key];
        }
    }
    
    //  Execute Google Places API request using FTGooglePlacesAPIService
    [FTGooglePlacesAPIService executeSearchRequest:request
                             withCompletionHandler:^(FTGooglePlacesAPISearchResponse *response, NSError *error) {
                                 
                                 //  If error is not nil, request failed and you should handle the error
                                 if (error)
                                 {
                                     
                                     if (error.code == 2) { //Error Domain=FTGooglePlacesAPIErrorDomain Code=2 "No results were found."
                                         
                                         NSMutableDictionary *resultsToReturn = [NSMutableDictionary dictionary];
                                         
                                         for (BTBusiness *business in filteredCacheResults) {
                                             [resultsToReturn setObject:business forKey:business.googlePlaceId];
                                         }
                                         
                                         if (completion) {
                                             completion(YES, key, [BTModel arraySortedByRelevance:resultsToReturn.allValues forSearchKey:key fromLocation:location], response.nextPageToken);
                                         }
                                         
                                     } else {
                                         // Handle error here
                                         //NSLog(@"Request failed. Error: %@", error);
                                         
                                         //  There may be a lot of causes for an error (for example networking error).
                                         //  If the network communication with Google Places API was successful,
                                         //  but the API returned some non-ok status code, NSError will have
                                         //  FTGooglePlacesAPIErrorDomain domain and status code from
                                         //  FTGooglePlacesAPIResponseStatus enum
                                         //  You can inspect error's domain and status code for more detailed info
                                         if (completion) {
                                             completion(YES, key, nil, response.nextPageToken);
                                         }
                                     }
                                     
                                 } else {
                                     
                                     //  Everything went fine, we have response object we can process
                                     //NSLog(@"Request succeeded. Response: %@", response);

                                     if (!resultsCache) {
                                         resultsCache = [NSMutableDictionary dictionary];
                                     }
                                     
                                     NSMutableDictionary *resultsToReturn = [NSMutableDictionary dictionary];
                                     
                                     for (FTGooglePlacesAPISearchResultItem *resultItem in response.results) {
                                         BTBusiness *business = [BTBusiness businessWithGooglePlacesSearchResultDictionary:resultItem.originalDictionaryRepresentation];
                                         
                                         [resultsToReturn setObject:business forKey:business.googlePlaceId];
                                         [resultsCache setObject:business forKey:business.googlePlaceId];
                                     }
                                     
                                     if (key.length == 0) {
                                         unfilteredCachedResults = resultsToReturn.allValues;
                                     }
        
                                     for (BTBusiness *business in filteredCacheResults) {
                                         [resultsToReturn setObject:business forKey:business.googlePlaceId];
                                     }
                                     
                                     if (completion) {
                                         completion(YES, key, [BTModel arraySortedByRelevance:resultsToReturn.allValues forSearchKey:key fromLocation:location], response.nextPageToken);
                                     }
                                     
                                 }
                                 
                             }];
}

+ (NSComparisonResult)sortUsingLocation:(BTBusiness *)b1 and:(BTBusiness *)b2 fromLocation:(CLLocation *)location {
    if ([b1.geoLocation distanceFromLocation:location] < [b2.geoLocation distanceFromLocation:location]) {
        return NSOrderedAscending;
    }
    return NSOrderedDescending;
}

+ (NSArray *)arraySortedByDistance:(NSArray *)array fromLocation:(CLLocation *)location
{
    return [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        BTBusiness *business1 = obj1;
        BTBusiness *business2 = obj2;
        return [BTModel sortUsingLocation:business1 and:business2 fromLocation:location];
    }];
}

+ (NSArray *)arraySortedByRelevance:(NSArray *)array forSearchKey:(NSString *)inKey fromLocation:(CLLocation *)location {
    
    return [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        BTBusiness *business1 = obj1;
        BTBusiness *business2 = obj2;
        
        NSString *key = inKey.lowercaseString;
        NSString *name1 = business1.name.lowercaseString;
        NSString *name2 = business2.name.lowercaseString;
        
        if (inKey.length == 0) {
            return [BTModel sortUsingLocation:business1 and:business2 fromLocation:location];
        }
        
        if ([name1 hasPrefix:key] && [name2 hasPrefix:key]) {
            return [BTModel sortUsingLocation:business1 and:business2 fromLocation:location];
        }
        
        if ([name1 hasPrefix:key]) {
            return NSOrderedAscending;
        }
        
        if ([name2 hasPrefix:key]) {
            return NSOrderedDescending;
        }
        
        if ([name1 containsString:key] && [name2 containsString:key]) {
            return [BTModel sortUsingLocation:business1 and:business2 fromLocation:location];
        }
        
        if ([name1 containsString:key]) {
            return NSOrderedAscending;
        }
        
        if ([name2 containsString:key]) {
            return NSOrderedDescending;
        }
        
        return [BTModel sortUsingLocation:business1 and:business2 fromLocation:location];
    }];
}

@end
