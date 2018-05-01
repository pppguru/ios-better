//
//  BTPasscodeTextField.h
//  BetterIt
//
//  Created by Jayden on 25/11/15.
//  Copyright © 2015 Jayden. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BTPasscodeTextFieldDelegate;

@interface BTPasscodeTextField : UITextField <UIKeyInput>

@property (assign, nonatomic) id<BTPasscodeTextFieldDelegate> backspaceDelegate;

@end


@protocol BTPasscodeTextFieldDelegate <NSObject>

- (void)textFieldDidDelete:(BTPasscodeTextField *)textField;

@end