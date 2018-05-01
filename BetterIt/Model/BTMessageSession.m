//
//  BTMessageSession.m
//  BetterIt
//
//  Created by devMac on 13/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTMessageSession.h"
#import "BTModel.h"




@implementation BTMessageSession

#pragma mark - Mantle

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:
            @{
              @"businessId" : @"business_id",
              @"business" : @"business",
              @"userId" : @"user_id",
              @"user" : @"user",
              @"businessStatus" : @"business_status",
              @"userStatus" : @"user_status"
              }];
}

+ (NSValueTransformer *)businessJSONTransformer {
    return [BTObject modelTransformerWithClass:[BTBusiness class]];
}

+ (NSValueTransformer *)userJSONTransformer {
    return [BTObject modelTransformerWithClass:[BTUser class]];
}

+ (NSValueTransformer *)businessIdJSONTransformer {
    return [self numberTransformer];
}

+ (NSValueTransformer *)userIdJSONTransformer {
    return [self numberTransformer];
}

- (NSArray *)messages {
    return [Model getAllMessagesInSession:self.objectId];
}

- (NSArray *)incentiveMessages {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d", BTMessageTypeIncentive];
    
    return [self.messages filteredArrayUsingPredicate:predicate];
}

- (NSArray *)incentives {    
    NSMutableArray *incentives = [NSMutableArray new];
    for (BTMessage *message in self.incentiveMessages) {
        if (message.incentive) {
            [incentives addObject:message.incentive];
        }
    }
    
    return incentives;
}

- (NSUInteger)numberOfIncentives {
    return self.incentiveMessages.count;
}

- (BTMessage *)firstMessage {
    return self.messages.firstObject;
}

- (BTMessage *)lastReplyMessage {
    static NSPredicate *predicate;
    if (!predicate) {
        predicate = [NSPredicate predicateWithFormat:@"type <= %d", BTMessageTypeIncentive];
    }
    
    return [self.messages filteredArrayUsingPredicate:predicate].lastObject;
}

- (BTMessage *)lastUserStateMessage {
    static NSPredicate *predicate;
    if (!predicate) {
        predicate = [NSPredicate predicateWithFormat:@"type == %d OR type == %d", BTMessageTypeUserStatePositive, BTMessageTypeUserStateNegative];
    }
    
    return [self.messages filteredArrayUsingPredicate:predicate].lastObject;
}

- (BTMessage *)lastBusinessStateMessage {
    static NSPredicate *predicate;
    if (!predicate) {
        predicate = [NSPredicate predicateWithFormat:@"type == %d OR type == %d", BTMessageTypeBusinessStatePositive, BTMessageTypeBusinessStateNegative];
    }
    
    return [self.messages filteredArrayUsingPredicate:predicate].lastObject;
}

- (BTUser *)user {
    if (Model.currentUserType == BTUserTypeNormal) {
        return Model.currentUser;
    }
    
    return _user;
}

- (BTBusiness *)business {
    if (Model.currentUserType == BTUserTypeBusiness) {
        return Model.currentUser.business;
    }
    
    return _business;
}

- (BOOL)isArchived {
    NSString *statusString = (Model.currentUserType == BTUserTypeNormal) ? self.userStatus : self.businessStatus;
    if (statusString && ![@"" isEqualToString:statusString]) {
        return YES;
    }
    return NO;
}

- (void)setIsArchived:(BOOL)isArchived {
    if (Model.currentUserType == BTUserTypeNormal) {
        self.userStatus = isArchived ? @"ARCHIVED" : @"";
    } else {
        self.businessStatus = isArchived ? @"ARCHIVED" : @"";
    }
}

- (NSInteger)unreadMessages {
    NSInteger unread = 0;
    for (BTMessage *message in [self messages]) {
        if (!message.readStatus) {
            unread++;
        }
    }
    
    return unread;
}

@end
