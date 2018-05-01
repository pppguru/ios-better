//
//  BTUserSessionTVC.m
//  BetterIt
//
//  Created by Maikel on 3/5/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTUserSessionTVC.h"
#import "BTModel.h"
#import "NSDate+Additions.h"
#import "Common.h"



@interface BTUserSessionTVC ()
@property (strong, nonatomic) IBOutlet UIButton *btnViewReward;
@property (weak, nonatomic) IBOutlet UIImageView *imgUnreadIndicator;

@end

@implementation BTUserSessionTVC

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageSession:(BTMessageSession *)messageSession {
    _messageSession = messageSession;
    
    _lblTitle.text = messageSession.business.name;
    
    BTMessage *lastMessage = messageSession.lastReplyMessage;
    
    if (lastMessage.hasImage) {
         _lblSubTitle.attributedText = [[NSAttributedString alloc] initWithString:(lastMessage.type == BTMessageTypeIncentive ? @"Reward" : @"Photo")
                                                                       attributes:@{
                                                                                    NSForegroundColorAttributeName : DEFAULT_TEXT_COLOR,
                                                                                    NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:13.f]
                                                                                    }];

    } else {
        _lblSubTitle.text = lastMessage.text;
    }
    
    _lblTimestamp.text = [messageSession.updatedAt bt_timeElapsedDescription];
    
    BTMessageFeedbackSubType feedbackType = (BTMessageFeedbackSubType)messageSession.firstMessage.type;
    
    NSString *imageString;
    switch (feedbackType) {
        case BTMessageFeedbackSubTypePositive:
            imageString = @"icn_thumbsup";
            break;
            
        case BTMessageFeedbackSubTypeNegative:
            imageString = @"icn_thumbsdown";
            break;
            
        default:
            imageString = @"icn_ideas";
            break;
    }
    _imgIcon.image = [UIImage imageNamed:imageString];
    
    _imgUnreadIndicator.hidden = (messageSession.unreadMessages == 0);

    NSArray *incentives = messageSession.incentives;

    _imgReward.hidden = (incentives.count == 0);

    BOOL hasUnused = NO;
    for (BTIncentive *incentive in incentives) {
        if (!incentive.used) {
            hasUnused = YES;
            break;
        }
    }
    
    _imgReward.image = [UIImage imageNamed: hasUnused ? @"icn_rewardSent" : @"icn_rewardUsed"];
    
    _btnViewReward.hidden = !hasUnused;
}

- (IBAction)viewRewardsAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(userSessionTVCDidTapViewRewards:)]) {
        [self.delegate userSessionTVCDidTapViewRewards:self];
    }
}

@end
