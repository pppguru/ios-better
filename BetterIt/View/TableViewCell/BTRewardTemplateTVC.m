//
//  BTRewardTemplateTVC.m
//  BetterIt
//
//  Created by Maikel on 02/07/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTRewardTemplateTVC.h"
#import "BTIncentive.h"



@interface BTRewardTemplateTVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblReward;

@end

@implementation BTRewardTemplateTVC

#pragma mark - Template Cell

+ (UINib *)cellNib {
    return [UINib nibWithNibName:@"BTRewardTemplateTVC" bundle:nil];
}

+ (NSString *)cellReuseIdentifier {
    return @"tvcRewardTemplate";
}

+ (CGFloat)cellHeight {
    return 44.f;
}

- (void)configureCell:(BTIncentive *)cellObject {
    _lblReward.text = cellObject.couponDescription;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
