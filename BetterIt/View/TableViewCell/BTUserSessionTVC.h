//
//  BTUserSessionTVC.h
//  BetterIt
//
//  Created by Maikel on 3/5/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTMessageSessionTVC.h"

@class BTUserSessionTVC;

@protocol BTUserSessionTVCDelegate <NSObject>
- (void)userSessionTVCDidTapViewRewards:(BTUserSessionTVC *)userSessionTVC;
@end

@interface BTUserSessionTVC : BTMessageSessionTVC
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (strong, nonatomic) IBOutlet UIImageView *imgReward;

@property (weak, nonatomic) BTMessageSession *messageSession;

@property (assign, nonatomic) id<BTUserSessionTVCDelegate> delegate;
@end
