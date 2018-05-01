//
//  NSArray+Plist.m
//  BetterIt
//
//  Created by devMac on 10/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "NSArray+Plist.h"

@implementation NSArray (Plist)

- (BOOL)bt_writeToPlistFile:(NSString *)filename {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSString *fullPath = [[NSArray bt_documentDirectoryPath] stringByAppendingPathComponent:filename];

    return [data writeToFile:fullPath atomically:YES];
}

+ (NSArray *)bt_readFromPlistFile:(NSString *)filename {
    NSString *fullPath = [[NSArray bt_documentDirectoryPath] stringByAppendingPathComponent:filename];

    NSData *data = [NSData dataWithContentsOfFile:fullPath];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+ (NSString *)bt_documentDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return paths.firstObject;
}

@end
