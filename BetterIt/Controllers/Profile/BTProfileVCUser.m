//
//  BTProfileVCUser.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTProfileVCUser.h"
#import "BTRootVC.h"
#import "Common.h"
#import "BTProfileSetupController.h"
#import "BTConfig.h"
#import "BTStatisticsView.h"
#import "BTModel.h"
#import "BTRestClient.h"
#import "BTNavigationController.h"
#import "NSString+Additions.h"
#import "UIView+AlertLabel.h"
#import <UIAlertView+Blocks.h>
#import <Google/Analytics.h>


@interface BTProfileVCUser () <UIScrollViewDelegate, UINavigationControllerDelegate, UITextFieldDelegate, BTProfileSetupControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblNoUsername;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblNoEmail;

@property (weak, nonatomic) IBOutlet UIButton *btnEdit;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (copy, nonatomic) BTUser *currentUser;

@property (assign, nonatomic) BOOL isEditing;
@property (assign, nonatomic) BOOL didTapAddEmail;
@end


@implementation BTProfileVCUser

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUserProfile) name:RestClientDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCharts) name:ModelMessagesUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCharts) name:ModelMessageSessionsUpdatedNotification object:nil];

    [self loadUserProfile];
    [self refreshCharts];
    
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

- (IBAction)changeUserTypeAction:(id)sender {
    if ([Model userForType:BTUserTypeBusiness] && ![Model currentUser].allowDemo) {
        // if already setup the business, just go to business screen
        Model.currentUserType = BTUserTypeBusiness;
        [RootVC reloadPages];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ModelUserUpdatedNotification object:nil];
    } else {
        // if not, show business profile controller
        [self performSegueWithIdentifier:@"BusinessProfileSetupSegue" sender:nil];
    }
}

- (IBAction)editAction:(id)sender {
    
    if (_isEditing) {
        
        if (![_tfEmail.text isEqualToString:Model.currentUser.email] ||
            ![_tfUsername.text isEqualToString:Model.currentUser.username]) {
            
            [RestClient updateUser:Model.currentUserTypeString.lowercaseString
                           Profile:@{@"email" : _tfEmail.text,
                                     @"name" : _tfUsername.text}
                        Completion:^(BOOL success, NSString *code, id response) {
                            if (!success) {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                    message:response[@"msg"]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"Dismiss"
                                                                          otherButtonTitles:nil];
                                [alertView show];
                                
                                [self loadUserProfile];
                                
                            } else {
                                Model.currentUser = _currentUser.copy;
                            }
                        }];;
        }
        
        // save changes
        _currentUser.email = _tfEmail.text;
        _currentUser.username = _tfUsername.text;
        
        [self.view endEditing:YES];
    }
    
    _isEditing = !_isEditing;
    _didTapAddEmail = NO;
    
    [_btnEdit setTitle:(_isEditing ? nil : @"Edit") forState:UIControlStateNormal];
    [_btnEdit setImage:(_isEditing ? [UIImage imageNamed:@"btn_profile_done"] : nil) forState:UIControlStateNormal];
    _btnEdit.enabled = _isEditing ? [self isUsernameValid:_tfUsername.text] && [self isEmailValid:_tfEmail.text] : YES;
    
    [self refreshAccountView];
    
    if (_isEditing && !_tfEmail.isFirstResponder) {
        [_tfUsername becomeFirstResponder];
    }
}



#pragma mark - Profile Setup Controller Delegate

- (void)profileSetupController:(BTProfileSetupController *)setupController didFinishSetup:(BOOL)success {
//    BTUser *businessUser = [Model userForType:BTUserTypeBusiness];
//    
//    businessUser.email = setupController.email;
//    businessUser.pinCode = setupController.pinCode;
//    
//    [Model setUser:businessUser forType:BTUserTypeBusiness];
//    
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (success) {
            Model.currentUserType = BTUserTypeBusiness;
            [RootVC reloadPages];
        }
    }];
}



#pragma mark - Account View

- (void)loadUserProfile {
    _currentUser = Model.currentUser.copy;
    
    [self refreshAccountView];
}

- (void)refreshAccountView {
    _tfUsername.text = _currentUser.username;
    _tfEmail.text = _currentUser.email;
    
//    _tfUsername.enabled = _tfEmail.enabled = _isEditing;
    
    if (!_isEditing && [_tfEmail.text isEqualToString:@""]) {
        UILabel *alertLabel = [_tfEmail bt_alertLabel];
        alertLabel.text = @"!";
        [alertLabel setFrame:CGRectMake(_tfEmail.bounds.size.width - ALERT_LABEL_SIZE.width,
                                       (_tfEmail.bounds.size.height - ALERT_LABEL_SIZE.height) / 2.f,
                                       ALERT_LABEL_SIZE.width,
                                        ALERT_LABEL_SIZE.height)];
        [_tfEmail bt_hideAlertLabel:NO];
    } else {
        [_tfEmail bt_hideAlertLabel:YES];
    }
}




#pragma mark - Incentives View

- (void)refreshCharts {
    for (int i = 1; i <= 4; i++) {
        [self refreshChartView:[_scrollView viewWithTag:i] atIndex:i];
    }
}

- (void)refreshChartView:(UIView *)chartView atIndex:(NSInteger)index {
    if (!chartView) {
        return;
    }

    static NSDictionary *titleAttributes = nil, *bodyAttributes = nil;
    if (!titleAttributes) {
        titleAttributes = @{
                            NSFontAttributeName : [UIFont fontWithName:@"Gotham-Bold" size:14.f],
                            NSForegroundColorAttributeName : DEFAULT_TEXT_COLOR
                            };
    }
    if (!bodyAttributes) {
        bodyAttributes = @{
                           NSFontAttributeName : [UIFont fontWithName:@"Gotham-Medium" size:12.f],
                           NSForegroundColorAttributeName : DEFAULT_TEXT_COLOR
                           };
    }
    
    static UIFont *normalFont = nil, *emptyFont = nil;
    if (!normalFont) {
        normalFont = [UIFont fontWithName:@"Gotham-Medium" size:22.f];
    }
    if (!emptyFont) {
        emptyFont = [UIFont fontWithName:@"Gotham-Medium" size:40.f];
    }
    
    NSArray *messageSessions = Model.messageSessions;
    
    UILabel *lblStat = (UILabel *)[chartView viewWithTag:102];
    UILabel *lblDescription = (UILabel *)[chartView viewWithTag:103];
    
    NSString *titleText = nil, *bodyText = nil;
    switch (index) {
        case 1:
        {
            titleText = @"Rewards Received";
            
            int incentiveCount = 0, unusedIncentiveCount = 0;
            for (BTMessageSession *messageSession in messageSessions) {
                incentiveCount += messageSession.incentives.count;
                for (BTIncentive *incentive in messageSession.incentives) {
                    if (!incentive.used) {
                        unusedIncentiveCount++;
                    }
                }
            }
            
            if (incentiveCount) {
                NSString *totalString, *unusedString;
                if (incentiveCount == 1) {
                    totalString = @"1 reward";
                } else {
                    totalString = [NSString stringWithFormat:@"%d rewards", incentiveCount];
                }
                if (unusedIncentiveCount == 0) {
                    unusedString = @"no unused rewards";
                } else if (unusedIncentiveCount == 1) {
                    unusedString = @"1 unused reward";
                } else {
                    unusedString = [NSString stringWithFormat:@"%d unused rewards", unusedIncentiveCount];
                }
                bodyText = [NSString stringWithFormat:@"You've received %@ and have %@. Keep leaving helpful feedback to get more rewards!", totalString, unusedString];
                
                lblStat.font = normalFont;
                lblStat.text = [NSString stringWithFormat:@"%d", incentiveCount];
                
            } else {
                bodyText = @"You haven't received any rewards yet. Keep leaving helpful feedback to get discounts and free stuff!";
                lblStat.font = emptyFont;
                lblStat.text = @"+";
            }

            break;
        }
        case 2:
        {
            titleText = @"Feedback Helpfulness Rating";
            
            NSDate *threshold = [[NSDate date] dateByAddingTimeInterval:-30 * 24 * 60 * 60];
            CGFloat total = 0.f, helpful = 0.f;
            for (BTMessageSession *session in messageSessions) {
                BTMessage *msgBusinsessState = session.lastBusinessStateMessage;
                if (msgBusinsessState && [threshold compare:msgBusinsessState.createdAt] != NSOrderedDescending) {
                    total++;
                    if (msgBusinsessState.type == BTMessageTypeBusinessStatePositive) {
                        helpful++;
                    }
                }
            }

            bodyText = @"The more helpful your feedback is, the more likely you are to receive rewards.";
            
            if (total) {
                lblStat.font = normalFont;
                lblStat.textColor = DEFAULT_GOLD_COLOR;
                lblStat.text = [NSString stringWithFormat:@"%d%%", (int)(helpful / total * 100)];
            } else {
                lblStat.font = emptyFont;
                lblStat.textColor = DEFAULT_GREEN_COLOR;
                lblStat.text = @"+";
            }

            break;
        }
        case 3:
        {
            titleText = @"Feedback by Type";
            
            int positive = 0, negative = 0, idea = 0;
            for (BTMessageSession *session in messageSessions) {
                switch (session.firstMessage.type) {
                    case BTMessageTypeFeedbackPositive:
                        positive++;
                        break;
                    case BTMessageTypeFeedbackNegative:
                        negative++;
                        break;
                    case BTMessageTypeFeedbackIdea:
                        idea++;
                        break;
                    default:
                        break;
                }
            }
            
            bodyText = @"Each piece of feedback is an opportunity to improve the places you go.";
         
            UILabel *lblPositive = (UILabel *)[chartView viewWithTag:102];
            UILabel *lblNegative = (UILabel *)[chartView viewWithTag:104];
            UILabel *lblIdea = (UILabel *)[chartView viewWithTag:105];
            
            lblPositive.text = positive ? [NSString stringWithFormat:@"%d", positive] : @"--";
            lblNegative.text = negative ? [NSString stringWithFormat:@"%d", negative] : @"--";
            lblIdea.text = idea ? [NSString stringWithFormat:@"%d", idea] : @"--";

            break;
        }
        case 4:
        {
            titleText = @"Feedback Left for Recent Places";
            
//            statString = @"----";
            bodyText = @"The recent places list makes it easy to leave feedback for the places you've been.";
            break;
        }
        default:
            break;
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    if (titleText) {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:titleText attributes:titleAttributes]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:titleAttributes]];
    }
    if (bodyText) {
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:bodyAttributes]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:bodyText attributes:bodyAttributes]];
    }
    lblDescription.attributedText = attributedString;
}


#pragma mark - Banned Words

- (NSArray *)bannedWords {
    static NSArray *bannedWords;
    if (!bannedWords) {
        bannedWords = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"banned_words" ofType:@"plist"]];
    }
    return bannedWords;
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _pageControl.currentPage = round(scrollView.contentOffset.x / scrollView.bounds.size.width);
}



#pragma mark - Text Field

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!_isEditing) {
        [self editAction:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSString *email = nil, *username = nil;
    if ([textField isEqual:_tfUsername]) {
        if (text.length > 15) {
            return NO;
        }
        username = text;
        email = _tfEmail.text;
    } else if ([textField isEqual:_tfEmail]) {
        username = _tfUsername.text;
        email = text;
    }
    
    if (username && email) {
        BOOL isUsernameValid = [self isUsernameValid:username];
        BOOL isEmailValid = [self isEmailValid:email];
        
        _lblNoUsername.hidden = isUsernameValid;
        _lblNoEmail.hidden = isEmailValid;
        _btnEdit.enabled = isUsernameValid && isEmailValid;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self isUsernameValid:_tfUsername.text] && [self isEmailValid:_tfEmail.text]) {
        [self editAction:nil];
    } else {
        [textField resignFirstResponder];
    }

    return NO;
}

- (BOOL)isUsernameValid:(NSString *)text {
    NSString *errMsg = nil;
    if ([@"" isEqualToString:text]) {
        errMsg = @"Username can not be empty.";
    } else if ([[self bannedWords] containsObject:text.lowercaseString]) {
        errMsg = @"Username not allowed.";
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.length > 3) AND (%@ CONTAINS[cd] SELF)", text];
        NSArray *bannedWords = [[self bannedWords] filteredArrayUsingPredicate:predicate];
        if (bannedWords.count) {
            errMsg = @"Username not allowed.";
        }
    }
    
    return (errMsg == nil);
}

- (BOOL)isEmailValid:(NSString *)text {
    NSString *errMsg = nil;
    if ([@"" isEqualToString:text]) {
        // valid username and no email address, valid use-case
//        errMsg = @"Email cannot be empty.";
    } else if (![text bt_isValidEmail]) {
        // valid username, and email address is provided, but not in correct format
        errMsg = @"Invalid email address!";
    }
    
    return (errMsg == nil);
}


#pragma mark - Nvigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"BusinessProfileSetupSegue"]) {
        BTProfileSetupController *setupController = (BTProfileSetupController *)segue.destinationViewController;
        setupController.delegate = self;
    }
}


@end
