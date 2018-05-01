//
//  BTProfileSetupFinalVC.h
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTPopupBaseVC.h"

@class BTProfileSetupFinalVC;




@protocol BTProfileSetupFinalVCDelegate <NSObject>

- (void)profileSetupFinalVC:(BTProfileSetupFinalVC *)finalVC didEnterPin:(NSString *)pin Email:(NSString *)email;

@end




@interface BTProfileSetupFinalVC : BTPopupBaseVC

@property(assign, nonatomic) id<BTProfileSetupFinalVCDelegate> delegate;

@end
