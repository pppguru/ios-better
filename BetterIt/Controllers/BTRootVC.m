//
//  BTRootVC.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTRootVC.h"
#import "AppDelegate.h"
#import "Common.h"
#import "BTConfig.h"
#import "BTModel.h"


#define NAVIGATION_BAR_CENTER_X _navigationBar.bounds.size.width / 2.f
#define NAVIGATION_BAR_CENTER_Y 42.f
#define NAVIGATION_ITEM_MARGIN  26.f
#define NAVIGATION_BAR_LENGTH_PER_PAGE  ((SCREEN_WIDTH / 2.f) - NAVIGATION_ITEM_MARGIN)




NSString * const kPageChildProfile  = @"ProfileVC";
NSString * const kPageChildMain     = @"MainVC";
NSString * const kPageChildMessage  = @"MessageVC";




@interface BTRootVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>
@property(strong, nonatomic) NSMutableDictionary *childVCs;

@property(strong, nonatomic) UIView *navigationBar;
@property(strong, nonatomic) NSMutableDictionary *navigationBarTitleViews;
@property(assign, nonatomic) CGFloat navigationBarCenterX;

@property(weak, nonatomic) UIScrollView *scrollView;
@end




@implementation BTRootVC

// used in go prev/next
static NSArray * childIds;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    childIds = @[kPageChildProfile, kPageChildMain, kPageChildMessage];
    
//    [self switchToUserType:[BTUser currentUserType]];
    // load initial child vc
    [self setViewControllers:@[[self rt_childVCWithId:kPageChildMain]] direction:0 animated:NO completion:nil];

    [self rt_initializeNavigationBar];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    // needed for scrolling between pages in Page View Controller
    self.dataSource = self;
    
    // find scroll view in UIPageViewController, and grab the reference
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            _scrollView = (UIScrollView *)subview;
        }
    }
    
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    
    [_scrollView removeGestureRecognizer:_scrollView.panGestureRecognizer];
    [_navigationBar addGestureRecognizer:_scrollView.panGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // show welcome overlay on first launch
//    if (![[BTConfig objectForKey:kConfigDidShowWelcomeOverlay] boolValue]) {
        // don't show again!
        [BTConfig setObject:@(YES) forKey:kConfigDidShowWelcomeOverlay];
        
        UIViewController *welcomeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WelcomeVC"];
        [self presentViewController:welcomeVC animated:YES completion:nil];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _scrollView.contentInset = UIEdgeInsetsMake(0.f, 0.f, 504.f, 0.f);
}

#pragma mark Actions

- (void)rt_navigationItemAction:(UITapGestureRecognizer *)gestureRecognizer {
    [self gotoPage:gestureRecognizer.view.restorationIdentifier animated:YES];
}



#pragma mark - PUBLIC

- (NSString *)currentChildId {
    return [self currentChildVC].restorationIdentifier;
}

- (UIViewController *)currentChildVC {
    return self.viewControllers.firstObject;
}

- (NSInteger)currentChildVCIndex {
    return [childIds indexOfObject:self.currentChildId];
}

#pragma mark Switch User Type

- (void)switchToUserType:(NSString *)userType {
    if (!IsValidUserType(userType) || [Model.currentUserTypeString isEqualToString:userType]) {
        return;
    }
    
    [self switchToUserType:userType InitialChildId:kPageChildMain];
}

- (void)switchToUserType:(NSString *)userType InitialChildId:(NSString *)childId {
    if (!IsValidUserType(userType) ||
        ([userType isEqualToString:Model.currentUserTypeString] && [[self currentChildId] isEqualToString:childId])) {
        return;
    }
    
    if (![userType isEqualToString:Model.currentUserTypeString]) {
        // invalidate current child vcs
        _childVCs = [[NSMutableDictionary alloc] init];
        if ([USERTYPE_NORMAL isEqualToString:userType]) {
            Model.currentUserType = BTUserTypeNormal;
        } else {
            Model.currentUserType = BTUserTypeBusiness;
        }
    }
    
    // load initial child vc
    [self setViewControllers:@[[self rt_childVCWithId:childId]] direction:0 animated:NO completion:nil];
}

#pragma mark Navigation

- (void)goToNext:(BOOL)animated {
    // ask data source
    UIViewController *nextChildVC = [self pageViewController:self viewControllerAfterViewController:self.viewControllers.firstObject];
    if (nextChildVC) {
        [self setViewControllers:@[nextChildVC]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:animated
                      completion:nil];
    }
}

- (void)goToPrev:(BOOL)animated {
    // ask data source
    UIViewController *prevChildVC = [self pageViewController:self viewControllerBeforeViewController:self.viewControllers.firstObject];
    if (prevChildVC) {
        [self setViewControllers:@[prevChildVC]
                       direction:UIPageViewControllerNavigationDirectionReverse
                        animated:animated
                      completion:nil];
    }
}

- (void)gotoPage:(NSString *)childId animated:(BOOL)animated {
    NSInteger pageIndex = [childIds indexOfObject:childId];
    [self setViewControllers:@[[self rt_childVCWithId:childId]]
                   direction:(pageIndex > self.currentChildVCIndex) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                    animated:animated
                  completion:nil];
}



#pragma mark - PRIVATE

// Return view controller using childId in combination with current user type.
// If specified view controller is not found, it instantiates it, and retain it
- (UIViewController *)rt_childVCWithId:(NSString *)childId {
    UIViewController *childVC = _childVCs[childId];
    
    if (childVC) {
        return childVC;
    }
    
    NSString *childVCStoryboardId = [NSString stringWithFormat:@"%@_%@", childId, Model.currentUserTypeString];
    childVC = [self.storyboard instantiateViewControllerWithIdentifier:childVCStoryboardId];
    
    [_childVCs setObject:childVC forKey:childId];
    return childVC;
}


#pragma mark Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSString *childId = viewController.restorationIdentifier;
    NSInteger currentIndex = [childIds indexOfObject:childId];
    
    if (currentIndex > -1 && currentIndex < childIds.count - 1) {
        return [self rt_childVCWithId:childIds[currentIndex+1]];

    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSString *childId = viewController.restorationIdentifier;
    NSInteger currentIndex = [childIds indexOfObject:childId];
    
    if (currentIndex < childIds.count && currentIndex > 0) {
        return [self rt_childVCWithId:childIds[currentIndex-1]];
    }
    
    return nil;
}

#pragma mark Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static CGFloat oldOffsetX = 0;
    
    if ((int)scrollView.contentOffset.x == (int)SCREEN_WIDTH) {
        self.navigationBarCenterX = self.currentChildVCIndex;
        [self rt_refreshNavigationBar];
    } else {
        self.navigationBarCenterX += (scrollView.contentOffset.x - oldOffsetX) / SCREEN_WIDTH;
    }
    
    oldOffsetX = scrollView.contentOffset.x;
}

#pragma mark Navigation Bar

- (void)rt_initializeNavigationBar {
    _navigationBar = [[UIView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, 0.f, SCREEN_WIDTH * 3, 64.f)];
    [_navigationBar setBackgroundColor:[UIColor whiteColor]];
    _navigationBar.userInteractionEnabled = YES;
    _navigationBarTitleViews = [NSMutableDictionary new];
    
    // main logo
    UIImageView *mainTitleView = [UIImageView new];
    mainTitleView.restorationIdentifier = kPageChildMain;
    mainTitleView.userInteractionEnabled = YES;
    [mainTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rt_navigationItemAction:)]];
    [_navigationBar addSubview:mainTitleView];
    [_navigationBarTitleViews setObject:mainTitleView forKey:kPageChildMain];
    
    // profile title view
    UIImageView *profileTitleView = [UIImageView new];
    profileTitleView.restorationIdentifier = kPageChildProfile;
    profileTitleView.userInteractionEnabled = YES;
    [profileTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rt_navigationItemAction:)]];
    [_navigationBar addSubview:profileTitleView];
    [_navigationBarTitleViews setObject:profileTitleView forKey:kPageChildProfile];
    
    // message title view
    UIImageView *messageTitleView = [UIImageView new];
    messageTitleView.restorationIdentifier = kPageChildMessage;
    messageTitleView.userInteractionEnabled = YES;
    [messageTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rt_navigationItemAction:)]];
    [_navigationBar addSubview:messageTitleView];
    [_navigationBarTitleViews setObject:messageTitleView forKey:kPageChildMessage];
    
    // separator
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 64.f, SCREEN_WIDTH, 0.5f)];
    [separatorView setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:separatorView];
    
    [self.view addSubview:_navigationBar];

    [self rt_refreshNavigationBar];
}

- (void)rt_refreshNavigationBar {
    // main logo
    UIImageView *mainTitleView = (UIImageView *)_navigationBarTitleViews[kPageChildMain];
    // set icon
    UIImage *mainIcon = [UIImage imageNamed:[self.currentChildId isEqualToString:kPageChildMain] ? @"nav_logo" : @"icn_B"];
    
    [UIView animateWithDuration:.2f animations:^{
        [mainTitleView setImage:mainIcon];
        // set frame
        [mainTitleView setFrame:CGRectMake(NAVIGATION_BAR_CENTER_X - mainIcon.size.width / 2.f,
                                           NAVIGATION_BAR_CENTER_Y - mainIcon.size.height / 2.f,
                                           mainIcon.size.width,
                                           mainIcon.size.height)];
    }];
    
    // profile icon
    UIImageView *profileTitleView = (UIImageView *)_navigationBarTitleViews[kPageChildProfile];
    // set icon
    UIImage *profileIcon = [UIImage imageNamed:@"icn_user"];
    [profileTitleView setImage:profileIcon];
    // set frame
    [profileTitleView setFrame:CGRectMake(NAVIGATION_BAR_CENTER_X - NAVIGATION_BAR_LENGTH_PER_PAGE - profileIcon.size.width / 2.f,
                                       NAVIGATION_BAR_CENTER_Y - profileIcon.size.height / 2.f,
                                       profileIcon.size.width,
                                       profileIcon.size.height)];
    
    // message icon
    UIImageView *messageTitleView = (UIImageView *)_navigationBarTitleViews[kPageChildMessage];
    // set icon
    UIImage *messageIcon = [UIImage imageNamed:@"icn_msg"];
    [messageTitleView setImage:messageIcon];
    // set frame
    [messageTitleView setFrame:CGRectMake(NAVIGATION_BAR_CENTER_X + NAVIGATION_BAR_LENGTH_PER_PAGE - messageIcon.size.width / 2.f,
                                       NAVIGATION_BAR_CENTER_Y - messageIcon.size.height / 2.f,
                                       messageIcon.size.width,
                                       messageIcon.size.height)];
    
}

- (void)setNavigationBarCenterX:(CGFloat)navigationBarCenterX {
    _navigationBarCenterX = navigationBarCenterX;
    
    CGPoint navBarCenter = _navigationBar.center;
    navBarCenter.x = (2.f - navigationBarCenterX) * NAVIGATION_BAR_LENGTH_PER_PAGE + NAVIGATION_ITEM_MARGIN;
    _navigationBar.center = navBarCenter;
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
