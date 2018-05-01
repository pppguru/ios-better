//
//  BTConfig.h
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString * const kConfigDidShowWelcomeOverlay;

extern NSString * const kConfigLastImageFilename;

extern NSString * const kAPNSTokenKey;

extern NSString * const kIsNotFirstUseOfApp;

@interface BTConfig : NSObject

+ (void)setObject:(id)object forKey:(NSString *)key;
+ (id)objectForKey:(NSString *)key;

@end
