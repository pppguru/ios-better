//
//  BTAppConfig.m
//  BetterIt
//
//  Created by devMac on 11/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTAppConfig.h"



@interface BTAppConfig ()
@property(strong, nonatomic) NSMutableDictionary *cache;
@end



@implementation BTAppConfig

SYNTHESIZE_SINGLETON_FOR_CLASS(BTAppConfig)

- (id)init {
    self = [super init];
    if (self) {
        _cache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    if (!_cache) {
        _cache = [[NSMutableDictionary alloc] init];
    }
    
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
