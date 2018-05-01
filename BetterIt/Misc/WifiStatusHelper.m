//
//  WifiStatusHelper.m
//  BetterIt
//
//  Created by Matias Pan on 3/21/16.
//  Copyright © 2016 Maikel. All rights reserved.
//

#import "WifiStatusHelper.h"
#import "ifaddrs.h"
#import <net/if.h>

@implementation WifiStatusHelper

+ (BOOL)isWiFiEnabled {
    
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

@end
