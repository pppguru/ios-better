//
//  NSString+ProfanityDetector.m
//  BetterIt
//
//  Created by Matias Pan on 2/17/16.
//  Copyright © 2016 Maikel. All rights reserved.
//

#import "NSString+ProfanityDetector.h"
#import <IODProfanityFilter.h>

@implementation NSString (ProfanityDetector)

- (BOOL)containsProfanity {
    return [IODProfanityFilter rangesOfFilteredWordsInString:self].count > 0;
}

@end
