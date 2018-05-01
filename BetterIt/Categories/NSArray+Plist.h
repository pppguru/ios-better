//
//  NSArray+Plist.h
//  BetterIt
//
//  Created by devMac on 10/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Plist)

- (BOOL)bt_writeToPlistFile:(NSString *)filename;

+ (NSArray *)bt_readFromPlistFile:(NSString *)filename;

@end
