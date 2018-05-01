//
//  BTSurveyTVC.h
//  BetterIt
//
//  Created by Maikel on 22/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTTemplateCell.h"

@class BTSurvey;

@interface BTSurveyTVC : UITableViewCell <BTTemplateCell>
@property (weak, nonatomic) BTSurvey *surveyObject;
@end
