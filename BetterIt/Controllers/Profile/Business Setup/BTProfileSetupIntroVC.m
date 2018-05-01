//
//  BTProfileSetupIntroVC.m
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTProfileSetupIntroVC.h"
#import "BTProfileSetupController.h"
#import "UIView+Gradient.h"
#import "Common.h"
#import "BTRestClient.h"
#import "BTModel.h"
#import "BTSearchBusinessController.h"
#import <Google/Analytics.h>
#import "IAPShare.h"


@interface BTProfileSetupIntroVC () <BTSearchBusinessControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *lblVerificationCode;
@property (weak, nonatomic) IBOutlet UILabel *lblVerificationDescription;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnStartCall;
@property (weak, nonatomic) IBOutlet UIButton *btnCallSupport;

@property (weak, nonatomic) IBOutlet UILabel *lblBusinessName;
@property (weak, nonatomic) IBOutlet UILabel *lblBusinessAddress;

@property (weak, nonatomic) BTProfileSetupController *controller;

@property (weak, nonatomic) IBOutlet UIView *plan1View;
@property (weak, nonatomic) IBOutlet UIView *plan2View;
@property (weak, nonatomic) IBOutlet UIView *selectedPlanBackgroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedPlanBGTop_Y;
@property (assign, nonatomic) NSInteger selectedPlan;
@property (weak, nonatomic) IBOutlet UIButton *btnPay;
@property (weak, nonatomic) IBOutlet UILabel *lblBetterIts;
@end


@implementation BTProfileSetupIntroVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _controller = (BTProfileSetupController *)self.navigationController;
    
    _plan1View.layer.cornerRadius = 5.f;
    _plan1View.layer.masksToBounds = YES;
    [self setState:NO ForView:_plan1View];
    _plan2View.layer.cornerRadius = 5.f;
    _plan2View.layer.masksToBounds = YES;
    [self setState:YES ForView:_plan2View];
    
    _selectedPlan = 1;
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

- (IBAction)closeAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Page 1
#pragma mark Search Business Controller Delegate

- (void)searchBusinessController:(BTSearchBusinessController *)searchController didSelectBusiness:(BTBusiness *)business {
    _controller.selectedBusiness = business;
    _lblBusinessName.text = business.name;
    _lblBusinessAddress.text = [business.address stringByReplacingOccurrencesOfString:@", United States" withString:@""];
    
    if (Model.currentUser.allowDemo.boolValue) {
        [RestClient enableDemoModeWithCompletion:^(BOOL success, NSString *code, id response) {
            if (success) {
                [RestClient linkDemoBusiness:business.objectId Completion:^(BOOL success, NSString *code, id response) {
                    if (success) {
                        if (response[@"businessProfile"]) {
                            _controller.verificationStatus = BTVerificationStatusSuccess;
                            _controller.businessUser = [BTUser userWithBusinessProfile:response[@"businessProfile"]];
                            _controller.businessUser.business = business;
                            
                            [self businessVerificationStatusUpdated];
                        }
                    }
                    else{
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"The selected business is already in use." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }];
            }
        }];
    } else {
        [RestClient getBusinessVerificationCode:business.objectId Completion:^(BOOL success, NSString *code, id response) {
            
            if (success) {
                if (response[@"businessProfile"]) {
                    _controller.verificationStatus = BTVerificationStatusSuccess;
                    _controller.businessUser = [BTUser userWithBusinessProfile:response[@"businessProfile"]];
                    _controller.businessUser.business = business;
                    
                    [self businessVerificationStatusUpdated];
                } else {
                    _lblVerificationCode.text = response[@"verification_code"];
                    
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
                    NSDictionary *normalAttributes = @{
                                                       NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:15.f],
                                                       NSForegroundColorAttributeName : RGB(108.f, 108.f, 108.f)
                                                       };
                    NSDictionary *boldAttributes = @{
                                                     NSFontAttributeName: [UIFont fontWithName:@"Gotham-Bold" size:15.f],
                                                     NSForegroundColorAttributeName : RGB(108.f, 108.f, 108.f)
                                                     };
                    
                    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Click the button below to call\nyour listed business number\n" attributes:normalAttributes]];
                    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:business.phoneNumber attributes:boldAttributes]];
                    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@" then enter the\ncode below when prompted" attributes:normalAttributes]];
                    _lblVerificationDescription.attributedText = attributedString;
                    [self gotoPage:2];
                }
            } else {
                _lblVerificationCode.text = @"ERROR";
            }
            
        }];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
        
        [manager GET:[API_BASE_URL stringByAppendingPathComponent:@"/api/business/unclaimed"] parameters:@{@"place_id" : business.googlePlaceId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([responseObject[@"code"] isEqualToString:@""]) {
                NSNumber *unclaimed = responseObject[@"business"][@"unclaimed"];
                if ([unclaimed isKindOfClass:[NSNumber class]] && unclaimed.integerValue) {
                    _lblBetterIts.hidden = NO;
                    _lblBetterIts.text = [NSString stringWithFormat:@"You have %@ BetterIts waiting for response", unclaimed];
                }
            } else {
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    
    [searchController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Page 2

- (IBAction)callBusinessAction:(id)sender {
    [_activityIndicator startAnimating];
    _btnStartCall.enabled = NO;
    _btnCallSupport.enabled = NO;

#if !TARGET_IPHONE_SIMULATOR
    [RestClient initiateBusinessVerificationProcess:_controller.selectedBusiness.objectId Completion:^(BOOL success, NSString *code, id response) {
        if (success) {
#endif
            _controller.verificationStatus = BTVerificationStatusCalling;
            
            // start checking business verification status
            [self performSelector:@selector(checkBusinessVerificationStatus) withObject:nil afterDelay:5.f];
#if !TARGET_IPHONE_SIMULATOR
        } else {
            _controller.verificationStatus = BTVerificationStatusFailure;
            [self businessVerificationStatusUpdated];
        }
    }];
#endif
}

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

- (void)requestToCallBusinessForAutomaticVerification {
    
}

- (void)callSupportForManualVerification {
    
}

- (void)checkBusinessVerificationStatus {
    [RestClient checkBusinessVerificationStatus:_controller.selectedBusiness.objectId Completion:^(BOOL success, NSString *code, id response) {
        if (success) {
            NSString *status = response[@"status"];
            
            if ([@"VERIFIED" isEqualToString:status]) { // Test
                _controller.verificationStatus = BTVerificationStatusSuccess;
                _controller.businessUser = [BTUser userWithBusinessProfile:response[@"businessProfile"]];
                
                [self businessVerificationStatusUpdated];
                
            } else if ([@"FAILED" isEqualToString:status]) {
                _controller.verificationStatus = BTVerificationStatusFailure;
                [self businessVerificationStatusUpdated];
                
            } else {
                [self performSelector:@selector(checkBusinessVerificationStatus) withObject:nil afterDelay:5.f];
            }
            
        } else {
            // end checking
            _controller.verificationStatus = BTVerificationStatusFailure;
            [self businessVerificationStatusUpdated];
        }
    }];
}

- (void)businessVerificationStatusUpdated {
    [_activityIndicator stopAnimating];
    _btnStartCall.enabled = YES;
    _btnCallSupport.enabled = YES;
    
    if (_controller.verificationStatus == BTVerificationStatusSuccess) {
        __weak typeof (self) weakSelf = self;
        [RestClient getUserSubscriptionWithCompletion:^(BOOL success, NSString *code, id response) {
            if (success) {
                BTSubscription *subscription = [BTSubscription objectWithJSONDictionary:response[@"subscription"]];
                if (subscription.subscriptionPlan.length || Model.currentUser.allowDemo.boolValue) {
                    weakSelf.controller.businessUser.business.subscription = subscription;
                    [weakSelf userSubscribedStatusUpdated];
                }
            }
        }];
        
        [self gotoPage:3];
    } else {
        
    }
}


#pragma mark - Page 3

- (IBAction)selectPlanAction:(id)sender {
    UIView *selectedPlanView = [sender superview];
    _selectedPlan = selectedPlanView.tag;
    [self setState:(_plan1View == selectedPlanView) ForView:_plan1View];
    [self setState:(_plan2View == selectedPlanView) ForView:_plan2View];
    
    _selectedPlanBGTop_Y.priority = (_plan1View == selectedPlanView) ? 250 : 900;
}

- (void)enableIAPView:(BOOL)enable {
    if (enable) {
        [_activityIndicator stopAnimating];
    } else {
        _activityIndicator.hidden = NO;
        [_activityIndicator startAnimating];
    }
    _plan1View.userInteractionEnabled = _plan2View.userInteractionEnabled = _btnPay.enabled = enable;
}

- (IBAction)applePayAction:(id)sender {
    NSString *productID = _selectedPlan ? kBetterItAndSurveyProductIdentifier : kBetterItProductIdentifier;
    
    [self enableIAPView:NO];
    
    __weak typeof (self) weakSelf = self;
    [[IAPShare sharedHelper] restoreOrBuyProductWithID:productID completionBlock:^(BOOL restored, SKPaymentTransaction *transaction) {
        if (transaction && transaction.transactionReceipt) {
            [RestClient subscribeBusinessWithTransactionData:transaction Completion:^(BOOL success, NSString *code, id response) {
                [weakSelf enableIAPView:YES];
                
                BTSubscription *subscription = [BTSubscription objectWithJSONDictionary:response[@"subscription"]];
                
                if (subscription.subscriptionPlan.length) {
                    _controller.businessUser.business.subscription = subscription;
                    [weakSelf userSubscribedStatusUpdated];
                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }];
        } else {
            [weakSelf enableIAPView:YES];
        }
    }];
}

- (void)userSubscribedStatusUpdated {
    if (_controller.businessUser.business.subscription.subscriptionPlan.length || Model.currentUser.allowDemo.boolValue) {
        [_controller didFinishSetup];
    }
}


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _pageControl.currentPage = round(scrollView.contentOffset.x / scrollView.bounds.size.width);
    
    if (_pageControl.currentPage != 0) {
        // can only scroll in first page
        scrollView.scrollEnabled = NO;
    }
}


#pragma mark - Misc

- (void)setState:(BOOL)selected ForView:(UIView *)planView {
    planView.backgroundColor = selected ? [UIColor clearColor] : RGB(246, 246, 246);
    for (UILabel *label in planView.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            label.textColor = selected ? [UIColor whiteColor] : RGB(108, 108, 108);
        }
    }
}


#pragma mark - Navigation

- (void)gotoPage:(NSInteger)pageNum {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.scrollView setContentOffset:CGPointMake(weakSelf.scrollView.bounds.size.width * (pageNum -1), 0.f) animated:YES];
        
        weakSelf.btnClose.hidden = (pageNum > 2);
    });
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SearchBusinessSegue"]) {
        BTSearchBusinessController *searchController = segue.destinationViewController;
        searchController.shouldShowBrands = YES;
        searchController.shouldShowBetterIts = YES;
        searchController.delegate = self;
    }
}


@end
