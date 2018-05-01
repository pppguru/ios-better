//
//  BTConfig.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTConfig.h"

NSString * const kConfigDidShowWelcomeOverlay   = @"didShowWelcomeOverlay";

NSString * const kConfigLastImageFilename       = @"lastImageFilename";

NSString * const kAPNSTokenKey                  = @"apns_token";

NSString * const kIsNotFirstUseOfApp            = @"is_not_first_use";


@implementation BTConfig

static NSMutableDictionary *_cache;

+ (void)setObject:(id)object forKey:(NSString *)key {
    if (!_cache) {
        _cache = [[NSMutableDictionary alloc] init];
    }
    
    // save to memory cache
    [_cache setObject:object forKey:key];
    
    // save to local storage for permanent use
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
}

+ (id)objectForKey:(NSString *)key {
    // look up in memory
    id obj = _cache[key];
    
    if (!obj) {
        // not found, read from local storage
        obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (obj) {
            // if found, save it to memory for later use
            [_cache setObject:obj forKey:key];
        }
    }
    return obj;
}

@end
