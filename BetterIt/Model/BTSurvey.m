//
//  BTSurvey.m
//  BetterIt
//
//  Created by Maikel on 21/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTSurvey.h"

@implementation BTSurvey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
             @"surveyType" : @"survey_type"
             }];
}

+ (id)surveyWithQuestion:(NSString *)question {
    BTSurvey *survey = [[BTSurvey alloc] init];
    survey.question = question;
    survey.options = @[@"Y", @"N"];
    survey.type = @"SINGLE";
    survey.status = @"LIVE";
    return survey;
}

- (NSInteger)positivePercentage {
    if ([self totalVotes] == 0) {
        return 0;
    }
    return [self positiveVotes] * 100 / [self totalVotes];
}

- (NSInteger)positiveVotes {
    int optionId = [self idForOptionNamed:@"Y"].intValue;
    if (optionId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"options CONTAINS %@", [NSString stringWithFormat:@"\"%d\"", optionId]];
        return [_answers filteredArrayUsingPredicate:predicate].count;
    }
    return 0;
}

- (NSInteger)negativeVotes {
    int optionId = [self idForOptionNamed:@"N"].intValue;
    if (optionId) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"options CONTAINS %@", [NSString stringWithFormat:@"\"%d\"", optionId]];
        return [_answers filteredArrayUsingPredicate:predicate].count;
    }
    return 0;
}

- (NSInteger)totalVotes {
    return _answers.count;
}

- (NSNumber *)idForOptionNamed:(NSString *)optionName {
    for (NSDictionary *option in _options) {
        if ([optionName isEqualToString:option[@"option"]]) {
            return option[@"id"];
        }
    }
    
    return nil;
}


@end
