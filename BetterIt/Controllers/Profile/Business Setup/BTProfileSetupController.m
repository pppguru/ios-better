//
//  BTProfileSetupController.m
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTProfileSetupController.h"
#import "BTProfileSetupFinalVC.h"
#import "BTRestClient.h"
#import "NSString+Additions.h"
#import "BTModel.h"


NSString * const kVerificationStatusUpdated = @"VerificationStatusUpdated";


@interface BTProfileSetupController ()
@end


@implementation BTProfileSetupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - PRIVATE

- (void)didFinishSetup {
    [Model setUser:_businessUser forType:BTUserTypeBusiness];
    if ([self.delegate respondsToSelector:@selector(profileSetupController:didFinishSetup:)]) {
        [self.delegate profileSetupController:self didFinishSetup:YES];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

}


@end
