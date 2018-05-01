//
//  BTSubscriptionVC.m
//  BetterIt
//
//  Created by Maikel on 15/11/15.
//  Copyright © 2015 Maikel. All rights reserved.
//

#import "BTSubscriptionVC.h"
#import "Common.h"
#import "BTBusiness.h"
#import "BTSubscription.h"
#import "BTModel.h"
#import "BTRestClient.h"
#import <UIAlertView+Blocks.h>
#import "IAPShare.h"


@interface BTSubscriptionVC ()
@property (weak, nonatomic) IBOutlet UIView *plan2View;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *cancelSubscriptionButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (assign, nonatomic) NSInteger selectedPlan;
@end

@implementation BTSubscriptionVC {
    BOOL isUpdating;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPlanViews];
    
    BTSubscription *subscription = Model.currentUser.business.subscription;
    if ([subscription.subscriptionPlan isEqualToString:@"PRO"]) {
        _selectedPlan = 1;
        _lblTitle.text = @"Your Current Plan";
        
    } else {
        _selectedPlan = 0;
        _lblTitle.text = @"Upgrade Your Plan";

    }
    
    _cancelSubscriptionButton.hidden = !_shouldShowCancelOption;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([Model.currentUser.business.subscription.currentCarrier isEqualToString:@"STRIPE"]) {
        NSString *title = [Model.currentUser.business.subscription.subscriptionPlan isEqualToString:@"PRO"]
        ? @"BetterIt Subscription"
        : @"Activate surveys";
        NSString *message = [Model.currentUser.business.subscription.subscriptionPlan isEqualToString:@"PRO"]
        ? @"Please call BetterIt to modify your subscription"
        : @"Please call BetterIt to upgrade to BetterIt+Survey";

        [[[UIAlertView alloc] initWithTitle:title message:message cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel"] otherButtonItems:[RIButtonItem itemWithLabel:@"Call" action:^{
            
            NSString *phNo = @"+17205230667";
            NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
            
            if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
                [[UIApplication sharedApplication] openURL:phoneUrl];
            } else
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }], nil] show];

        self.contentView.hidden = YES;
        self.view.backgroundColor = [UIColor clearColor];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (isUpdating) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)closeAction:(id)sender {
    if (isUpdating) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelSubscriptionAction:(id)sender {
    [[[UIAlertView alloc] initWithTitle:nil
                                message:@"To cancel your BetterIt service please call or email customer support"
                               delegate:nil
                      cancelButtonTitle:@"Dismiss"
                      otherButtonTitles:nil]
     show];
}

- (IBAction)selectPlanAction:(id)sender {
    if (isUpdating || _selectedPlan) {
        return;
    }
    
    __weak typeof (self) weakSelf = self;
    
    isUpdating = YES;
    [_activityIndicator startAnimating];
    
    [[IAPShare sharedHelper] restoreOrBuyProductWithID:kBetterItSurveyProductIdentifier completionBlock:^(BOOL restored, SKPaymentTransaction *transaction) {
        if (transaction && transaction.transactionReceipt) {
            [RestClient subscribeBusinessWithTransactionData:transaction Completion:^(BOOL success, NSString *code, id response) {
                BTSubscription *subscription = [BTSubscription objectWithJSONDictionary:response[@"subscription"]];
                if ([subscription.subscriptionPlan isEqualToString:@"PRO"]) {
                    Model.currentUser.business.subscription = subscription;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:ModelUserSubscriptionUpdatedNotification object:nil];
                    
                    [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:code delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                }
                
                isUpdating = NO;
                [_activityIndicator stopAnimating];
            }];
        } else {
            isUpdating = NO;
            [_activityIndicator stopAnimating];
        }
    }];
}

#pragma mark - MISC

- (void)setupPlanViews
{
    _plan2View.layer.cornerRadius = 5.f;
    _plan2View.layer.masksToBounds = YES;
    [self setState:YES ForView:_plan2View];
}

- (void)setState:(BOOL)selected ForView:(UIView *)planView {
    planView.backgroundColor = selected ? [UIColor clearColor] : RGB(246, 246, 246);
    for (UILabel *label in planView.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            label.textColor = selected ? [UIColor whiteColor] : RGB(108, 108, 108);
        }
    }
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
