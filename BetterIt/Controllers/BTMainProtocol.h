//
//  BTMainProtocol.h
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BTMainProtocol <NSObject>
- (NSString *)userType;

- (void)presentProfileVC:(BOOL)animated;
- (void)presentMessageVC:(BOOL)animated;
@end

typedef UIViewController<BTMainProtocol> BTMainVC;
