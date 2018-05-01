//
//  BTObject.m
//  BetterIt
//
//  Created by devMac on 15/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTObject.h"

@implementation BTObject

#pragma mark - Mantle

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{@"objectId" : @"id",
             @"createdAt" : @"created_at",
             @"updatedAt" : @"updated_at",
             @"deletedAt" : @"deleted_at"};
}

+ (NSValueTransformer *)objectIdJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [self dateTransformer];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [self dateTransformer];
}

+ (NSValueTransformer *)deletedAtJSONTransformer {
    return [self dateTransformer];
}



#pragma mark Transformers

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        dateFormatter.dateFormat = @"yyyy-MM-dd' 'HH:mm:ss";
    }
    
    return dateFormatter;
}

+ (NSValueTransformer *)dateTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [BTObject.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [BTObject.dateFormatter stringFromDate:date];
    }];
}

+ (NSNumberFormatter *)numberFormatter {
    static NSNumberFormatter *numberFormatter;

    if (!numberFormatter) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    
    return numberFormatter;
}

+ (NSValueTransformer *)numberTransformer {
    return [MTLValueTransformer transformerWithBlock:^id(id inObj) {
        if (!inObj || inObj == NSNull.null) {
            return @(0);
            
        } else if ([inObj isKindOfClass:[NSString class]]) {
            NSNumber *numObj = [self.numberFormatter numberFromString:inObj];
            if (numObj) {
                return numObj;
            }
            return @(0);
            
        } else {
            return inObj;
        }
    }];
}

+ (NSValueTransformer *)modelTransformerWithClass:(Class)modelClass {
    return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *JSONDictionary) {
        if ([JSONDictionary isKindOfClass:[NSString class]]) {
            return nil;
        }
        
        return [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:JSONDictionary error:nil];
    }];
}

#pragma mark - Initializer

+ (id)objectWithJSONDictionary:(NSDictionary *)JSONDictionary {
    NSError *error = nil;
    
    id obj = [MTLJSONAdapter modelOfClass:[self class] fromJSONDictionary:JSONDictionary error:&error];
    
    if (error) {
        //NSLog(@"Error parsing JSON Dictionary - %@\nError - %@", JSONDictionary, error);
    }
    
    return obj;
}

+ (NSArray *)objectsWithJSONArray:(NSArray *)JSONArray {
    NSError *error = nil;
    
    NSArray *objs = [MTLJSONAdapter modelsOfClass:[self class] fromJSONArray:JSONArray error:&error];
    
    if (error) {
        //NSLog(@"Error parsing JSON Array - %@\nError - %@", JSONArray, error);
    }
    
    return objs;
}

- (NSDictionary *)JSONDictionary {
    return [MTLJSONAdapter JSONDictionaryFromModel:self];
}



#pragma mark - Getters & Setters

- (NSString *)objectIdString {
    return NSStringFromObjectId(self.objectId);
}
@end
