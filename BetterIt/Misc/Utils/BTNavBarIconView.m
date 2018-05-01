//
//  BTNavBarIconView.m
//  BetterIt
//
//  Created by Jayden on 22/12/15.
//  Copyright © 2015 Jayden. All rights reserved.
//

#import "BTNavBarIconView.h"

#define FG_COLOR_START RGB(176.f, 182.f, 187.f)
#define FG_COLOR_END   RGB(235.f, 178.f, 17.f)
#define BG_COLOR_START RGB(241.f, 241.f, 241.f)
#define BG_COLOR_END   RGB(255.f, 255.f, 255.f)

@implementation BTNavBarIconView

- (void)setPercentage:(CGFloat)percentage {
    _percentage = percentage;
    
    [self setNeedsDisplay];
}

- (UIColor *)colorBetweenFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor weight:(CGFloat)weight {
    weight = MIN(1.f, MAX(0.f, weight));

    CGFloat r1, r2, g1, g2, b1, b2, a1, a2;
    [fromColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [toColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];

    return [UIColor colorWithRed:r1+(r2-r1) * weight
                           green:g1+(g2-g1) * weight
                            blue:b1+(b2-b1) * weight
                           alpha:a1+(a2-a1) * weight];
}

- (void)drawRect:(CGRect)rect
{
    UIColor *fgColor = [self colorBetweenFromColor:FG_COLOR_START toColor:FG_COLOR_END weight:_percentage];
    UIColor *bgColor = [self colorBetweenFromColor:BG_COLOR_START toColor:BG_COLOR_END weight:_percentage];
    
    switch (_iconType) {
        case BTNavBarIconPersonal:
            [NavigationBarDrawingKit drawNavBarPersonalIconWithFgColor:fgColor
                                                               bgColor:bgColor];
            break;

        case BTNavBarIconBusiness:
            [NavigationBarDrawingKit drawNavBarBusinessIconWithFgColor:fgColor
                                                               bgColor:bgColor];
            break;

        case BTNavBarIconChat:
            [NavigationBarDrawingKit drawNavBarChatIconWithFgColor:fgColor
                                                           bgColor:bgColor];
            break;

        case BTNavBarIconLogo:
            [NavigationBarDrawingKit drawNavBarLogoIconWithTextColor:fgColor
                                                          percentage:_percentage];
            break;
            
        default:
            break;
    }
}

@end
