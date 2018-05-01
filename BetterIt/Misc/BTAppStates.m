//
//  BTAppStates.m
//  BetterIt
//
//  Created by devMac on 11/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTAppStates.h"
#import "Common.h"

NSString * const kStatesCurrentUserType         = @"statesUserType";
NSString * const kStatesCurrentUsername         = @"statesUsername";
NSString * const kStatesCurrentUseremail        = @"statesUserEmail";
NSString * const kStatesCurrentBussiness        = @"statesBusiness";

NSString * const kStatesDidShowWelcomeOverlay   = @"statesDidShowWelcomeOverlay";
NSString * const kStatesDidSetupBusiness        = @"statesDidSetupBusines";

NSString * const kStatesLastUsedTime            = @"statesLastUsedTime";



@interface BTAppStates ()
@property(strong, nonatomic) NSMutableDictionary *cache;
@end




@implementation BTAppStates

SYNTHESIZE_SINGLETON_FOR_CLASS(BTAppStates)

- (id)init {
    self = [super init];
    if (self) {
        _cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (NSString *)currentUserType {
    NSString *userType = [self objectForKey:kStatesCurrentUserType];

    if (!userType || !IsValidUserType(userType)) {
        // reset to normal user if userType is invalid
        userType = USERTYPE_NORMAL;
        [self setObject:userType forKey:kStatesCurrentUserType];
    }
    
    return userType;
}

- (void)setCurrentUserType:(NSString *)userType {
    if (userType) {
        [self setObject:userType forKey:kStatesCurrentUserType];
    }
}
//
//- (NSString *)currentUsername {
//    return [self objectForKey:kStatesCurrentUsername][@"name"];
//}
//
//- (void)setCurrentUsername:(NSString *)username {
//    if (!username) {
//        return;
//    }
//    
//    NSMutableDictionary *userDic = [[self objectForKey:kStatesCurrentUser] mutableCopy];
//    if (!userDic) {
//        userDic = [[NSMutableDictionary alloc] init];
//    }
//    [userDic setObject:username forKey:@"name"];
//    
//    [self setObject:userDic forKey:kStatesCurrentUser];
//}
//
//- (NSString *)currentUserEmail {
//    return [self objectForKey:kStatesCurrentUser][@"email"];
//}

- (void)setObject:(id)object forKey:(NSString *)key {
    // save to memory cache
    [_cache setObject:object forKey:key];
    
    // save to local storage for permanent use
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)objectForKey:(NSString *)key {
    // look up in memory
    id obj = _cache[key];
    
    if (!obj) {
        // not found, read from local storage
        obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (obj) {
            // if found, cache it to memory for later use
            [_cache setObject:obj forKey:key];
        }
    }
    return obj;
}
@end
