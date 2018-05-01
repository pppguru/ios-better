//
//  BTObject.h
//  BetterIt
//
//  Created by devMac on 15/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <Mantle.h>

#define NSStringFromObjectId(objectId) [NSString stringWithFormat:@"%ld", (unsigned long)objectId]

@interface BTObject : MTLModel <MTLJSONSerializing>

@property (assign, nonatomic) NSUInteger objectId;

@property (copy, nonatomic) NSDate *createdAt;
@property (copy, nonatomic) NSDate *updatedAt;
@property (copy, nonatomic) NSDate *deletedAt;

+ (id)objectWithJSONDictionary:(NSDictionary *)JSONDictionary;
+ (NSArray *)objectsWithJSONArray:(NSArray *)JSONArray;

- (NSDictionary *)JSONDictionary;

+ (NSDateFormatter *)dateFormatter;
+ (NSNumberFormatter *)numberFormatter;
+ (NSValueTransformer *)dateTransformer;
+ (NSValueTransformer *)numberTransformer;
+ (NSValueTransformer *)modelTransformerWithClass:(Class)modelClass;

- (NSString *)objectIdString;

@end
