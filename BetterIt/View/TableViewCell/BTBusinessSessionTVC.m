//
//  BTBusinessSessionTVC.m
//  BetterIt
//
//  Created by devMac on 20/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTBusinessSessionTVC.h"
#import "BTModel.h"
#import "NSDate+Additions.h"
#import "Common.h"

@interface BTBusinessSessionTVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imgUnreadIndicator;

@end

@implementation BTBusinessSessionTVC

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageSession:(BTMessageSession *)messageSession {
    _messageSession = messageSession;
    
    _lblTitle.text = _messageSession.user.username;
    
    BTMessage *lastMessage = _messageSession.lastReplyMessage;
    
    if (lastMessage.hasImage) {
        
        _lblSubTitle.attributedText = [[NSAttributedString alloc] initWithString:(lastMessage.type == BTMessageTypeIncentive ? @"Reward" : @"Photo")
                                                                      attributes:@{
                                                                                   NSForegroundColorAttributeName : DEFAULT_TEXT_COLOR,
                                                                                   NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:13.f]
                                                                                   }];
        
    } else {
        _lblSubTitle.text = lastMessage.text;
    }
    
    _lblTimestamp.text = [_messageSession.updatedAt bt_timeElapsedDescription];
    
    BTMessageFeedbackSubType feedbackType = (BTMessageFeedbackSubType)_messageSession.firstMessage.type;
    
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
    
    // incentives
    NSArray *incentives = _messageSession.incentives;
    
    _imgReward.hidden = (incentives.count == 0);
    
    BOOL hasUnused = NO;
    for (BTIncentive *incentive in incentives) {
        if (!incentive.used) {
            hasUnused = YES;
            break;
        }
    }
    
    _imgReward.image = [UIImage imageNamed: hasUnused ? @"icn_rewardSent" : @"icn_rewardUsed"];
    
    BTMessage *lastUserStateMessage = _messageSession.lastUserStateMessage;
    
    if (lastUserStateMessage) {
        _imgBusinessState.hidden = NO;
        
        if (lastUserStateMessage.type == BTMessageTypeUserStatePositive) {
            [_imgBusinessState setImage:[UIImage imageNamed:@"bizmesfeed_positivebubbleicon"]];
        } else {
            [_imgBusinessState setImage:[UIImage imageNamed:@"bizmesfeed_negativebubbleicon"]];
        }
        
    } else {
        _imgBusinessState.hidden = YES;
    }

}

@end
