//
//  UIView+Gradient.h
//  BetterIt
//
//  Created by Maikel on 2/25/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Gradient)

- (void)bt_setBackgroundGradient:(NSDictionary *)stopInfo;
- (void)bt_setBackgroundGradient:(NSDictionary *)stopInfo directionAngle:(CGFloat)angle;
@end
