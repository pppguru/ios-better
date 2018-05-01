//
//  BTSubscription.h
//  BetterIt
//
//  Created by Maikel on 3/23/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTObject.h"

@interface BTSubscription : BTObject
@property (assign, nonatomic, readonly) NSUInteger businessId;
@property (copy, nonatomic, readonly) NSString *customerToken;
@property (copy, nonatomic, readonly) NSString *subscriptionId;
@property (copy, nonatomic, readonly) NSString *subscriptionPlan;
@property (copy, nonatomic, readonly) NSString *currentCarrier;
@property (copy, nonatomic, readonly) NSDate *expiryDate;
@end
