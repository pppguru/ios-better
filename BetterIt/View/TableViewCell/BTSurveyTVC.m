//
//  BTSurveyTVC.m
//  BetterIt
//
//  Created by Maikel on 22/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTSurveyTVC.h"
#import "BTBarChartView.h"
#import "BTSurvey.h"
#import "Common.h"

@interface BTSurveyTVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblQuestion;
@property (weak, nonatomic) IBOutlet BTBarChartView *barChartView;
@property (weak, nonatomic) IBOutlet UIImageView *disabledView;

@end

@implementation BTSurveyTVC

#pragma mark - Template Cell

+ (UINib *)cellNib {
    return [UINib nibWithNibName:@"BTSurveyTVC" bundle:nil];
}

+ (NSString *)cellReuseIdentifier {
    return @"tvcSurvey";
}

+ (CGFloat)cellHeight {
    return 88.f;
}

- (void)configureCell:(NSObject *)cellObject {
    _surveyObject = (BTSurvey *)cellObject;
    
    _lblQuestion.text = _surveyObject.question;
    _barChartView.percentage = _surveyObject.positivePercentage;
    _barChartView.isEmpty = (_surveyObject.totalVotes == 0);
    
    if ([_surveyObject.surveyType isEqualToString:SURVEY_TYPE_DEFAULT]) {
        _disabledView.hidden = NO;
        _disabledView.backgroundColor = DEFAULT_GOLD_COLOR;
        
    } else if (![SURVEY_STATUS_LIVE isEqualToString:_surveyObject.status]) {
        _disabledView.hidden = NO;
        _disabledView.backgroundColor = [UIColor lightGrayColor];
        
    } else {
        _disabledView.hidden = YES;
    }
}

#pragma mark - Cell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
