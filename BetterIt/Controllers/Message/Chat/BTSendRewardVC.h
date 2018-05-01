//
//  BTSendReward.h
//  BetterIt
//
//  Created by Maikel on 4/2/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTPopupBaseVC.h"

@class BTSendRewardVC;
@class BTIncentive;

@protocol BTSendRewardVCDelegate <NSObject>
- (void)sendRewardVC:(BTSendRewardVC *)sendRewardVC didCreateIncentive:(BTIncentive *)incentive;
@end

@interface BTSendRewardVC : BTPopupBaseVC
@property (assign, nonatomic) id<BTSendRewardVCDelegate> delegate;
@end
