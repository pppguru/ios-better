//
//  BTSurveyManager.h
//  BetterIt
//
//  Created by Jayden on 30/10/15.
//  Copyright © 2015 Jayden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTSurveyManager : NSObject

+ (BOOL)isSurveyAnswered:(NSInteger)surveyId;
+ (void)answeredSurvey:(NSInteger)surveyId;

@end
