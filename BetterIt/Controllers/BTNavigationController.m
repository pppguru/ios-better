//
//  BTNavigationController.m
//  BetterIt
//
//  Created by Maikel on 3/17/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTNavigationController.h"
#import "BTModel.h"
#import "Common.h"
#import "BTConfig.h"
#import "UIView+AlertLabel.h"
#import "AppDelegate.h"
#import "BTNavBarIconView.h"
#import "IAPShare.h"


#define NAVIGATION_BAR_CENTER_X _navigationBar.bounds.size.width / 2.f
#define NAVIGATION_BAR_CENTER_Y 45.f
#define NAVIGATION_ITEM_MARGIN  26.f
#define NAVIGATION_BAR_LENGTH_PER_PAGE  ((SCREEN_WIDTH / 2.f) - NAVIGATION_ITEM_MARGIN)




@interface BTNavigationController () <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSArray *childIds;
@property (strong, nonatomic) NSArray *childTitleViews;

@property (strong, nonatomic) NSLayoutConstraint *pageConstraint;
@end




@implementation BTNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _childIds = @[@"ProfileVC", @"MainVC", @"MessageVC"];
    
    [self reloadPages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(btn_refreshProfileAlertLabel)
                                                 name:ModelUserUpdatedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(btn_refreshMessageAlertLabel)
                                                 name:ModelMessageSessionsUpdatedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(btn_refreshMessageAlertLabel)
                                                 name:ModelMessagesUpdatedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(btn_refreshMessageAlertLabel)
                                                 name:ModelUserUpdatedNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // show welcome overlay on first launch
    if (![[BTConfig objectForKey:kConfigDidShowWelcomeOverlay] boolValue]) {
        // don't show again!
        [BTConfig setObject:@(YES) forKey:kConfigDidShowWelcomeOverlay];
        
        UIViewController *welcomeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OnboardingVC"];
        [self presentViewController:welcomeVC animated:NO completion:nil];
        
        return;
    }
    
    if (appDelegate.pushNotificationInfo) {
        [self gotoPage:BTPageIndexMessage animate:NO];
        appDelegate.pushNotificationInfo = nil;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self btn_layoutNavigationBar:NO];
}


#pragma mark - Actions

- (void)btn_navigationItemAction:(UIGestureRecognizer *)sender {
    [self gotoPage:(BTPageIndex)[sender.view tag] animate:YES];
}


#pragma mark - PUBLIC

- (void) reloadPages {
    [self btn_loadChildViewControllers];
    [self btn_initializeNavigationBar];
    [self btn_refreshProfileAlertLabel];
    [self btn_refreshMessageAlertLabel];
}

#pragma mark Page Navigation

- (void)gotoPage:(BTPageIndex)pageIndex animate:(BOOL)animate {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTopNavigationBarDidStartScrolling object:nil];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:(animate ? 0.7f : 0.f) delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        _pageConstraint.constant = SCREEN_WIDTH * pageIndex;
        //        [_scrollView setContentOffset:CGPointMake(NAVIGATION_BAR_LENGTH_PER_PAGE * pageIndex, 0.f) animated:YES];
        [_scrollView setContentOffset:CGPointMake(NAVIGATION_BAR_LENGTH_PER_PAGE * pageIndex, 0.f) animated:NO];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        _currentPage = pageIndex;
        [self btn_layoutNavigationBar:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTopNavigationBarDidStopScrolling object:nil];
        
    }];

    if (animate) {
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            NSInteger stepsCount = 100;
            CGFloat currentPage = strongSelf.currentPage;
            CGFloat step = (CGFloat)(pageIndex - currentPage) / stepsCount;
            
            while ((step > 0.f && currentPage < pageIndex) ||
                   (step < 0.f && currentPage > pageIndex))
            {
                currentPage += step;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf btn_redrawIcons:currentPage];
                });
                
                usleep(700000 / stepsCount);
            }
            
        });
    }
}

- (void)gotoPrev:(BOOL)animate {
    if (_currentPage > 0) {
        [self gotoPage:_currentPage-1 animate:animate];
    }
}

- (void)gotoNext:(BOOL)animate {
    if (_currentPage < 2) {
        [self gotoPage:_currentPage+1 animate:animate];
    }
}


#pragma mark - Scroll View Delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger currentPageIndex = round(scrollView.contentOffset.x / NAVIGATION_BAR_LENGTH_PER_PAGE);
    NSInteger targetPageIndex = round(targetContentOffset->x / NAVIGATION_BAR_LENGTH_PER_PAGE);
    
    if (currentPageIndex != targetPageIndex) {
        if (labs(_currentPage - targetPageIndex) > 1) {
            targetPageIndex = _currentPage > targetPageIndex ? (_currentPage - 1) : (_currentPage + 1);
        }
    }
    
    targetContentOffset->x = targetPageIndex * NAVIGATION_BAR_LENGTH_PER_PAGE;
    
    _currentPage = (BTPageIndex)targetPageIndex;
    [self btn_layoutNavigationBar:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"Scroll view did scroll - %@", NSStringFromCGPoint(scrollView.contentOffset));
    
    CGFloat currentPage = scrollView.contentOffset.x / NAVIGATION_BAR_LENGTH_PER_PAGE;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _pageConstraint.constant = currentPage * SCREEN_WIDTH;
    });

    if (scrollView.isDragging || scrollView.isDecelerating) {
        [self btn_redrawIcons:currentPage];
    }
    
    [self btn_layoutNavigationBar:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTopNavigationBarDidStartScrolling object:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTopNavigationBarDidStopScrolling object:nil];
}

#pragma mark - PRIVATE

- (void)btn_loadChildViewControllers {
    // remove child view controllers
    for (UIViewController *childVC in self.childViewControllers) {
        [childVC willMoveToParentViewController:nil];
        [childVC.view removeFromSuperview];
        [childVC removeFromParentViewController];
    }
    
    UIViewController *previousVC = nil;
    
    for (NSString *childId in _childIds) {
        NSString *childVCId = [NSString stringWithFormat:@"%@_%@", childId, Model.currentUserTypeString];
        
        UIViewController *childVC = [self.storyboard instantiateViewControllerWithIdentifier:childVCId];
        
        UIView *childView = childVC.view;
        childView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // add child view controller
        [self addChildViewController:childVC];
        [self.view insertSubview:childView atIndex:0];
        [childVC didMoveToParentViewController:self];
        
        // add layout constraints
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.f
                                                               constant:0.f]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.f
                                                               constant:0.f]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.f
                                                               constant:0.f]];
        
        // add horizontal layout constraints
        if (!previousVC) {
            // first one, connect to view, and save the constraint for paging control
            _pageConstraint = [NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:childView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.f constant:0.f];
            
            [self.view addConstraint:_pageConstraint];
            
        } else {
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:previousVC.view
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:childView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.f
                                                                   constant:0.f]];
        }
        
        previousVC = childVC;
    }
    
    [self gotoPage:BTPageIndexMain animate:NO];
}

#pragma mark Navigation Bar

- (void)btn_initializeNavigationBar {
    // remove old title views
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // profile title view
    BTNavBarIconView *profileTitleView = [BTNavBarIconView new];
    profileTitleView.iconType = (Model.currentUserType == BTUserTypeBusiness) ? BTNavBarIconBusiness : BTNavBarIconPersonal;
    profileTitleView.userInteractionEnabled = YES;
    profileTitleView.tag = BTPageIndexProfile;
    profileTitleView.backgroundColor = [UIColor whiteColor];
    [profileTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btn_navigationItemAction:)]];
    [_scrollView addSubview:profileTitleView];

    // main logo
    BTNavBarIconView *mainTitleView = [BTNavBarIconView new];
    mainTitleView.iconType = BTNavBarIconLogo;
    mainTitleView.percentage = 1.f;
    mainTitleView.tag = BTPageIndexMain;
    mainTitleView.userInteractionEnabled = YES;
    mainTitleView.backgroundColor = [UIColor whiteColor];
    [mainTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btn_navigationItemAction:)]];
    [_scrollView addSubview:mainTitleView];
    
    // message title view
    BTNavBarIconView *messageTitleView = [BTNavBarIconView new];
    messageTitleView.iconType = BTNavBarIconChat;
    messageTitleView.tag = BTPageIndexMessage;
    messageTitleView.userInteractionEnabled = YES;
    messageTitleView.backgroundColor = [UIColor whiteColor];
    [messageTitleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btn_navigationItemAction:)]];
    [_scrollView addSubview:messageTitleView];
    
    _childTitleViews = @[profileTitleView, mainTitleView, messageTitleView];
    
    [self btn_layoutNavigationBar:NO];
}

- (void)btn_layoutNavigationBar:(BOOL)animate {
    _scrollView.contentSize = CGSizeMake((SCREEN_WIDTH - NAVIGATION_ITEM_MARGIN) * 2, _scrollView.bounds.size.height);

    for (int i = 0; i < _childTitleViews.count; i++) {
        UIImageView *titleView = (UIImageView *)_childTitleViews[i];
        CGSize titleViewSize = (i == BTPageIndexMain) ? CGSizeMake(92.f, 28.f) : CGSizeMake(64.f, 43.f);

        [UIView animateWithDuration:(animate ? 0.2f : 0.0f) animations:^{
            CGFloat offset = 0.f;
            switch (_currentPage) {
                case BTPageIndexProfile:
                    offset = (2 - i) * 3.f;
                    break;
                case BTPageIndexMain:
                    offset = (1 - i) * 14.f;
                    break;
                case BTPageIndexMessage:
                    offset = (2 - i) * 5.f;
                    break;
                default:
                    break;
            }
            titleView.frame = CGRectMake(SCREEN_WIDTH / 2 + NAVIGATION_BAR_LENGTH_PER_PAGE * i - titleViewSize.width / 2 + offset,
                                         NAVIGATION_BAR_CENTER_Y - titleViewSize.height / 2,
                                         titleViewSize.width,
                                         titleViewSize.height);
            [titleView bt_layoutAlertLabel];
        }];
    }
}

- (void)btn_redrawIcons:(CGFloat)currentPage {
    for (int i = 0; i < _childTitleViews.count; i++) {
        BTNavBarIconView *iconView = _childTitleViews[i];
        switch (i) {
            case 0:
                iconView.percentage = 1 - currentPage;
                break;
                
            case 1:
                iconView.percentage = MAX(0.f, 1.f - fabs(1.f - currentPage));
                break;
                
            case 2:
                iconView.percentage = currentPage - 1;
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - Alert Labels

-(void)btn_refreshProfileAlertLabel {
    // https://trello.com/c/UZ72GvI6/316-remove-the-exclamation-point-from-the-nav-bar-it-should-never-appear-in-the-nav-bar
//    UIImageView *profileTitleView = _childTitleViews[0];
//
//    if ([Model currentUser].hasEmail) {
//        [profileTitleView bt_removeAlertLabel];
//        
//    } else {
//        profileTitleView.bt_alertLabel.text = @"!";
//    }
}

- (void)btn_refreshMessageAlertLabel {
    UIImageView *messageTitleView = _childTitleViews[2];
    
    int unreadCount = 0;
    NSArray *messageSessions = Model.messageSessions;
    
    for (BTMessageSession *messageSession in messageSessions) {
        if (messageSession.unreadMessages) {
            unreadCount++;
        }
    }
    
    if (unreadCount) {
        messageTitleView.bt_alertLabel.text = [NSString stringWithFormat:@"%d", unreadCount];
        
    } else {
        [messageTitleView bt_removeAlertLabel];
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
