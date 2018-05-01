//
//  BTSurvey.h
//  BetterIt
//
//  Created by Maikel on 21/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTObject.h"

#define SURVEY_SELECTION_TYPE_SINGLE   @"SINGLE"
#define SURVEY_SELECTION_TYPE_MULTIPLE @"MULTIPLE"

#define SURVEY_STATUS_LIVE   @"LIVE"
#define SURVEY_STATUS_DRAFT  @"DRAFT"
#define SURVEY_STATUS_PAUSED @"PAUSED"

#define SURVEY_TYPE_CUSTOM  @"CUSTOM"
#define SURVEY_TYPE_DEFAULT @"DEFAULT"
#define SURVEY_TYPE_FORTUNE @"FORTUNE"

@interface BTSurvey : BTObject
@property (copy, nonatomic) NSString *question;
@property (copy, nonatomic) NSArray *options;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *status;
@property (copy, nonatomic) NSArray *answers;
@property (copy, nonatomic) NSString *surveyType;

+ (id)surveyWithQuestion:(NSString *)question;

- (NSInteger)totalVotes;
- (NSInteger)positivePercentage;
- (NSInteger)positiveVotes;
- (NSInteger)negativeVotes;
- (NSNumber *)idForOptionNamed:(NSString *)option;
@end
