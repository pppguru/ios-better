//
//  BTOnboardingVC.m
//  BetterIt
//
//  Created by Maikel on 20/04/16.
//  Copyright © 2016 Maikel. All rights reserved.
//

#import "BTOnboardingVC.h"
#import "StyledPageControl.h"


@interface BTOnboardingVC () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) StyledPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *btnTutorial;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIView *tutorialView;
@property (assign, nonatomic) NSInteger currentPage;
@end

@implementation BTOnboardingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupPageControl];
    _currentPage = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextAction:(id)sender {
    if (++_pageControl.currentPage == 3) {
        [self startTapThrough];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.bounds.size.width * _pageControl.currentPage, 0.f) animated:YES];
}

- (IBAction)tutorialNextAction:(id)sender {
    if (++_currentPage > 9) {
        [self dismissViewControllerAnimated:YES completion:nil];        
    } else {
        [UIView animateWithDuration:.2f animations:^{
            _btnTutorial.alpha = 0.3f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.3f animations:^{
                [_btnTutorial setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bubble_screens_grey_2-%d", (int)_currentPage]]
                              forState:UIControlStateNormal];
                _btnTutorial.alpha = 1.f;
            }];
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _pageControl.currentPage = round(scrollView.contentOffset.x / scrollView.bounds.size.width);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_pageControl.currentPage == 3) {
        [self startTapThrough];
    }
}

- (void)startTapThrough {
    [UIView animateWithDuration:.3f animations:^{
        _pageControl.alpha = _btnNext.alpha = 0.f;
    } completion:^(BOOL finished) {
        _pageControl.hidden = _btnNext.hidden = YES;
    }];
    _scrollView.scrollEnabled = NO;
}

- (void)setupPageControl {
    _pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(138.f, 475.f, 44.f, 8.f)];
    _pageControl.userInteractionEnabled = NO;
    
    [_pageControl setPageControlStyle:PageControlStyleStrokedCircle];
    
    [_pageControl setNumberOfPages:3];
    [_pageControl setCurrentPage:0];
    
    [_pageControl setCoreNormalColor:[UIColor clearColor]];
    [_pageControl setCoreSelectedColor:[UIColor whiteColor]];
    [_pageControl setStrokeNormalColor:[UIColor whiteColor]];
    [_pageControl setStrokeSelectedColor:[UIColor whiteColor]];
    
    [_pageControl setGapWidth:10.f];
    [_pageControl setDiameter:8.f];
    [_pageControl setStrokeWidth:1.f];
    
    [self.view addSubview:_pageControl];
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
