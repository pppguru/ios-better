//
//  BTViewRewardsVC.h
//  BetterIt
//
//  Created by Maikel on 3/23/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTPopupBaseVC.h"

@class BTMessageSession;
@class BTMessage;

@interface BTViewRewardsVC : BTPopupBaseVC
@property (weak, nonatomic) BTMessageSession *messageSession;
@property (weak, nonatomic) BTMessage *initialIncentiveMessage;
@end
