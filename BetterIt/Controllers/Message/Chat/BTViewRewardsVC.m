//
//  BTViewRewardsVC.m
//  BetterIt
//
//  Created by Maikel on 3/23/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTViewRewardsVC.h"
#import "BTModel.h"
#import "BTRestClient.h"
#import <Google/Analytics.h>


@interface BTViewRewardsVC () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblCode;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiryDate;
@property (strong, nonatomic) IBOutlet UIButton *btnMarkUsed;
@end




@implementation BTViewRewardsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _btnMarkUsed.layer.cornerRadius = 5.f;
    _btnMarkUsed.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnMarkUsed.layer.borderWidth = 2.f;
    _btnMarkUsed.layer.masksToBounds = YES;
    
    _lblDescription.text = _initialIncentiveMessage.incentive.couponDescription;
    _lblCode.text = [NSString stringWithFormat:@"Reward Code: %@", _initialIncentiveMessage.incentive.couponCode];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"'Expires: 'MMMM dd, YYYY";
    _lblExpiryDate.text = [dateFormatter stringFromDate:_initialIncentiveMessage.incentive.expiryDate];
    [self updateMarkAsUsedButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Actions

- (IBAction)markUsedAction:(id)sender {
    BTIncentive *incentive = _initialIncentiveMessage.incentive;
    
    _btnMarkUsed.enabled = NO;
    
    [RestClient markIncentive:incentive.objectId Used:!incentive.used Completion:^(BOOL success, NSString *code, id response) {
        _btnMarkUsed.enabled = YES;
        
        if (success) {
            incentive.used = !incentive.used;
            [Model updateMessages:@[_initialIncentiveMessage] InSession:_messageSession.objectId];
            
            [self updateMarkAsUsedButton];
        }
    }];
}

#pragma mark - MISC

- (void)updateMarkAsUsedButton {
    if (Model.currentUserType == BTUserTypeNormal) {
        [_btnMarkUsed setTitle:(_initialIncentiveMessage.incentive.used ? @"Mark as Unused" : @"Mark as Used") forState:UIControlStateNormal];
    } else {
        [_btnMarkUsed setTitle:(_initialIncentiveMessage.incentive.used ? @"Used" : @"Unused") forState:UIControlStateNormal];
    }
    _btnMarkUsed.enabled = (Model.currentUserType == BTUserTypeNormal);
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
