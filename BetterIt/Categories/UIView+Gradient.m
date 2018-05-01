//
//  UIView+Gradient.m
//  BetterIt
//
//  Created by Maikel on 2/25/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "UIView+Gradient.h"

@implementation UIView (Gradient)

- (void)bt_setBackgroundGradient:(NSDictionary *)stopInfo {
    [self bt_setBackgroundGradient:stopInfo directionAngle:0];
}

- (void)bt_setBackgroundGradient:(NSDictionary *)stopInfo directionAngle:(CGFloat)angle {
    if (!stopInfo) {
        return;
    }

    // remove any previously given gradient
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    
    if (stopInfo[@"locations"]) {
        gradient.locations = stopInfo[@"locations"];
    }
    
    gradient.colors = stopInfo[@"colors"];
    
    // calculate startPoint and endPoint with directionAngle
    if (angle) {
        gradient.startPoint = CGPointMake(0.f, 0.5f - 0.5f * tan(angle));
        gradient.endPoint = CGPointMake(1.f, 0.5f + 0.5f * tan(angle));
    }
    
//    //NSLog(@"Gradient from %@ to %@", NSStringFromCGPoint(gradient.startPoint), NSStringFromCGPoint(gradient.endPoint));
//    //NSLog(@"Locations : %@", gradient.locations);
    
    [self.layer insertSublayer:gradient atIndex:0];}
@end
