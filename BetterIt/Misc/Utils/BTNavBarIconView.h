//
//  BTNavBarIconView.h
//  BetterIt
//
//  Created by Jayden on 22/12/15.
//  Copyright © 2015 Jayden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationBarDrawingKit.h"
#import "Common.h"


typedef NS_ENUM(NSInteger) {
    BTNavBarIconLogo,
    BTNavBarIconPersonal,
    BTNavBarIconBusiness,
    BTNavBarIconChat,
}BTNavBarIcon;


IB_DESIGNABLE
@interface BTNavBarIconView : UIView

@property (assign, nonatomic) IBInspectable CGFloat percentage;
@property (assign, nonatomic) BTNavBarIcon iconType;

@end

