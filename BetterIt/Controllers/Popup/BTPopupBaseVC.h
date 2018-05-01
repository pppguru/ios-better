//
//  BTPopupBaseVC.h
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTPopupBaseVC : UIViewController
@property (weak, nonatomic) IBOutlet UIView *contentView;

// to be overrided by child
- (CGFloat)contentViewYOffsetWhenKeyboardShown;

@end
