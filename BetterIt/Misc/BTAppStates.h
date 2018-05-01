//
//  BTAppStates.h
//  BetterIt
//
//  Created by devMac on 11/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#define AppStates ((BTAppStates *)[BTAppStates sharedInstance])

//extern NSString * const kStatesCurrentUser;
//extern NSString * const kStatesCurrentBussiness;

extern NSString * const kStatesDidShowWelcomeOverlay;
extern NSString * const kStatesDidSetupBusiness;

//extern NSString * const kStatesLastUsedTime;

// Stores app specific states data
@interface BTAppStates : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(BTAppStates)

- (NSString *)currentUserType;
- (NSString *)currentUsername;
- (NSString *)currentUserEmail;

- (void)setObject:(id)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
@end
