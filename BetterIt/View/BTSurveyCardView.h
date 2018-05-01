//
//  BTSurveyCardView.h
//  BetterIt
//
//  Created by Maikel on 21/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTCardView.h"
#import "BTBarChartView.h"

@interface BTSurveyCardView : BTCardView
@property (weak, nonatomic) IBOutlet BTBarChartView *chartView;

@end
