//
//  BTUpdatePINVC.h
//  BetterIt
//
//  Created by devMac on 20/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTPopupBaseVC.h"

@class BTUpdatePINVC;

@protocol UpdatePINVCDelegate <NSObject>

- (void)updatePINVC:(BTUpdatePINVC *)updatePINVC didEnterNewPIN:(NSString *)enteredPIN;

@optional
- (void)updatePINVCDidCancel:(BTUpdatePINVC *)updatePINVC;

@end




@interface BTUpdatePINVC : BTPopupBaseVC

@property (copy, nonatomic) NSString *originalPINCode;

@property (assign, nonatomic) id<UpdatePINVCDelegate> delegate;

@end
