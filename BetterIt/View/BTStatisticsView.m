//
//  BTStatisticsView.m
//  BetterIt
//
//  Created by Maikel on 3/1/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTStatisticsView.h"
#import "UIView+Gradient.h"
#import "Common.h"

@implementation BTStatisticsView

+ (id)chartView {
    BTStatisticsView *chartView = [[[NSBundle mainBundle] loadNibNamed:@"BTStatisticsView" owner:nil options:nil] lastObject];
    
    // make sure cardView is not nil or the wrong class!
    if ([chartView isKindOfClass:[BTStatisticsView class]])
        return chartView;
    else
        return nil;
}

- (void)awakeFromNib {
    self.layer.cornerRadius = 5.f;
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self bt_setBackgroundGradient:@{@"colors" : @[(id)RGB(33, 64, 154).CGColor, (id)RGB(39, 170, 225).CGColor]}];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
