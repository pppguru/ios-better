//
//  BTSendReward.m
//  BetterIt
//
//  Created by Maikel on 4/2/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTSendRewardVC.h"
#import "Common.h"
#import "UIView+Gradient.h"
#import "BTIncentive.h"
#import <Google/Analytics.h>


@interface BTSendRewardVC () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *tfCode;
@property (strong, nonatomic) IBOutlet UITextField *tfDescription;
@property (strong, nonatomic) IBOutlet UITextField *tfExpirationDate;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) UITextField *selectedTextField;
@end




@implementation BTSendRewardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _tfExpirationDate.inputView = _datePicker;
    _tfCode.inputAccessoryView = _tfDescription.inputAccessoryView = _tfExpirationDate.inputAccessoryView = _toolBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


#pragma mark - Actions

- (IBAction)sendRewardAction:(id)sender {
    if (_tfCode.text.length &&
        _tfDescription.text.length &&
        _tfExpirationDate.text.length) {
        
        if ([self.delegate respondsToSelector:@selector(sendRewardVC:didCreateIncentive:)]) {
            BTIncentive *incentive = [[BTIncentive alloc] initWithCouponCode:_tfCode.text
                                                                 Description:_tfDescription.text
                                                                  ExpiryDate:_datePicker.date];
            
            [self.delegate sendRewardVC:self didCreateIncentive:incentive];
            
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Please input all the fields"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)prevAction:(id)sender {
    NSInteger currentTag = [_selectedTextField tag];
    UITextField *prevTextField = (UITextField *)[[_selectedTextField superview] viewWithTag:currentTag-1];
    if (prevTextField && [prevTextField isKindOfClass:[UITextField class]]) {
        [prevTextField becomeFirstResponder];
    }
}

- (IBAction)nextAction:(id)sender {
    NSInteger currentTag = [_selectedTextField tag];
    UITextField *prevTextField = (UITextField *)[[_selectedTextField superview] viewWithTag:currentTag+1];
    if (prevTextField && [prevTextField isKindOfClass:[UITextField class]]) {
        [prevTextField becomeFirstResponder];
    }
}

- (IBAction)doneInputAction:(id)sender {
    [self.view endEditing:YES];
}




#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _selectedTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:_tfExpirationDate]) {
        [self updateExpiryDateTextField];
    }
}

#pragma mark - MISC

- (void)updateExpiryDateTextField {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM dd YYYY";
    }
    
    _tfExpirationDate.text = [dateFormatter stringFromDate:_datePicker.date];
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
