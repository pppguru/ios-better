//
//  BTPasscodeTextField.m
//  BetterIt
//
//  Created by Jayden on 25/11/15.
//  Copyright © 2015 Jayden. All rights reserved.
//

#import "BTPasscodeTextField.h"

@implementation BTPasscodeTextField

- (BOOL)keyboardInputShouldDelete:(UITextField *)textField {
    BOOL shouldDelete = YES;
    
    if ([UITextField instancesRespondToSelector:_cmd]) {
        BOOL (*keyboardInputShouldDelete)(id, SEL, UITextField *) = (BOOL (*)(id, SEL, UITextField *))[UITextField instanceMethodForSelector:_cmd];
        
        if (keyboardInputShouldDelete) {
            shouldDelete = keyboardInputShouldDelete(self, _cmd, textField);
        }
    }
    
    BOOL isIos8 = ([[[UIDevice currentDevice] systemVersion] intValue] == 8);
    BOOL isLessThanIos8_3 = ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.3f);
    
    if (![textField.text length] && isIos8 && isLessThanIos8_3) {
        [self deleteBackward];
    }
    
    return shouldDelete;
}

- (void)deleteBackward {
    [super deleteBackward];

    if ([self.backspaceDelegate respondsToSelector:@selector(textFieldDidDelete:)]) {
        [self.backspaceDelegate textFieldDidDelete:self];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
