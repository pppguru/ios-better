//
//  PaymentVC.h
//  BetterIt
//
//  Created by Maikel on 4/1/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Stripe.h>
#import "BTPopupBaseVC.h"



@class PaymentVC;

@protocol PaymentVCDelegate <NSObject>

- (void)paymentVC:(PaymentVC *)paymentVC didCreateToken:(STPToken *)token WithCard:(STPCard *)card;

@optional
- (void)paymentVCDidCancel:(PaymentVC *)paymentVC;

@end




@interface PaymentVC : BTPopupBaseVC
@property (assign, nonatomic) id<PaymentVCDelegate> delegate;
@end
