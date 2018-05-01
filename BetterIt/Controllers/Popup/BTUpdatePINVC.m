//
//  BTUpdatePINVC.m
//  BetterIt
//
//  Created by devMac on 20/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTUpdatePINVC.h"
#import "UIView+Gradient.h"
#import "Common.h"
#import "NSString+Additions.h"
#import "BTPasscodeTextField.h"


#define PIN_TAG_BASE 1000


@interface BTUpdatePINVC () <UITextFieldDelegate, BTPasscodeTextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblError;
@property (weak, nonatomic) IBOutlet UIView *originalPINView;
@property (weak, nonatomic) IBOutlet UIView *enterPINView;
@property (weak, nonatomic) IBOutlet UIView *confirmPINView;
@end




@implementation BTUpdatePINVC {
    CGColorRef normalColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self resetView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Actions

- (IBAction)updateAction:(id)sender {
    NSString *originalPINCode = [self getPINCodeFromView:_originalPINView];
    NSString *enterPINCode = [self getPINCodeFromView:_enterPINView];
    NSString *confirmPINCode = [self getPINCodeFromView:_confirmPINView];

    [self resetView];
    
    NSString *errMsg = nil;
    
    if ((_originalPINCode.length == 0 && originalPINCode.length != 0) ||
        (_originalPINCode.length != 0 && ![originalPINCode.MD5 isEqualToString:_originalPINCode])) {
        
        [self highlightPINCodeView:_originalPINView];
        errMsg = @"please enter it again";
        
    } else if (enterPINCode.length != 4) {
        [self highlightPINCodeView:_enterPINView];
        errMsg = @"please enter new pin again";
        
    } else if (confirmPINCode.length != 4) {
        [self highlightPINCodeView:_confirmPINView];
        errMsg = @"please enter confirm pin again";
        
    } else if (![enterPINCode isEqualToString:confirmPINCode]) {
        [self highlightPINCodeView:_enterPINView];
        [self highlightPINCodeView:_confirmPINView];
        errMsg = @"inputs do not match";
    }
    
    if (errMsg) {
        _lblError.text = [NSString stringWithFormat:@"Error - %@", errMsg];
        _lblError.hidden = NO;
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(updatePINVC:didEnterNewPIN:)]) {
        [self.delegate updatePINVC:self didEnterNewPIN:enterPINCode.MD5];
    }
}

- (IBAction)closeAction:(id)sender {
    __weak typeof (self) weakSelf = self;
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([weakSelf.delegate respondsToSelector:@selector(updatePINVCDidCancel:)]) {
            [weakSelf.delegate updatePINVCDidCancel:weakSelf];
        }
    }];
}


#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length == 0) {
        return YES;
    } else if (string.length > 1) {
        return NO;
    }
    
    UITextField *nextTextField = (UITextField *)[textField.superview viewWithTag:(textField.tag + 1)];
    if (!nextTextField && [textField.superview isEqual:_enterPINView]) {
        nextTextField = (UITextField *)[_confirmPINView viewWithTag:PIN_TAG_BASE];
    }
    
    if (nextTextField) {
        [nextTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    textField.text = string;
   
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // hide error message if user starts inputting again
    if (!_lblError.hidden) {
        [self resetView];
    }
}

#pragma mark - BTPasscodeTextFieldDelegate

- (void)textFieldDidDelete:(BTPasscodeTextField *)textField {
    if (textField.text.length == 0) {
        UITextField *prevTextField = (UITextField *)[textField.superview viewWithTag:(textField.tag - 1)];
        if (!prevTextField && [textField.superview isEqual:_confirmPINView]) {
            prevTextField = (UITextField *)[_enterPINView viewWithTag:PIN_TAG_BASE+3];
        }
        
        if (prevTextField) {
            [prevTextField becomeFirstResponder];
        } else {
            [textField resignFirstResponder];
        }

        prevTextField.text = @"";
    }
}


#pragma mark - Misc

- (void)resetView {
    [self resetPINCodeView:_originalPINView];
    [self resetPINCodeView:_enterPINView];
    [self resetPINCodeView:_confirmPINView];
    _lblError.hidden = YES;
}

- (void)highlightPINCodeView:(UIView *)PINView {
    for (int i = 0; i < 4; i++) {
        UITextField *textField = (UITextField *)[PINView viewWithTag:(PIN_TAG_BASE + i)];
        textField.layer.borderColor = RGB(207.f, 33.f, 39.f).CGColor;
        textField.layer.borderWidth = .5f;
        textField.layer.cornerRadius = 5.f;
    }
}

#pragma mark PIN Code View

- (void)resetPINCodeView:(UIView *)PINView {
    for (int i = 0; i < 4; i++) {
        BTPasscodeTextField *textField = (BTPasscodeTextField *)[PINView viewWithTag:(PIN_TAG_BASE + i)];
        textField.text = @"";
        textField.tintColor = [UIColor clearColor];
        textField.layer.borderWidth = 0.f;
        
        textField.backspaceDelegate = self;
    }
}

- (NSString *)getPINCodeFromView:(UIView *)PINView {
    NSMutableString *PINCode = [NSMutableString new];
    for (int i = 0; i < 4; i++) {
        UITextField *nextTextField = (UITextField *)[PINView viewWithTag:(PIN_TAG_BASE + i)];
        [PINCode appendString:nextTextField.text];
    }
    return PINCode;
}




#pragma mark - Popup Base VC Overrides

- (CGFloat)contentViewYOffsetWhenKeyboardShown {
    return 100.f;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
