//
//  UIImageView+AlertLabel.h
//  BetterIt
//
//  Created by Maikel on 4/1/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALERT_LABEL_SIZE CGSizeMake(20.f, 20.f)

@interface UIView (AlertLabel)

- (UILabel *)bt_alertLabel;
- (void)bt_hideAlertLabel:(BOOL)hide;
- (void)bt_removeAlertLabel;
- (void)bt_layoutAlertLabel;
@end
