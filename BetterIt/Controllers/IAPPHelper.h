//
//  IAPPHelper.h
//  BetterIt
//
//  Created by Yosemite on 1/21/16.
//  Copyright © 2016 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKProduct;
@interface IAPPHelper : UIViewController

- (void)restore;
- (void)purchase:(SKProduct *)product;

@end
