//
//  BTMainVCUser.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTMainVCUser.h"
#import "Constants.h"
#import "BTRootVC.h"

@interface BTMainVCUser ()

@end

@implementation BTMainVCUser

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)profileAction:(id)sender {
    [rootVC goToPrev:YES];
}
- (IBAction)messageAction:(id)sender {
    [rootVC goToNext:YES];
}

- (NSString *)userType {
    return USERTYPE_NORMAL;
}

- (void)presentProfileVC:(BOOL)animated {

}

- (void)presentMessageVC:(BOOL)animated {
    
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
