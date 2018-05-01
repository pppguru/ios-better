//
//  BTProfileSetupFinalVC.m
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTProfileSetupFinalVC.h"
#import "UIView+Gradient.h"
#import "Common.h"
#import "NSString+Additions.h"
#import "BTPasscodeTextField.h"
#import <Google/Analytics.h>


#define PIN_TAG_BASE 1000




@interface BTProfileSetupFinalVC () <UITextFieldDelegate, BTPasscodeTextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *firstPINView;
@property (weak, nonatomic) IBOutlet UIView *secondPINView;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;

@end




@implementation BTProfileSetupFinalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self resetView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BTPasscodeTextField *textField = [_firstPINView viewWithTag:PIN_TAG_BASE];
    [textField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


#pragma mark - Overrides

- (CGFloat)contentViewYOffsetWhenKeyboardShown {
    return 80.f;
}

#pragma mark - Actions

- (IBAction)dashboardAction:(id)sender {
    NSString *errMsg = nil;
    
    NSString *firstPINCode = [self getPINCodeFromView:_firstPINView];
    if (firstPINCode.length != 4) {
        errMsg = @"You must provide PIN code!";
    }
    
    NSString *secondPINCode = [self getPINCodeFromView:_secondPINView];
    if (secondPINCode.length != 4) {
        errMsg = @"You must provide PIN code!";
    }
    
    if (![firstPINCode isEqualToString:secondPINCode]) {
        errMsg = @"Invalid PIN code!";
    }
    
    if (![_tfEmail.text bt_isValidEmail]) {
        errMsg = @"Invalid email address!";
    }
    
    if (errMsg) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errMsg delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
        
        [self resetView];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(profileSetupFinalVC:didEnterPin:Email:)]) {
        [self.delegate profileSetupFinalVC:self didEnterPin:firstPINCode Email:_tfEmail.text];
    }
}




#pragma mark - Text Field Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:_tfEmail]) {
        return YES;
    } else if (string.length == 0) {
        return YES;
    } else if (string.length > 1) {
        return NO;
    }
    
    textField.text = string;
    
    UITextField *nextTextField = (UITextField *)[textField.superview viewWithTag:(textField.tag + 1)];
    if (!nextTextField) {
        if ([textField.superview isEqual:_firstPINView]) {
            nextTextField = (UITextField *)[_secondPINView viewWithTag:PIN_TAG_BASE];
        } else if ([textField.superview isEqual:_secondPINView]) {
            nextTextField = _tfEmail;
        }
    }
    
    if (nextTextField) {
        [nextTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }

    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:_tfEmail]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - BTPasscodeTextFieldDelegate

- (void)textFieldDidDelete:(BTPasscodeTextField *)textField {
    if (textField.text.length == 0) {
        UITextField *prevTextField = (UITextField *)[textField.superview viewWithTag:(textField.tag - 1)];
        if (!prevTextField && [textField.superview isEqual:_secondPINView]) {
            prevTextField = (UITextField *)[_firstPINView viewWithTag:PIN_TAG_BASE+3];
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
    [self resetPINCodeView:_firstPINView];
    [self resetPINCodeView:_secondPINView];
    self.tfEmail.text = @"";
    [self.view endEditing:YES];
}

#pragma mark PIN Code View

- (void)resetPINCodeView:(UIView *)PINView {
    for (int i = 0; i < 4; i++) {
        BTPasscodeTextField *textField = (BTPasscodeTextField *)[PINView viewWithTag:(PIN_TAG_BASE + i)];
        textField.text = @"";
        textField.tintColor = [UIColor clearColor];
        
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


