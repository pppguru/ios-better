//
//  BTUserIdentifierHelper.m
//  BetterIt
//
//  Created by Matias Pan on 2/9/16.
//  Copyright © 2016 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTUserIdentifierHelper.h"

#define kKCUserIdentifier @"userIdentifier-UUID"

@implementation BTUserIdentifierHelper

+ (BOOL)userIdentifierExists {
    NSString *userIdentifier = [self valueForKeychainKey:kKCUserIdentifier service:kKCUserIdentifier];
    return userIdentifier.length > 0;
}

+ (NSString *)userIdentifier {
//    return @"A6344580-4452-4EBE-A69D-972BC7F5CEA6";
    NSString *userIdentifier = [self valueForKeychainKey:kKCUserIdentifier service:kKCUserIdentifier];
    
    if (userIdentifier.length > 0) {
        return userIdentifier;
    }
    
    userIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [self setValue:userIdentifier forKeychainKey:kKCUserIdentifier inService:kKCUserIdentifier];
    
    return userIdentifier;
}

+ (OSStatus)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    NSMutableDictionary *keychainItem = [[self class] keychainItemForKey:key service:service];
    keychainItem[(__bridge id)kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];
    return SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
}

+ (NSString *)valueForKeychainKey:(NSString *)key service:(NSString *)service {
    OSStatus status;
    NSMutableDictionary *keychainItem = [[self class] keychainItemForKey:key service:service];
    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    CFDictionaryRef result = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    if (status != noErr) {
        return nil;
    }
    NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
    NSData *data = resultDict[(__bridge id)kSecValueData];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSMutableDictionary *)keychainItemForKey:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecAttrService] = service;
    return keychainItem;
}

+ (NSString *)randomUUID {
    if(NSClassFromString(@"NSUUID")) {
        return [[NSUUID UUID] UUIDString];
    }
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfuuid = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [((__bridge NSString *) cfuuid) copy];
    CFRelease(cfuuid);
    return uuid;
}

@end
