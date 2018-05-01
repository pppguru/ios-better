//
//  NSDate+Additions.m
//  BetterIt
//
//  Created by devMac on 15/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (NSString *)bt_timeElapsedDescription {
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Get conversion to months, days, hours, minutes
    NSDateComponents *dateComponents = [sysCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSWeekOfMonthCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                                      fromDate:self
                                                        toDate:[NSDate date]
                                                       options:0];
    
    // Return appropriate description string
    if (dateComponents.year) {
        return [NSString stringWithFormat:@"%ld year%@ ago", (long)dateComponents.year, dateComponents.year > 1 ? @"s" : @""];
        
    } else if (dateComponents.month) {
        return [NSString stringWithFormat:@"%ld month%@ ago", (long)dateComponents.month, dateComponents.month > 1 ? @"s" : @""];
        
    } else if (dateComponents.weekOfMonth) {
        return [NSString stringWithFormat:@"%ld week%@ ago", (long)dateComponents.weekOfMonth, dateComponents.weekOfMonth > 1 ? @"s" : @""];
        
    } else if (dateComponents.day) {
        return [NSString stringWithFormat:@"%ld day%@ ago", (long)dateComponents.day, dateComponents.day > 1 ? @"s" : @""];
        
    } else if (dateComponents.hour) {
        return [NSString stringWithFormat:@"%ld hour%@ ago", (long)dateComponents.hour, dateComponents.hour > 1 ? @"s" : @""];
        
    } else if (dateComponents.minute > 1) {
        return [NSString stringWithFormat:@"%ld minute%@ ago", (long)dateComponents.minute, dateComponents.minute > 1 ? @"s" : @""];
        
    } else {
        return @"just now";
    }
    
}

- (NSString *)bt_UTCString {
    return [[NSDate bt_UTCFormatter] stringFromDate:self];
}

#pragma mark - PRIVATE

static NSDateFormatter *_UTCFormatter = nil;

+ (NSDateFormatter *)bt_UTCFormatter {
    if (!_UTCFormatter) {
        _UTCFormatter = [[NSDateFormatter alloc] init];
        [_UTCFormatter setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
        [_UTCFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [_UTCFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    return _UTCFormatter;
}

@end
