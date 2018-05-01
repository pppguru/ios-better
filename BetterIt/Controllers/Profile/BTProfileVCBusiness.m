//
//  BTProfileVCBusiness.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTProfileVCBusiness.h"
#import "BTNavigationController.h"
#import "BTModel.h"
#import "NSString+Additions.h"
#import "BTRestClient.h"
#import "BTUpdatePINVC.h"
#import "Common.h"
#import "BTSubscriptionVC.h"

#import <MessageUI/MessageUI.h>
#import <Google/Analytics.h>


@interface BTProfileVCBusiness () <UITextFieldDelegate, UpdatePINVCDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblNoEmail;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UILabel *lblSubscription;

@property (copy, nonatomic) BTUser *currentUser;
@property (assign, nonatomic) BOOL isEditing;

@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@property (weak, nonatomic) IBOutlet UIButton *btnEditPIN;
@property (weak, nonatomic) IBOutlet UIButton *btnEditEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnEditSubscription;

@end




@implementation BTProfileVCBusiness

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isEditing = NO;
    
    [self loadUserProfile];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserProfile) name:ModelUserUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSubscriptionView) name:ModelUserSubscriptionUpdatedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Actions
- (IBAction)callSupportAction:(id)sender {
    NSString *phNo = @"+17205230667";
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)emailSupportAction:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:[NSString stringWithFormat:@"Support Request from BetterIt User - %@", [Model userForType:BTUserTypeNormal].username]];
        [mail setToRecipients:@[@"support@betterit.io"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        //NSLog(@"This device cannot send email");
    }
}

- (IBAction)aboutAction:(id)sender {
    NSMutableString *text = [NSMutableString string];
    
    [text appendString:@"Version: "];
    [text appendString:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
    [text appendString:@"\nDevice: "];
    [text appendString:[DEVICE_TOKEN substringWithRange:NSMakeRange(0, 6)]];
    [text appendString:@"\n\nLove BetterIt and want to tell us? See something we could be doing better? Use search to select 'BetterIt' and give us your feedback!"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)editAction:(id)sender {
    if (_isEditing) {

        _currentUser.email = _tfEmail.text;
        
        if (![_currentUser.pinCode isEqualToString:Model.currentUser.pinCode] ||
            ![_currentUser.email isEqualToString:Model.currentUser.email]) {
            
            [RestClient updateUser:@"business" Profile:@{@"pincode" : _currentUser.pinCode.MD5, @"email" : _currentUser.email} Completion:^(BOOL success, NSString *code, id response) {
                if (success) {
                    // save changes
                    Model.currentUser = _currentUser;
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:response[@"msg"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Dismiss"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    
                    [self loadUserProfile];
                }
            }];
            
        }
        
        [self.view endEditing:YES];
        
    }
    
    _isEditing = !_isEditing;
    
    [_btnEdit setTitle:(_isEditing ? @"" : @"Edit") forState:UIControlStateNormal];
    [_btnEdit setImage:(_isEditing ? [UIImage imageNamed:@"btn_profile_done"] : nil) forState:UIControlStateNormal];
    _btnEdit.enabled = _isEditing ? [self isEmailValid:_tfEmail.text] : YES;

    [UIView animateWithDuration:.3f animations:^{
        [self refreshAccountView];
    }];
}

- (IBAction)editPINAction:(id)sender {
//    if (_isEditing) {
        [self performSegueWithIdentifier:@"EditPINCodeSegue" sender:nil];
//    }
}

- (IBAction)changeUserTypeAction:(id)sender {
    Model.currentUserType = BTUserTypeNormal;
    [RootVC reloadPages];
}

- (IBAction)editEmailAction:(id)sender {
    [_tfEmail becomeFirstResponder];
}

- (IBAction)editSubscriptionAction:(id)sender {
}

#pragma mark - MFMailComposeControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"We'll get back to you in less than 24 hours" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            //NSLog(@"You sent the email.");
            
            break;
        }
        case MFMailComposeResultSaved:
            //NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            //NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            //NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Update PIN VC Delegate

- (void)updatePINVC:(BTUpdatePINVC *)updatePINVC didEnterNewPIN:(NSString *)enteredPIN {
    _currentUser.pinCode = enteredPIN;
    
    [RestClient updateUser:@"business" Profile:@{@"pincode" : _currentUser.pinCode.MD5, @"email" : Model.currentUser.email} Completion:^(BOOL success, NSString *code, id response) {
    }];

    [updatePINVC dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!_isEditing) {
        [self editAction:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if ([self isEmailValid:text]) {
        _lblNoEmail.hidden = YES;
        _btnEdit.enabled = YES;
    } else {
        _lblNoEmail.hidden = NO;
        _btnEdit.enabled = NO;
    }
    
    return YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self isEmailValid:_tfEmail.text]) {
        [self editAction:nil];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

#pragma mark - MISC

- (BOOL)isEmailValid:(NSString *)text {
    NSString *errMsg = nil;
    if ([@"" isEqualToString:_tfEmail.text]) {
        // valid username and no email address, valid use-case
        errMsg = @"Email cannot be empty.";
    } else if (![_tfEmail.text bt_isValidEmail]) {
        // valid username, and email address is provided, but not in correct format
        errMsg = @"Invalid email address!";
    }
    
    return (errMsg == nil);
}

- (void)loadUserProfile {
    _currentUser = Model.currentUser.copy;
    [self refreshAccountView];
    [self refreshSubscriptionView];
}

- (void)refreshAccountView {
    _lblEmail.text = _tfEmail.text = _currentUser.email;
}

- (void)refreshSubscriptionView {
    BTSubscription *subscription = Model.currentUser.business.subscription;
    if (!subscription) {
        return;
    }

    NSString *planName = [subscription.subscriptionPlan isEqualToString:@"PRO"] ? @"BetterIt+Survey" : @"BetterIt";
    static NSDictionary *boldAttributes = nil, *normalAttributes = nil;
    static NSDateFormatter *dateFormatter = nil;
    if (!boldAttributes) {
        boldAttributes = @{
                           NSFontAttributeName : [UIFont fontWithName:@"Gotham-Bold" size:11.f],
                           NSForegroundColorAttributeName : DEFAULT_TEXT_COLOR
                           };
    }
    
    if (!normalAttributes) {
        normalAttributes = @{
                             NSFontAttributeName : [UIFont fontWithName:@"Gotham-Book" size:11.f],
                             NSForegroundColorAttributeName : DEFAULT_TEXT_COLOR
                             };
    }
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yy";
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Plan Name: " attributes:normalAttributes]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:planName attributes:boldAttributes]];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nAnnual subscription renewing on %@", [dateFormatter stringFromDate:subscription.expiryDate]] attributes:normalAttributes]];
    
    _lblSubscription.attributedText = attributedString;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"EditPINCodeSegue"]) {
        BTUpdatePINVC *updatePINVC = segue.destinationViewController;
        updatePINVC.originalPINCode = _currentUser.pinCode;
        updatePINVC.delegate = self;
    } else if ([segue.identifier isEqualToString:@"SubscriptionSegue"]) {
        BTSubscriptionVC *subscriptionVC = segue.destinationViewController;
        subscriptionVC.shouldShowCancelOption = YES;
    }
}


@end
