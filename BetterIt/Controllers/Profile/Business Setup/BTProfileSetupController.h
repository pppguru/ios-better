//
//  BTProfileSetupController.h
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>




extern NSString * const kVerificationStatusUpdated;

typedef enum BTVerificationStatusType {
    BTVerificationStatusCalling,
    BTVerificationStatusSuccess,
    BTVerificationStatusFailure
} BTVerificationStatus;




@class BTProfileSetupController;
@class BTBusiness;
@class BTUser;

@protocol BTProfileSetupControllerDelegate <NSObject>

- (void)profileSetupController:(BTProfileSetupController *)setupController didFinishSetup:(BOOL)success;

@end





@interface BTProfileSetupController : UINavigationController

@property (strong, nonatomic) BTBusiness *selectedBusiness;
@property (strong, nonatomic) BTUser *businessUser;

@property (copy, nonatomic) NSString *verificationCode;
@property (assign, nonatomic) BTVerificationStatus verificationStatus;

@property(assign, nonatomic) id<BTProfileSetupControllerDelegate, UINavigationControllerDelegate> delegate;

- (void)didFinishSetup;

@end
