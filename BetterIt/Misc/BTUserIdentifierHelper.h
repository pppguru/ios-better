//
//  BTUserIdentifierHelper.h
//  BetterIt
//
//  Created by Matias Pan on 2/9/16.
//  Copyright © 2016 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTUserIdentifierHelper : NSObject

+ (BOOL)userIdentifierExists;
+ (NSString *)userIdentifier;

@end
