//
//  NavigationBarDrawingKit.m
//  BetterIt
//
//  Created by Jayden on 22/12/15.
//  Copyright © 2015 Jayden. All rights reserved.
//

#import "NavigationBarDrawingKit.h"



@implementation NavigationBarDrawingKit

#pragma mark Initialization

+ (void)initialize
{
}


#pragma mark Drawing Methods

+ (void)drawNavBarPersonalIconWithFgColor: (UIColor*)fgColor bgColor: (UIColor*)bgColor
{
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(63.77, 1.75)];
    [bezier4Path addCurveToPoint: CGPointMake(62.02, -0) controlPoint1: CGPointMake(63.77, 0.78) controlPoint2: CGPointMake(62.98, -0)];
    [bezier4Path addLineToPoint: CGPointMake(46.78, -0)];
    [bezier4Path addLineToPoint: CGPointMake(31.69, -0)];
    [bezier4Path addLineToPoint: CGPointMake(4.51, -0)];
    [bezier4Path addCurveToPoint: CGPointMake(-0, 4.51) controlPoint1: CGPointMake(2.02, -0) controlPoint2: CGPointMake(-0, 2.02)];
    [bezier4Path addLineToPoint: CGPointMake(-0, 38.4)];
    [bezier4Path addCurveToPoint: CGPointMake(4.51, 42.91) controlPoint1: CGPointMake(-0, 40.89) controlPoint2: CGPointMake(2.02, 42.91)];
    [bezier4Path addLineToPoint: CGPointMake(46.71, 42.91)];
    [bezier4Path addCurveToPoint: CGPointMake(49.16, 41.15) controlPoint1: CGPointMake(47.84, 42.91) controlPoint2: CGPointMake(48.81, 42.17)];
    [bezier4Path addLineToPoint: CGPointMake(63.66, 2.35)];
    [bezier4Path addCurveToPoint: CGPointMake(63.77, 1.75) controlPoint1: CGPointMake(63.72, 2.16) controlPoint2: CGPointMake(63.77, 1.96)];
    [bezier4Path closePath];
    bezier4Path.lineCapStyle = kCGLineCapRound;
    
    bezier4Path.lineJoinStyle = kCGLineJoinRound;
    
    [bgColor setFill];
    [bezier4Path fill];
    
    
    //// Oval 3 Drawing
    UIBezierPath* oval3Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(12.75, 8.76, 26.1, 26)];
    [[UIColor whiteColor] setFill];
    [oval3Path fill];
    
    
    //// Group
    {
        //// Oval 4 Drawing
        UIBezierPath* oval4Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(12.75, 8.76, 26.1, 26)];
        [fgColor setStroke];
        oval4Path.lineWidth = 1.16;
        [oval4Path stroke];
        
        
        //// Oval 5 Drawing
        UIBezierPath* oval5Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(20.05, 16.06, 11.5, 11.5)];
        [fgColor setStroke];
        oval5Path.lineWidth = 1.16;
        [oval5Path stroke];
        
        
        //// Bezier 5 Drawing
        UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
        [bezier5Path moveToPoint: CGPointMake(21.71, 25.88)];
        [bezier5Path addCurveToPoint: CGPointMake(17.16, 31.52) controlPoint1: CGPointMake(19.49, 27.02) controlPoint2: CGPointMake(17.81, 29.06)];
        bezier5Path.lineCapStyle = kCGLineCapRound;
        
        bezier5Path.lineJoinStyle = kCGLineJoinRound;
        
        [fgColor setStroke];
        bezier5Path.lineWidth = 1.16;
        [bezier5Path stroke];
        
        
        //// Bezier 6 Drawing
        UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
        [bezier6Path moveToPoint: CGPointMake(34.4, 31.52)];
        [bezier6Path addCurveToPoint: CGPointMake(29.85, 25.88) controlPoint1: CGPointMake(33.75, 29.06) controlPoint2: CGPointMake(32.07, 27.02)];
        bezier6Path.lineCapStyle = kCGLineCapRound;
        
        bezier6Path.lineJoinStyle = kCGLineJoinRound;
        
        [fgColor setStroke];
        bezier6Path.lineWidth = 1.16;
        [bezier6Path stroke];
    }
}

+ (void)drawNavBarChatIconWithFgColor: (UIColor*)fgColor bgColor: (UIColor*)bgColor
{
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(0, 41.16)];
    [bezierPath addCurveToPoint: CGPointMake(1.75, 42.91) controlPoint1: CGPointMake(0, 42.12) controlPoint2: CGPointMake(0.78, 42.91)];
    [bezierPath addLineToPoint: CGPointMake(16.99, 42.91)];
    [bezierPath addLineToPoint: CGPointMake(32.08, 42.91)];
    [bezierPath addLineToPoint: CGPointMake(59.26, 42.91)];
    [bezierPath addCurveToPoint: CGPointMake(63.77, 38.4) controlPoint1: CGPointMake(61.75, 42.91) controlPoint2: CGPointMake(63.77, 40.89)];
    [bezierPath addLineToPoint: CGPointMake(63.77, 4.51)];
    [bezierPath addCurveToPoint: CGPointMake(59.26, -0) controlPoint1: CGPointMake(63.77, 2.02) controlPoint2: CGPointMake(61.75, -0)];
    [bezierPath addLineToPoint: CGPointMake(17.06, -0)];
    [bezierPath addCurveToPoint: CGPointMake(14.61, 1.75) controlPoint1: CGPointMake(15.93, -0) controlPoint2: CGPointMake(14.96, 0.73)];
    [bezierPath addLineToPoint: CGPointMake(0.11, 40.56)];
    [bezierPath addCurveToPoint: CGPointMake(0, 41.16) controlPoint1: CGPointMake(0.04, 40.74) controlPoint2: CGPointMake(0, 40.94)];
    [bezierPath closePath];
    [bgColor setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(32.07, 9.22)];
    [bezier2Path addCurveToPoint: CGPointMake(21.22, 20.07) controlPoint1: CGPointMake(26.08, 9.22) controlPoint2: CGPointMake(21.22, 14.08)];
    [bezier2Path addCurveToPoint: CGPointMake(23.17, 26.26) controlPoint1: CGPointMake(21.22, 22.37) controlPoint2: CGPointMake(21.94, 24.51)];
    [bezier2Path addCurveToPoint: CGPointMake(19.05, 31.6) controlPoint1: CGPointMake(22.36, 28.43) controlPoint2: CGPointMake(20.91, 30.29)];
    [bezier2Path addCurveToPoint: CGPointMake(22.45, 32.15) controlPoint1: CGPointMake(20.12, 31.96) controlPoint2: CGPointMake(21.26, 32.15)];
    [bezier2Path addCurveToPoint: CGPointMake(28.49, 30.31) controlPoint1: CGPointMake(24.68, 32.15) controlPoint2: CGPointMake(26.76, 31.47)];
    [bezier2Path addCurveToPoint: CGPointMake(32.07, 30.92) controlPoint1: CGPointMake(29.61, 30.7) controlPoint2: CGPointMake(30.82, 30.92)];
    [bezier2Path addCurveToPoint: CGPointMake(42.92, 20.07) controlPoint1: CGPointMake(38.06, 30.92) controlPoint2: CGPointMake(42.92, 26.06)];
    [bezier2Path addCurveToPoint: CGPointMake(32.07, 9.22) controlPoint1: CGPointMake(42.92, 14.08) controlPoint2: CGPointMake(38.06, 9.22)];
    [bezier2Path closePath];
    [fillColor setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(51.1, 28.93)];
    [bezier3Path addCurveToPoint: CGPointMake(53.33, 23.19) controlPoint1: CGPointMake(52.48, 27.41) controlPoint2: CGPointMake(53.33, 25.41)];
    [bezier3Path addCurveToPoint: CGPointMake(44.81, 14.67) controlPoint1: CGPointMake(53.33, 18.49) controlPoint2: CGPointMake(49.52, 14.67)];
    [bezier3Path addCurveToPoint: CGPointMake(36.29, 23.19) controlPoint1: CGPointMake(40.1, 14.67) controlPoint2: CGPointMake(36.29, 18.49)];
    [bezier3Path addCurveToPoint: CGPointMake(44.81, 31.71) controlPoint1: CGPointMake(36.29, 27.9) controlPoint2: CGPointMake(40.1, 31.71)];
    [bezier3Path addCurveToPoint: CGPointMake(48.21, 31) controlPoint1: CGPointMake(46.02, 31.71) controlPoint2: CGPointMake(47.17, 31.46)];
    [bezier3Path addCurveToPoint: CGPointMake(52.5, 32.44) controlPoint1: CGPointMake(49.41, 31.9) controlPoint2: CGPointMake(50.89, 32.44)];
    [bezier3Path addCurveToPoint: CGPointMake(51.1, 28.93) controlPoint1: CGPointMake(51.75, 31.44) controlPoint2: CGPointMake(51.25, 30.24)];
    [bezier3Path closePath];
    [fillColor setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(32.07, 9.22)];
    [bezier4Path addCurveToPoint: CGPointMake(21.22, 20.07) controlPoint1: CGPointMake(26.08, 9.22) controlPoint2: CGPointMake(21.22, 14.08)];
    [bezier4Path addCurveToPoint: CGPointMake(23.17, 26.26) controlPoint1: CGPointMake(21.22, 22.37) controlPoint2: CGPointMake(21.94, 24.51)];
    [bezier4Path addCurveToPoint: CGPointMake(19.05, 31.6) controlPoint1: CGPointMake(22.36, 28.43) controlPoint2: CGPointMake(20.91, 30.29)];
    [bezier4Path addCurveToPoint: CGPointMake(22.45, 32.15) controlPoint1: CGPointMake(20.12, 31.96) controlPoint2: CGPointMake(21.26, 32.15)];
    [bezier4Path addCurveToPoint: CGPointMake(28.49, 30.31) controlPoint1: CGPointMake(24.68, 32.15) controlPoint2: CGPointMake(26.76, 31.47)];
    [bezier4Path addCurveToPoint: CGPointMake(32.07, 30.92) controlPoint1: CGPointMake(29.61, 30.7) controlPoint2: CGPointMake(30.82, 30.92)];
    [bezier4Path addCurveToPoint: CGPointMake(42.92, 20.07) controlPoint1: CGPointMake(38.06, 30.92) controlPoint2: CGPointMake(42.92, 26.06)];
    [bezier4Path addCurveToPoint: CGPointMake(32.07, 9.22) controlPoint1: CGPointMake(42.92, 14.08) controlPoint2: CGPointMake(38.06, 9.22)];
    [bezier4Path closePath];
    [fgColor setStroke];
    bezier4Path.lineWidth = 1.16;
    [bezier4Path stroke];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(51.1, 28.93)];
    [bezier5Path addCurveToPoint: CGPointMake(53.33, 23.19) controlPoint1: CGPointMake(52.48, 27.41) controlPoint2: CGPointMake(53.33, 25.41)];
    [bezier5Path addCurveToPoint: CGPointMake(44.81, 14.67) controlPoint1: CGPointMake(53.33, 18.49) controlPoint2: CGPointMake(49.52, 14.67)];
    [bezier5Path addCurveToPoint: CGPointMake(36.29, 23.19) controlPoint1: CGPointMake(40.1, 14.67) controlPoint2: CGPointMake(36.29, 18.49)];
    [bezier5Path addCurveToPoint: CGPointMake(44.81, 31.71) controlPoint1: CGPointMake(36.29, 27.9) controlPoint2: CGPointMake(40.1, 31.71)];
    [bezier5Path addCurveToPoint: CGPointMake(48.21, 31) controlPoint1: CGPointMake(46.02, 31.71) controlPoint2: CGPointMake(47.17, 31.46)];
    [bezier5Path addCurveToPoint: CGPointMake(52.5, 32.44) controlPoint1: CGPointMake(49.41, 31.9) controlPoint2: CGPointMake(50.89, 32.44)];
    [bezier5Path addCurveToPoint: CGPointMake(51.1, 28.93) controlPoint1: CGPointMake(51.75, 31.44) controlPoint2: CGPointMake(51.25, 30.24)];
    [bezier5Path closePath];
    [fgColor setStroke];
    bezier5Path.lineWidth = 1.16;
    [bezier5Path stroke];
}

+ (void)drawNavBarBusinessIconWithFgColor: (UIColor*)fgColor bgColor: (UIColor*)bgColor
{
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(63.77, 1.75)];
    [bezierPath addCurveToPoint: CGPointMake(62.02, -0) controlPoint1: CGPointMake(63.77, 0.78) controlPoint2: CGPointMake(62.98, -0)];
    [bezierPath addLineToPoint: CGPointMake(46.78, -0)];
    [bezierPath addLineToPoint: CGPointMake(31.69, -0)];
    [bezierPath addLineToPoint: CGPointMake(4.51, -0)];
    [bezierPath addCurveToPoint: CGPointMake(-0, 4.51) controlPoint1: CGPointMake(2.02, -0) controlPoint2: CGPointMake(-0, 2.02)];
    [bezierPath addLineToPoint: CGPointMake(-0, 38.4)];
    [bezierPath addCurveToPoint: CGPointMake(4.51, 42.91) controlPoint1: CGPointMake(-0, 40.89) controlPoint2: CGPointMake(2.02, 42.91)];
    [bezierPath addLineToPoint: CGPointMake(46.71, 42.91)];
    [bezierPath addCurveToPoint: CGPointMake(49.16, 41.15) controlPoint1: CGPointMake(47.84, 42.91) controlPoint2: CGPointMake(48.81, 42.17)];
    [bezierPath addLineToPoint: CGPointMake(63.66, 2.35)];
    [bezierPath addCurveToPoint: CGPointMake(63.77, 1.75) controlPoint1: CGPointMake(63.72, 2.16) controlPoint2: CGPointMake(63.77, 1.96)];
    [bezierPath closePath];
    [bgColor setFill];
    [bezierPath fill];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(12.75, 8.71, 26.1, 26.1)];
    [fillColor setFill];
    [ovalPath fill];
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(12.75, 8.71, 26.1, 26.1)];
    [fgColor setStroke];
    oval2Path.lineWidth = 1.16;
    [oval2Path stroke];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(16.58, 30.62)];
    [bezier2Path addLineToPoint: CGPointMake(16.58, 23.31)];
    [bezier2Path addLineToPoint: CGPointMake(21.18, 23.31)];
    [bezier2Path addLineToPoint: CGPointMake(21.18, 14.11)];
    [bezier2Path addLineToPoint: CGPointMake(25.78, 14.11)];
    [bezier2Path addLineToPoint: CGPointMake(25.78, 18.71)];
    [bezier2Path addLineToPoint: CGPointMake(30.38, 18.71)];
    [bezier2Path addLineToPoint: CGPointMake(30.38, 23.31)];
    [bezier2Path addLineToPoint: CGPointMake(34.98, 23.31)];
    [bezier2Path addLineToPoint: CGPointMake(34.98, 30.62)];
    bezier2Path.lineCapStyle = kCGLineCapRound;
    
    bezier2Path.lineJoinStyle = kCGLineJoinRound;
    
    [fgColor setStroke];
    bezier2Path.lineWidth = 1.16;
    [bezier2Path stroke];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(21.18, 23.31)];
    [bezier3Path addLineToPoint: CGPointMake(25.78, 23.31)];
    [bezier3Path addLineToPoint: CGPointMake(25.78, 30.26)];
    bezier3Path.lineCapStyle = kCGLineCapRound;
    
    bezier3Path.lineJoinStyle = kCGLineJoinRound;
    
    [fgColor setStroke];
    bezier3Path.lineWidth = 1.16;
    [bezier3Path stroke];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(30.38, 23.31)];
    [bezier4Path addLineToPoint: CGPointMake(30.38, 27.19)];
    bezier4Path.lineCapStyle = kCGLineCapRound;
    
    bezier4Path.lineJoinStyle = kCGLineJoinRound;
    
    [fgColor setStroke];
    bezier4Path.lineWidth = 1.16;
    [bezier4Path stroke];
}


+ (void)drawNavBarLogoIconWithTextColor: (UIColor*)textColor percentage: (CGFloat)percentage
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor2 = [UIColor colorWithRed: 0.953 green: 0.819 blue: 0.084 alpha: 1];
    UIColor* fillColor3 = [UIColor colorWithRed: 0.974 green: 0.902 blue: 0.115 alpha: 1];
    UIColor* fillColor4 = [UIColor colorWithRed: 0.741 green: 0.741 blue: 0.741 alpha: 1];
    UIColor* fillColor = [UIColor colorWithRed: 0.921 green: 0.699 blue: 0.068 alpha: 1];
    
    //// Variable Declarations
    CGFloat capActiveAlpha = percentage;
    CGFloat capInactiveAlpha = 1 - percentage;
    CGFloat textScale = percentage;
    CGFloat textB_X = 28 * (1 - percentage);
    CGFloat capWidth = 26 + 38 * percentage;
    
    //// Frames
    CGRect frame = CGRectMake(capWidth, 0, 12, 20);
    
    
    //// B Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, textB_X, 9.05);
    
    UIBezierPath* bPath = [UIBezierPath bezierPath];
    [bPath moveToPoint: CGPointMake(0, 0)];
    [bPath addLineToPoint: CGPointMake(0, 18.14)];
    [bPath addLineToPoint: CGPointMake(8.56, 18.14)];
    [bPath addCurveToPoint: CGPointMake(10.52, 17.79) controlPoint1: CGPointMake(9.26, 18.14) controlPoint2: CGPointMake(9.91, 18.02)];
    [bPath addCurveToPoint: CGPointMake(12.13, 16.82) controlPoint1: CGPointMake(11.14, 17.56) controlPoint2: CGPointMake(11.67, 17.24)];
    [bPath addCurveToPoint: CGPointMake(13.23, 15.34) controlPoint1: CGPointMake(12.59, 16.4) controlPoint2: CGPointMake(12.96, 15.91)];
    [bPath addCurveToPoint: CGPointMake(13.64, 13.46) controlPoint1: CGPointMake(13.51, 14.77) controlPoint2: CGPointMake(13.64, 14.14)];
    [bPath addCurveToPoint: CGPointMake(12.73, 10.55) controlPoint1: CGPointMake(13.64, 12.35) controlPoint2: CGPointMake(13.34, 11.38)];
    [bPath addCurveToPoint: CGPointMake(10.27, 8.84) controlPoint1: CGPointMake(12.13, 9.72) controlPoint2: CGPointMake(11.31, 9.14)];
    [bPath addCurveToPoint: CGPointMake(12.19, 7.14) controlPoint1: CGPointMake(11.09, 8.46) controlPoint2: CGPointMake(11.73, 7.9)];
    [bPath addCurveToPoint: CGPointMake(12.88, 4.62) controlPoint1: CGPointMake(12.65, 6.38) controlPoint2: CGPointMake(12.88, 5.54)];
    [bPath addCurveToPoint: CGPointMake(12.58, 2.95) controlPoint1: CGPointMake(12.88, 4.06) controlPoint2: CGPointMake(12.78, 3.5)];
    [bPath addCurveToPoint: CGPointMake(11.75, 1.47) controlPoint1: CGPointMake(12.39, 2.4) controlPoint2: CGPointMake(12.11, 1.9)];
    [bPath addCurveToPoint: CGPointMake(10.45, 0.41) controlPoint1: CGPointMake(11.39, 1.04) controlPoint2: CGPointMake(10.96, 0.68)];
    [bPath addCurveToPoint: CGPointMake(8.74, 0) controlPoint1: CGPointMake(9.94, 0.14) controlPoint2: CGPointMake(9.37, 0)];
    [bPath addLineToPoint: CGPointMake(0, 0)];
    [bPath closePath];
    [bPath moveToPoint: CGPointMake(1.79, 1.56)];
    [bPath addLineToPoint: CGPointMake(8.18, 1.56)];
    [bPath addCurveToPoint: CGPointMake(9.35, 1.83) controlPoint1: CGPointMake(8.6, 1.56) controlPoint2: CGPointMake(8.99, 1.65)];
    [bPath addCurveToPoint: CGPointMake(10.28, 2.54) controlPoint1: CGPointMake(9.71, 2) controlPoint2: CGPointMake(10.02, 2.24)];
    [bPath addCurveToPoint: CGPointMake(10.9, 3.6) controlPoint1: CGPointMake(10.55, 2.84) controlPoint2: CGPointMake(10.75, 3.19)];
    [bPath addCurveToPoint: CGPointMake(11.11, 4.9) controlPoint1: CGPointMake(11.04, 4.01) controlPoint2: CGPointMake(11.11, 4.44)];
    [bPath addCurveToPoint: CGPointMake(10.88, 6.17) controlPoint1: CGPointMake(11.11, 5.35) controlPoint2: CGPointMake(11.03, 5.77)];
    [bPath addCurveToPoint: CGPointMake(10.24, 7.23) controlPoint1: CGPointMake(10.73, 6.57) controlPoint2: CGPointMake(10.52, 6.92)];
    [bPath addCurveToPoint: CGPointMake(9.26, 7.97) controlPoint1: CGPointMake(9.97, 7.54) controlPoint2: CGPointMake(9.64, 7.78)];
    [bPath addCurveToPoint: CGPointMake(8.02, 8.25) controlPoint1: CGPointMake(8.88, 8.16) controlPoint2: CGPointMake(8.46, 8.25)];
    [bPath addLineToPoint: CGPointMake(1.79, 8.25)];
    [bPath addLineToPoint: CGPointMake(1.79, 1.56)];
    [bPath closePath];
    [bPath moveToPoint: CGPointMake(1.79, 9.71)];
    [bPath addLineToPoint: CGPointMake(8.74, 9.71)];
    [bPath addCurveToPoint: CGPointMake(9.98, 10) controlPoint1: CGPointMake(9.18, 9.71) controlPoint2: CGPointMake(9.59, 9.81)];
    [bPath addCurveToPoint: CGPointMake(10.97, 10.77) controlPoint1: CGPointMake(10.36, 10.2) controlPoint2: CGPointMake(10.69, 10.45)];
    [bPath addCurveToPoint: CGPointMake(11.62, 11.86) controlPoint1: CGPointMake(11.25, 11.08) controlPoint2: CGPointMake(11.47, 11.45)];
    [bPath addCurveToPoint: CGPointMake(11.85, 13.16) controlPoint1: CGPointMake(11.78, 12.28) controlPoint2: CGPointMake(11.85, 12.71)];
    [bPath addCurveToPoint: CGPointMake(11.6, 14.44) controlPoint1: CGPointMake(11.85, 13.6) controlPoint2: CGPointMake(11.77, 14.03)];
    [bPath addCurveToPoint: CGPointMake(10.9, 15.54) controlPoint1: CGPointMake(11.43, 14.86) controlPoint2: CGPointMake(11.19, 15.23)];
    [bPath addCurveToPoint: CGPointMake(9.85, 16.3) controlPoint1: CGPointMake(10.6, 15.86) controlPoint2: CGPointMake(10.25, 16.11)];
    [bPath addCurveToPoint: CGPointMake(8.56, 16.58) controlPoint1: CGPointMake(9.45, 16.48) controlPoint2: CGPointMake(9.02, 16.58)];
    [bPath addLineToPoint: CGPointMake(1.79, 16.58)];
    [bPath addLineToPoint: CGPointMake(1.79, 9.71)];
    [bPath closePath];
    [textColor setFill];
    [bPath fill];
    
    CGContextRestoreGState(context);
    
    
    //// Other Text
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 46.39, 18.25);
        CGContextScaleCTM(context, textScale, 1);
        
        
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(-7.81, -9.2)];
        [bezierPath addLineToPoint: CGPointMake(-7.82, -4.37)];
        [bezierPath addLineToPoint: CGPointMake(-9.66, -4.37)];
        [bezierPath addLineToPoint: CGPointMake(-9.66, -2.99)];
        [bezierPath addLineToPoint: CGPointMake(-7.82, -2.99)];
        [bezierPath addLineToPoint: CGPointMake(-7.82, 6.54)];
        [bezierPath addCurveToPoint: CGPointMake(-7.59, 7.66) controlPoint1: CGPointMake(-7.82, 6.97) controlPoint2: CGPointMake(-7.74, 7.34)];
        [bezierPath addCurveToPoint: CGPointMake(-6.97, 8.47) controlPoint1: CGPointMake(-7.44, 7.99) controlPoint2: CGPointMake(-7.23, 8.26)];
        [bezierPath addCurveToPoint: CGPointMake(-6.08, 8.94) controlPoint1: CGPointMake(-6.72, 8.68) controlPoint2: CGPointMake(-6.42, 8.84)];
        [bezierPath addCurveToPoint: CGPointMake(-5.01, 9.09) controlPoint1: CGPointMake(-5.74, 9.04) controlPoint2: CGPointMake(-5.38, 9.09)];
        [bezierPath addCurveToPoint: CGPointMake(-3.99, 8.99) controlPoint1: CGPointMake(-4.65, 9.09) controlPoint2: CGPointMake(-4.31, 9.06)];
        [bezierPath addCurveToPoint: CGPointMake(-3.12, 8.76) controlPoint1: CGPointMake(-3.66, 8.92) controlPoint2: CGPointMake(-3.37, 8.85)];
        [bezierPath addCurveToPoint: CGPointMake(-2.44, 8.51) controlPoint1: CGPointMake(-2.86, 8.68) controlPoint2: CGPointMake(-2.64, 8.59)];
        [bezierPath addCurveToPoint: CGPointMake(-1.99, 8.3) controlPoint1: CGPointMake(-2.25, 8.42) controlPoint2: CGPointMake(-2.1, 8.35)];
        [bezierPath addLineToPoint: CGPointMake(-2.45, 6.9)];
        [bezierPath addCurveToPoint: CGPointMake(-3.17, 7.24) controlPoint1: CGPointMake(-2.56, 6.97) controlPoint2: CGPointMake(-2.79, 7.08)];
        [bezierPath addCurveToPoint: CGPointMake(-4.47, 7.48) controlPoint1: CGPointMake(-3.54, 7.4) controlPoint2: CGPointMake(-3.98, 7.48)];
        [bezierPath addCurveToPoint: CGPointMake(-5.56, 7.14) controlPoint1: CGPointMake(-4.88, 7.48) controlPoint2: CGPointMake(-5.24, 7.37)];
        [bezierPath addCurveToPoint: CGPointMake(-6.08, 6.05) controlPoint1: CGPointMake(-5.87, 6.91) controlPoint2: CGPointMake(-6.05, 6.55)];
        [bezierPath addLineToPoint: CGPointMake(-6.08, -2.99)];
        [bezierPath addLineToPoint: CGPointMake(-2.02, -2.99)];
        [bezierPath addLineToPoint: CGPointMake(-2.02, -4.37)];
        [bezierPath addLineToPoint: CGPointMake(-6.08, -4.37)];
        [bezierPath addLineToPoint: CGPointMake(-6.08, -9.2)];
        [bezierPath addLineToPoint: CGPointMake(-7.81, -9.2)];
        [bezierPath closePath];
        [textColor setFill];
        [bezierPath fill];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
        [bezier2Path moveToPoint: CGPointMake(-16.83, -9.2)];
        [bezier2Path addLineToPoint: CGPointMake(-16.83, -4.37)];
        [bezier2Path addLineToPoint: CGPointMake(-18.67, -4.37)];
        [bezier2Path addLineToPoint: CGPointMake(-18.67, -2.99)];
        [bezier2Path addLineToPoint: CGPointMake(-16.83, -2.99)];
        [bezier2Path addLineToPoint: CGPointMake(-16.83, 6.54)];
        [bezier2Path addCurveToPoint: CGPointMake(-16.6, 7.66) controlPoint1: CGPointMake(-16.83, 6.97) controlPoint2: CGPointMake(-16.76, 7.34)];
        [bezier2Path addCurveToPoint: CGPointMake(-15.99, 8.47) controlPoint1: CGPointMake(-16.45, 7.99) controlPoint2: CGPointMake(-16.24, 8.26)];
        [bezier2Path addCurveToPoint: CGPointMake(-15.09, 8.94) controlPoint1: CGPointMake(-15.73, 8.68) controlPoint2: CGPointMake(-15.43, 8.84)];
        [bezier2Path addCurveToPoint: CGPointMake(-14.02, 9.09) controlPoint1: CGPointMake(-14.75, 9.04) controlPoint2: CGPointMake(-14.4, 9.09)];
        [bezier2Path addCurveToPoint: CGPointMake(-13, 8.99) controlPoint1: CGPointMake(-13.66, 9.09) controlPoint2: CGPointMake(-13.32, 9.06)];
        [bezier2Path addCurveToPoint: CGPointMake(-12.13, 8.76) controlPoint1: CGPointMake(-12.68, 8.92) controlPoint2: CGPointMake(-12.39, 8.85)];
        [bezier2Path addCurveToPoint: CGPointMake(-11.45, 8.51) controlPoint1: CGPointMake(-11.87, 8.68) controlPoint2: CGPointMake(-11.65, 8.59)];
        [bezier2Path addCurveToPoint: CGPointMake(-11.01, 8.3) controlPoint1: CGPointMake(-11.26, 8.42) controlPoint2: CGPointMake(-11.11, 8.35)];
        [bezier2Path addLineToPoint: CGPointMake(-11.47, 6.9)];
        [bezier2Path addCurveToPoint: CGPointMake(-12.18, 7.24) controlPoint1: CGPointMake(-11.57, 6.97) controlPoint2: CGPointMake(-11.81, 7.08)];
        [bezier2Path addCurveToPoint: CGPointMake(-13.48, 7.48) controlPoint1: CGPointMake(-12.56, 7.4) controlPoint2: CGPointMake(-12.99, 7.48)];
        [bezier2Path addCurveToPoint: CGPointMake(-14.57, 7.14) controlPoint1: CGPointMake(-13.89, 7.48) controlPoint2: CGPointMake(-14.26, 7.37)];
        [bezier2Path addCurveToPoint: CGPointMake(-15.09, 6.05) controlPoint1: CGPointMake(-14.89, 6.91) controlPoint2: CGPointMake(-15.06, 6.55)];
        [bezier2Path addLineToPoint: CGPointMake(-15.09, -2.99)];
        [bezier2Path addLineToPoint: CGPointMake(-11.03, -2.99)];
        [bezier2Path addLineToPoint: CGPointMake(-11.03, -4.37)];
        [bezier2Path addLineToPoint: CGPointMake(-15.09, -4.37)];
        [bezier2Path addLineToPoint: CGPointMake(-15.1, -9.2)];
        [bezier2Path addLineToPoint: CGPointMake(-16.83, -9.2)];
        [bezier2Path closePath];
        [textColor setFill];
        [bezier2Path fill];
        
        
        //// Bezier 4 Drawing
        UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
        [bezier4Path moveToPoint: CGPointMake(-27.94, -4.05)];
        [bezier4Path addCurveToPoint: CGPointMake(-30.05, -2.57) controlPoint1: CGPointMake(-28.76, -3.68) controlPoint2: CGPointMake(-29.46, -3.19)];
        [bezier4Path addCurveToPoint: CGPointMake(-31.43, -0.4) controlPoint1: CGPointMake(-30.64, -1.95) controlPoint2: CGPointMake(-31.1, -1.22)];
        [bezier4Path addCurveToPoint: CGPointMake(-31.93, 2.25) controlPoint1: CGPointMake(-31.76, 0.43) controlPoint2: CGPointMake(-31.93, 1.31)];
        [bezier4Path addCurveToPoint: CGPointMake(-31.43, 4.93) controlPoint1: CGPointMake(-31.93, 3.2) controlPoint2: CGPointMake(-31.76, 4.1)];
        [bezier4Path addCurveToPoint: CGPointMake(-30.04, 7.14) controlPoint1: CGPointMake(-31.1, 5.76) controlPoint2: CGPointMake(-30.63, 6.5)];
        [bezier4Path addCurveToPoint: CGPointMake(-27.93, 8.65) controlPoint1: CGPointMake(-29.44, 7.78) controlPoint2: CGPointMake(-28.74, 8.28)];
        [bezier4Path addCurveToPoint: CGPointMake(-25.26, 9.2) controlPoint1: CGPointMake(-27.12, 9.01) controlPoint2: CGPointMake(-26.23, 9.2)];
        [bezier4Path addCurveToPoint: CGPointMake(-23.39, 8.95) controlPoint1: CGPointMake(-24.61, 9.2) controlPoint2: CGPointMake(-23.99, 9.12)];
        [bezier4Path addCurveToPoint: CGPointMake(-21.76, 8.26) controlPoint1: CGPointMake(-22.8, 8.79) controlPoint2: CGPointMake(-22.26, 8.56)];
        [bezier4Path addCurveToPoint: CGPointMake(-20.46, 7.22) controlPoint1: CGPointMake(-21.27, 7.97) controlPoint2: CGPointMake(-20.83, 7.62)];
        [bezier4Path addCurveToPoint: CGPointMake(-19.59, 5.88) controlPoint1: CGPointMake(-20.08, 6.82) controlPoint2: CGPointMake(-19.79, 6.37)];
        [bezier4Path addLineToPoint: CGPointMake(-21.1, 5.47)];
        [bezier4Path addCurveToPoint: CGPointMake(-21.76, 6.45) controlPoint1: CGPointMake(-21.25, 5.83) controlPoint2: CGPointMake(-21.47, 6.15)];
        [bezier4Path addCurveToPoint: CGPointMake(-22.73, 7.2) controlPoint1: CGPointMake(-22.05, 6.75) controlPoint2: CGPointMake(-22.37, 7)];
        [bezier4Path addCurveToPoint: CGPointMake(-23.91, 7.69) controlPoint1: CGPointMake(-23.09, 7.41) controlPoint2: CGPointMake(-23.48, 7.57)];
        [bezier4Path addCurveToPoint: CGPointMake(-25.18, 7.87) controlPoint1: CGPointMake(-24.33, 7.81) controlPoint2: CGPointMake(-24.76, 7.87)];
        [bezier4Path addCurveToPoint: CGPointMake(-27.01, 7.5) controlPoint1: CGPointMake(-25.83, 7.87) controlPoint2: CGPointMake(-26.44, 7.75)];
        [bezier4Path addCurveToPoint: CGPointMake(-28.53, 6.46) controlPoint1: CGPointMake(-27.58, 7.25) controlPoint2: CGPointMake(-28.09, 6.91)];
        [bezier4Path addCurveToPoint: CGPointMake(-29.62, 4.89) controlPoint1: CGPointMake(-28.97, 6.02) controlPoint2: CGPointMake(-29.34, 5.5)];
        [bezier4Path addCurveToPoint: CGPointMake(-30.11, 2.91) controlPoint1: CGPointMake(-29.9, 4.29) controlPoint2: CGPointMake(-30.06, 3.63)];
        [bezier4Path addLineToPoint: CGPointMake(-18.72, 2.91)];
        [bezier4Path addCurveToPoint: CGPointMake(-18.7, 2.63) controlPoint1: CGPointMake(-18.7, 2.86) controlPoint2: CGPointMake(-18.7, 2.77)];
        [bezier4Path addLineToPoint: CGPointMake(-18.7, 2.22)];
        [bezier4Path addCurveToPoint: CGPointMake(-19.18, -0.38) controlPoint1: CGPointMake(-18.7, 1.3) controlPoint2: CGPointMake(-18.86, 0.43)];
        [bezier4Path addCurveToPoint: CGPointMake(-20.53, -2.56) controlPoint1: CGPointMake(-19.5, -1.2) controlPoint2: CGPointMake(-19.96, -1.92)];
        [bezier4Path addCurveToPoint: CGPointMake(-22.62, -4.05) controlPoint1: CGPointMake(-21.11, -3.18) controlPoint2: CGPointMake(-21.81, -3.68)];
        [bezier4Path addCurveToPoint: CGPointMake(-25.29, -4.6) controlPoint1: CGPointMake(-23.42, -4.42) controlPoint2: CGPointMake(-24.31, -4.6)];
        [bezier4Path addCurveToPoint: CGPointMake(-27.94, -4.05) controlPoint1: CGPointMake(-26.24, -4.6) controlPoint2: CGPointMake(-27.13, -4.42)];
        [bezier4Path closePath];
        [bezier4Path moveToPoint: CGPointMake(-29.67, -0.36)];
        [bezier4Path addCurveToPoint: CGPointMake(-28.62, -1.89) controlPoint1: CGPointMake(-29.4, -0.95) controlPoint2: CGPointMake(-29.05, -1.46)];
        [bezier4Path addCurveToPoint: CGPointMake(-27.1, -2.89) controlPoint1: CGPointMake(-28.19, -2.32) controlPoint2: CGPointMake(-27.68, -2.65)];
        [bezier4Path addCurveToPoint: CGPointMake(-25.26, -3.24) controlPoint1: CGPointMake(-26.52, -3.13) controlPoint2: CGPointMake(-25.91, -3.24)];
        [bezier4Path addCurveToPoint: CGPointMake(-23.43, -2.89) controlPoint1: CGPointMake(-24.61, -3.24) controlPoint2: CGPointMake(-24, -3.13)];
        [bezier4Path addCurveToPoint: CGPointMake(-21.93, -1.89) controlPoint1: CGPointMake(-22.86, -2.65) controlPoint2: CGPointMake(-22.36, -2.32)];
        [bezier4Path addCurveToPoint: CGPointMake(-20.85, -0.37) controlPoint1: CGPointMake(-21.49, -1.46) controlPoint2: CGPointMake(-21.13, -0.96)];
        [bezier4Path addCurveToPoint: CGPointMake(-20.36, 1.58) controlPoint1: CGPointMake(-20.57, 0.22) controlPoint2: CGPointMake(-20.41, 0.87)];
        [bezier4Path addLineToPoint: CGPointMake(-30.14, 1.58)];
        [bezier4Path addCurveToPoint: CGPointMake(-29.67, -0.36) controlPoint1: CGPointMake(-30.09, 0.89) controlPoint2: CGPointMake(-29.93, 0.24)];
        [bezier4Path closePath];
        [textColor setFill];
        [bezier4Path fill];
        
        
        //// Bezier 5 Drawing
        UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
        [bezier5Path moveToPoint: CGPointMake(1.9, -4.05)];
        [bezier5Path addCurveToPoint: CGPointMake(-0.21, -2.57) controlPoint1: CGPointMake(1.08, -3.68) controlPoint2: CGPointMake(0.38, -3.19)];
        [bezier5Path addCurveToPoint: CGPointMake(-1.59, -0.4) controlPoint1: CGPointMake(-0.8, -1.95) controlPoint2: CGPointMake(-1.26, -1.22)];
        [bezier5Path addCurveToPoint: CGPointMake(-2.09, 2.25) controlPoint1: CGPointMake(-1.92, 0.43) controlPoint2: CGPointMake(-2.09, 1.31)];
        [bezier5Path addCurveToPoint: CGPointMake(-1.59, 4.93) controlPoint1: CGPointMake(-2.09, 3.2) controlPoint2: CGPointMake(-1.92, 4.1)];
        [bezier5Path addCurveToPoint: CGPointMake(-0.2, 7.14) controlPoint1: CGPointMake(-1.26, 5.76) controlPoint2: CGPointMake(-0.79, 6.5)];
        [bezier5Path addCurveToPoint: CGPointMake(1.91, 8.65) controlPoint1: CGPointMake(0.4, 7.78) controlPoint2: CGPointMake(1.1, 8.28)];
        [bezier5Path addCurveToPoint: CGPointMake(4.58, 9.2) controlPoint1: CGPointMake(2.72, 9.01) controlPoint2: CGPointMake(3.61, 9.2)];
        [bezier5Path addCurveToPoint: CGPointMake(6.44, 8.95) controlPoint1: CGPointMake(5.22, 9.2) controlPoint2: CGPointMake(5.85, 9.12)];
        [bezier5Path addCurveToPoint: CGPointMake(8.08, 8.26) controlPoint1: CGPointMake(7.04, 8.79) controlPoint2: CGPointMake(7.58, 8.56)];
        [bezier5Path addCurveToPoint: CGPointMake(9.38, 7.22) controlPoint1: CGPointMake(8.57, 7.97) controlPoint2: CGPointMake(9.01, 7.62)];
        [bezier5Path addCurveToPoint: CGPointMake(10.25, 5.88) controlPoint1: CGPointMake(9.75, 6.82) controlPoint2: CGPointMake(10.04, 6.37)];
        [bezier5Path addLineToPoint: CGPointMake(8.74, 5.47)];
        [bezier5Path addCurveToPoint: CGPointMake(8.08, 6.45) controlPoint1: CGPointMake(8.59, 5.83) controlPoint2: CGPointMake(8.37, 6.15)];
        [bezier5Path addCurveToPoint: CGPointMake(7.11, 7.2) controlPoint1: CGPointMake(7.79, 6.75) controlPoint2: CGPointMake(7.46, 7)];
        [bezier5Path addCurveToPoint: CGPointMake(5.93, 7.69) controlPoint1: CGPointMake(6.75, 7.41) controlPoint2: CGPointMake(6.36, 7.57)];
        [bezier5Path addCurveToPoint: CGPointMake(4.65, 7.87) controlPoint1: CGPointMake(5.51, 7.81) controlPoint2: CGPointMake(5.08, 7.87)];
        [bezier5Path addCurveToPoint: CGPointMake(2.83, 7.5) controlPoint1: CGPointMake(4.01, 7.87) controlPoint2: CGPointMake(3.4, 7.75)];
        [bezier5Path addCurveToPoint: CGPointMake(1.31, 6.46) controlPoint1: CGPointMake(2.26, 7.25) controlPoint2: CGPointMake(1.75, 6.91)];
        [bezier5Path addCurveToPoint: CGPointMake(0.22, 4.89) controlPoint1: CGPointMake(0.87, 6.02) controlPoint2: CGPointMake(0.5, 5.5)];
        [bezier5Path addCurveToPoint: CGPointMake(-0.28, 2.91) controlPoint1: CGPointMake(-0.06, 4.29) controlPoint2: CGPointMake(-0.22, 3.63)];
        [bezier5Path addLineToPoint: CGPointMake(11.12, 2.91)];
        [bezier5Path addCurveToPoint: CGPointMake(11.14, 2.63) controlPoint1: CGPointMake(11.13, 2.86) controlPoint2: CGPointMake(11.14, 2.77)];
        [bezier5Path addLineToPoint: CGPointMake(11.14, 2.22)];
        [bezier5Path addCurveToPoint: CGPointMake(10.66, -0.38) controlPoint1: CGPointMake(11.14, 1.3) controlPoint2: CGPointMake(10.98, 0.43)];
        [bezier5Path addCurveToPoint: CGPointMake(9.3, -2.56) controlPoint1: CGPointMake(10.33, -1.2) controlPoint2: CGPointMake(9.88, -1.92)];
        [bezier5Path addCurveToPoint: CGPointMake(7.22, -4.05) controlPoint1: CGPointMake(8.72, -3.18) controlPoint2: CGPointMake(8.03, -3.68)];
        [bezier5Path addCurveToPoint: CGPointMake(4.55, -4.6) controlPoint1: CGPointMake(6.41, -4.42) controlPoint2: CGPointMake(5.52, -4.6)];
        [bezier5Path addCurveToPoint: CGPointMake(1.9, -4.05) controlPoint1: CGPointMake(3.6, -4.6) controlPoint2: CGPointMake(2.71, -4.42)];
        [bezier5Path closePath];
        [bezier5Path moveToPoint: CGPointMake(0.17, -0.36)];
        [bezier5Path addCurveToPoint: CGPointMake(1.22, -1.89) controlPoint1: CGPointMake(0.43, -0.95) controlPoint2: CGPointMake(0.79, -1.46)];
        [bezier5Path addCurveToPoint: CGPointMake(2.74, -2.89) controlPoint1: CGPointMake(1.65, -2.32) controlPoint2: CGPointMake(2.16, -2.65)];
        [bezier5Path addCurveToPoint: CGPointMake(4.58, -3.24) controlPoint1: CGPointMake(3.32, -3.13) controlPoint2: CGPointMake(3.93, -3.24)];
        [bezier5Path addCurveToPoint: CGPointMake(6.4, -2.89) controlPoint1: CGPointMake(5.22, -3.24) controlPoint2: CGPointMake(5.83, -3.13)];
        [bezier5Path addCurveToPoint: CGPointMake(7.91, -1.89) controlPoint1: CGPointMake(6.97, -2.65) controlPoint2: CGPointMake(7.48, -2.32)];
        [bezier5Path addCurveToPoint: CGPointMake(8.98, -0.37) controlPoint1: CGPointMake(8.35, -1.46) controlPoint2: CGPointMake(8.7, -0.96)];
        [bezier5Path addCurveToPoint: CGPointMake(9.48, 1.58) controlPoint1: CGPointMake(9.27, 0.22) controlPoint2: CGPointMake(9.43, 0.87)];
        [bezier5Path addLineToPoint: CGPointMake(-0.3, 1.58)];
        [bezier5Path addCurveToPoint: CGPointMake(0.17, -0.36) controlPoint1: CGPointMake(-0.25, 0.89) controlPoint2: CGPointMake(-0.09, 0.24)];
        [bezier5Path closePath];
        [textColor setFill];
        [bezier5Path fill];
        
        
        //// Bezier 6 Drawing
        UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
        [bezier6Path moveToPoint: CGPointMake(16.33, -3.58)];
        [bezier6Path addCurveToPoint: CGPointMake(14.34, -1.18) controlPoint1: CGPointMake(15.5, -3) controlPoint2: CGPointMake(14.84, -2.2)];
        [bezier6Path addLineToPoint: CGPointMake(14.34, -4.37)];
        [bezier6Path addLineToPoint: CGPointMake(12.71, -4.37)];
        [bezier6Path addLineToPoint: CGPointMake(12.71, 8.94)];
        [bezier6Path addLineToPoint: CGPointMake(14.44, 8.94)];
        [bezier6Path addLineToPoint: CGPointMake(14.44, 0.66)];
        [bezier6Path addCurveToPoint: CGPointMake(16.28, -1.87) controlPoint1: CGPointMake(14.8, -0.41) controlPoint2: CGPointMake(15.42, -1.25)];
        [bezier6Path addCurveToPoint: CGPointMake(19.35, -2.84) controlPoint1: CGPointMake(17.15, -2.48) controlPoint2: CGPointMake(18.17, -2.8)];
        [bezier6Path addLineToPoint: CGPointMake(19.35, -4.42)];
        [bezier6Path addCurveToPoint: CGPointMake(19.02, -4.45) controlPoint1: CGPointMake(19.26, -4.44) controlPoint2: CGPointMake(19.15, -4.45)];
        [bezier6Path addCurveToPoint: CGPointMake(16.33, -3.58) controlPoint1: CGPointMake(18.06, -4.45) controlPoint2: CGPointMake(17.17, -4.16)];
        [bezier6Path closePath];
        [textColor setFill];
        [bezier6Path fill];
        
        
        //// Rectangle Drawing
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(20.91, -9.18, 1.8, 18.15)];
        [textColor setFill];
        [rectanglePath fill];
        
        
        //// Bezier 7 Drawing
        UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
        [bezier7Path moveToPoint: CGPointMake(26.11, -9.2)];
        [bezier7Path addLineToPoint: CGPointMake(26.1, -4.37)];
        [bezier7Path addLineToPoint: CGPointMake(24.26, -4.37)];
        [bezier7Path addLineToPoint: CGPointMake(24.26, -2.99)];
        [bezier7Path addLineToPoint: CGPointMake(26.1, -2.99)];
        [bezier7Path addLineToPoint: CGPointMake(26.1, 6.54)];
        [bezier7Path addCurveToPoint: CGPointMake(26.34, 7.66) controlPoint1: CGPointMake(26.1, 6.97) controlPoint2: CGPointMake(26.18, 7.34)];
        [bezier7Path addCurveToPoint: CGPointMake(26.95, 8.47) controlPoint1: CGPointMake(26.49, 7.99) controlPoint2: CGPointMake(26.69, 8.26)];
        [bezier7Path addCurveToPoint: CGPointMake(27.84, 8.94) controlPoint1: CGPointMake(27.2, 8.68) controlPoint2: CGPointMake(27.5, 8.84)];
        [bezier7Path addCurveToPoint: CGPointMake(28.91, 9.09) controlPoint1: CGPointMake(28.18, 9.04) controlPoint2: CGPointMake(28.54, 9.09)];
        [bezier7Path addCurveToPoint: CGPointMake(29.94, 8.99) controlPoint1: CGPointMake(29.27, 9.09) controlPoint2: CGPointMake(29.61, 9.06)];
        [bezier7Path addCurveToPoint: CGPointMake(30.8, 8.76) controlPoint1: CGPointMake(30.26, 8.92) controlPoint2: CGPointMake(30.55, 8.85)];
        [bezier7Path addCurveToPoint: CGPointMake(31.48, 8.51) controlPoint1: CGPointMake(31.06, 8.68) controlPoint2: CGPointMake(31.29, 8.59)];
        [bezier7Path addCurveToPoint: CGPointMake(31.93, 8.3) controlPoint1: CGPointMake(31.68, 8.42) controlPoint2: CGPointMake(31.83, 8.35)];
        [bezier7Path addLineToPoint: CGPointMake(31.47, 6.9)];
        [bezier7Path addCurveToPoint: CGPointMake(30.75, 7.24) controlPoint1: CGPointMake(31.37, 6.97) controlPoint2: CGPointMake(31.13, 7.08)];
        [bezier7Path addCurveToPoint: CGPointMake(29.45, 7.48) controlPoint1: CGPointMake(30.38, 7.4) controlPoint2: CGPointMake(29.94, 7.48)];
        [bezier7Path addCurveToPoint: CGPointMake(28.36, 7.14) controlPoint1: CGPointMake(29.04, 7.48) controlPoint2: CGPointMake(28.68, 7.37)];
        [bezier7Path addCurveToPoint: CGPointMake(27.84, 6.05) controlPoint1: CGPointMake(28.05, 6.91) controlPoint2: CGPointMake(27.88, 6.55)];
        [bezier7Path addLineToPoint: CGPointMake(27.84, -2.99)];
        [bezier7Path addLineToPoint: CGPointMake(31.9, -2.99)];
        [bezier7Path addLineToPoint: CGPointMake(31.9, -4.37)];
        [bezier7Path addLineToPoint: CGPointMake(27.84, -4.37)];
        [bezier7Path addLineToPoint: CGPointMake(27.84, -9.2)];
        [bezier7Path addLineToPoint: CGPointMake(26.11, -9.2)];
        [bezier7Path closePath];
        [textColor setFill];
        [bezier7Path fill];
        
        
        
        CGContextRestoreGState(context);
    }
    
    
    //// Group 2
    {
        CGContextSaveGState(context);
        CGContextBeginTransparencyLayer(context, NULL);
        
        //// Clip Clip 2
        UIBezierPath* clip2Path = [UIBezierPath bezierPath];
        [clip2Path moveToPoint: CGPointMake(15.62, 4.53)];
        [clip2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 19.87, CGRectGetMinY(frame) + 4.59)];
        [clip2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 17.45, CGRectGetMinY(frame) + 18.76)];
        [clip2Path addLineToPoint: CGPointMake(CGRectGetMinX(frame) + 27.21, CGRectGetMinY(frame))];
        [clip2Path addLineToPoint: CGPointMake(15.62, 4.53)];
        [clip2Path closePath];
        [clip2Path addClip];
        
        
        //// Group
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, capActiveAlpha);
            CGContextBeginTransparencyLayer(context, NULL);
            
            
            //// Bezier 11 Drawing
            UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
            [bezier11Path moveToPoint: CGPointMake(2.09, 25.39)];
            [bezier11Path addLineToPoint: CGPointMake(16.39, -2.32)];
            [bezier11Path addLineToPoint: CGPointMake(56.97, -2.7)];
            [bezier11Path addLineToPoint: CGPointMake(56.97, 25.56)];
            [bezier11Path addLineToPoint: CGPointMake(2.09, 25.39)];
            [bezier11Path closePath];
            [fillColor setFill];
            [bezier11Path fill];
            
            
            //// Bezier 12 Drawing
            UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
            [bezier12Path moveToPoint: CGPointMake(34.56, 25.39)];
            [bezier12Path addLineToPoint: CGPointMake(48.85, -2.32)];
            [bezier12Path addLineToPoint: CGPointMake(89.43, -2.7)];
            [bezier12Path addLineToPoint: CGPointMake(89.43, 25.56)];
            [bezier12Path addLineToPoint: CGPointMake(34.56, 25.39)];
            [bezier12Path closePath];
            [fillColor2 setFill];
            [bezier12Path fill];
            
            
            //// Bezier 13 Drawing
            UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
            [bezier13Path moveToPoint: CGPointMake(66.25, 25.39)];
            [bezier13Path addLineToPoint: CGPointMake(80.55, -2.32)];
            [bezier13Path addLineToPoint: CGPointMake(99.87, -2.7)];
            [bezier13Path addLineToPoint: CGPointMake(99.87, 25.56)];
            [bezier13Path addLineToPoint: CGPointMake(66.25, 25.39)];
            [bezier13Path closePath];
            [fillColor3 setFill];
            [bezier13Path fill];
            
            
            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
        
        
        //// Group 3
        {
            CGContextSaveGState(context);
            CGContextSetAlpha(context, capInactiveAlpha);
            CGContextBeginTransparencyLayer(context, NULL);
            
            
            //// Rectangle 2 Drawing
            UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(10, -5, 100, 30)];
            [fillColor4 setFill];
            [rectangle2Path fill];
            
            
            CGContextEndTransparencyLayer(context);
            CGContextRestoreGState(context);
        }
        
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
}

@end
