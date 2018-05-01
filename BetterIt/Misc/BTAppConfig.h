//
//  BTAppConfig.h
//  BetterIt
//
//  Created by devMac on 11/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"




#define AppConfig ((BTAppConfig *)[BTAppConfig sharedInstance])




@interface BTAppConfig : NSObject
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(BTAppConfig)

- (void)setObject:(id)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
@end
