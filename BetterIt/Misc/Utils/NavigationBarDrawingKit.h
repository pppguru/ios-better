//
//  NavigationBarDrawingKit.h
//  BetterIt
//
//  Created by Jayden on 22/12/15.
//  Copyright © 2015 Jayden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NavigationBarDrawingKit : NSObject

// Drawing Methods
+ (void)drawNavBarPersonalIconWithFgColor: (UIColor*)fgColor bgColor: (UIColor*)bgColor;

+ (void)drawNavBarChatIconWithFgColor: (UIColor*)fgColor bgColor: (UIColor*)bgColor;

+ (void)drawNavBarBusinessIconWithFgColor: (UIColor*)fgColor bgColor: (UIColor*)bgColor;

+ (void)drawNavBarLogoIconWithTextColor: (UIColor*)textColor percentage: (CGFloat)percentage;

@end
