//
//  BTBusinessSessionTVC.h
//  BetterIt
//
//  Created by devMac on 20/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTMessageSessionTVC.h"

@interface BTBusinessSessionTVC : BTMessageSessionTVC
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (strong, nonatomic) IBOutlet UIImageView *imgReward;
@property (strong, nonatomic) IBOutlet UIButton *btnUserState;
@property (weak, nonatomic) IBOutlet UIImageView *imgBusinessState;

@property (weak, nonatomic) BTMessageSession *messageSession;
@end
