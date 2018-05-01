//
//  BTProfileVCUser.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTProfileVCUser.h"
#import "BTRootVC.h"
#import "Constants.h"

@interface BTProfileVCUser ()

@end

@implementation BTProfileVCUser

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mainAction:(id)sender {
    [rootVC goToMain:YES];
}

- (IBAction)changeUserTypeAction:(id)sender {
    [rootVC switchToUserType:USERTYPE_BUSINESS InitialChildId:kPageChildProfile];
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
