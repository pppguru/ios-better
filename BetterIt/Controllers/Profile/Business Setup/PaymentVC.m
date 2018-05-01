//
//  PaymentVC.m
//  BetterIt
//
//  Created by Maikel on 4/1/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "PaymentVC.h"
#import "PTKView.h"
#import <Google/Analytics.h>


@interface PaymentVC () <PTKViewDelegate>
@property (strong, nonatomic) IBOutlet PTKView *paymentView;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@end


@implementation PaymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _paymentView.delegate = self;
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

- (IBAction)okAction:(id)sender {
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                      message:@"Error registering card. Please try again later!"
                                                                                                     delegate:nil
                                                                                            cancelButtonTitle:@"Dismiss"
                                                                                            otherButtonTitles:nil];
                                                  [alertView show];
                                                  
                                              } else {
                                                  if ([self.delegate respondsToSelector:@selector(paymentVC:didCreateToken:WithCard:)]) {
                                                      [self.delegate paymentVC:self didCreateToken:token WithCard:card];
                                                  }
                                              }
                                          }];
}

- (IBAction)closeAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(paymentVCDidCancel:)]) {
        [self.delegate paymentVCDidCancel:self];
        
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}


#pragma mark - PTKView Delegate

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    // Toggle navigation, for example
    self.saveButton.enabled = valid;
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
