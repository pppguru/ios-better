//
//  BTWelcomePopupVC.m
//  BetterIt
//
//  Created by Maikel on 2/25/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTWelcomePopupVC.h"
#import "Common.h"

#import "UIView+Gradient.h"

@interface BTWelcomePopupVC () <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *btnGetStarted;

@end

@implementation BTWelcomePopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.contentView bt_setBackgroundGradient:@{@"locations" : @[@(0.f), @(0.19f), @(0.67f), @(0.74f), @(1.f)],
//                                                 @"colors":@[(id)RGB(195, 146, 46).CGColor,
//                                                             (id)RGB(215, 167, 44).CGColor,
//                                                             (id)RGB(243, 194, 40).CGColor,
//                                                             (id)RGB(252, 209, 36).CGColor,
//                                                             (id)RGB(208, 156, 50).CGColor]}];
    _btnGetStarted.layer.borderColor = RGB(240, 190, 17).CGColor;
    _btnGetStarted.layer.borderWidth = 2.f;
    _btnGetStarted.layer.cornerRadius = 5.f;
    _btnGetStarted.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _pageControl.currentPage = round(scrollView.contentOffset.x / scrollView.bounds.size.width);
    _pageControl.hidden = _pageControl.currentPage == 2;
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
