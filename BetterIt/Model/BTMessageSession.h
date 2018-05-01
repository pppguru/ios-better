//
//  BTMessageSession.h
//  BetterIt
//
//  Created by devMac on 13/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTObject.h"

@class BTBusiness;
@class BTUser;
@class BTMessage;

@interface BTMessageSession : BTObject

@property (assign, nonatomic) NSUInteger businessId;
@property (assign, nonatomic) NSUInteger userId;

@property (copy, nonatomic) BTBusiness *business;
@property (copy, nonatomic) BTUser *user;
@property (copy, nonatomic) NSString *businessStatus;
@property (copy, nonatomic) NSString *userStatus;

@property (assign, nonatomic) BOOL isArchived;

- (NSArray *)messages;

- (NSArray *)incentiveMessages;
- (NSArray *)incentives;
- (NSUInteger)numberOfIncentives;

- (BTMessage *)firstMessage;
- (BTMessage *)lastReplyMessage;
- (BTMessage *)lastUserStateMessage;
- (BTMessage *)lastBusinessStateMessage;

- (NSInteger)unreadMessages;
@end
