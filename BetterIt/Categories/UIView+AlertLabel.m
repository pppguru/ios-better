//
//  UIImageView+AlertLabel.m
//  BetterIt
//
//  Created by Maikel on 4/1/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "UIView+AlertLabel.h"
#import "Common.h"




#define ALERT_LABEL_TAG 999




@implementation UIView (AlertLabel)

- (UILabel *)_alertLabel {
    return (UILabel *)[self viewWithTag:ALERT_LABEL_TAG];
}

- (UILabel *)bt_alertLabel {
    UILabel *alertLabel = self._alertLabel;
    
    if (!alertLabel) {
        alertLabel = [[UILabel alloc] init];
        
        alertLabel.tag = ALERT_LABEL_TAG;
        
        alertLabel.layer.cornerRadius = ALERT_LABEL_SIZE.width / 2.f;
        alertLabel.layer.borderColor = RGB(207.f, 33.f, 39.f).CGColor;
        alertLabel.layer.borderWidth = 1.f;
        alertLabel.layer.masksToBounds = YES;
        alertLabel.backgroundColor = [UIColor whiteColor];
        
        [alertLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15.f]];
        [alertLabel setTextColor:RGB(207.f, 33.f, 39.f)];
        [alertLabel setTextAlignment:NSTextAlignmentCenter];
        
        [self addSubview:alertLabel];
        [self bt_layoutAlertLabel];
    }
    
    return alertLabel;
}

- (void)bt_hideAlertLabel:(BOOL)hide {
    UILabel *alertLabel = self._alertLabel;
    if (alertLabel) {
        [alertLabel setHidden:hide];
    }
}

- (void)bt_removeAlertLabel {
    UILabel *alertLabel = self._alertLabel;
    if (alertLabel) {
        [alertLabel removeFromSuperview];
    }
}

- (void)bt_layoutAlertLabel {
    self._alertLabel.frame = CGRectMake(self.bounds.size.width / 2.f,
                                        self.bounds.size.height / 2.f - ALERT_LABEL_SIZE.height,
                                        ALERT_LABEL_SIZE.width,
                                        ALERT_LABEL_SIZE.height);
}
@end
