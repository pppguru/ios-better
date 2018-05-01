//
//  BTSurveyManager.m
//  BetterIt
//
//  Created by Jayden on 30/10/15.
//  Copyright © 2015 Jayden. All rights reserved.
//

#import "BTSurveyManager.h"
#import "NSArray+Plist.h"

static NSString * kSurveyCacheKey = @"survey_cache";

@implementation BTSurveyManager

#pragma mark - PUBLIC

+ (BOOL)isSurveyAnswered:(NSInteger)surveyId
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy/MM/dd";
    }
    
    NSMutableDictionary *cache = [self cache];
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)surveyId];
    
    NSDate *date = [cache objectForKey:key];
    if (date) {
        NSString *today = [dateFormatter stringFromDate:[NSDate date]];
        NSString *answeredDay = [dateFormatter stringFromDate:date];
        if (![today isEqualToString:answeredDay]) {
            [cache removeObjectForKey:key];
            [@[cache] bt_writeToPlistFile:kSurveyCacheKey];
            
            return NO;
        }
        
        return YES;
    }
    
    return NO;
}

+ (void)answeredSurvey:(NSInteger)surveyId
{
    NSMutableDictionary *cache = [self cache];
    
    NSString *key = [NSString stringWithFormat:@"%ld", (long)surveyId];
    
    [cache setObject:[NSDate date] forKey:key];
    [@[cache] bt_writeToPlistFile:kSurveyCacheKey];
}

#pragma mark - PRIVATE

+ (NSMutableDictionary *)cache
{
    static NSMutableDictionary *cache = nil;

    if (!cache) {
        NSArray *array = [NSArray bt_readFromPlistFile:kSurveyCacheKey];
        
        cache = [NSMutableDictionary dictionaryWithDictionary:array.firstObject];
        
        if (!cache) {
            cache = [NSMutableDictionary dictionary];
        }
    }
    
    return cache;
}


@end
