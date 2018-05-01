//
//  BTPopupBaseVC.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTPopupBaseVC.h"
#import <Google/Analytics.h>


@interface BTPopupBaseVC ()

@end


@implementation BTPopupBaseVC {
    BOOL keyboardShown;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.f alpha:.8f];
    
    _contentView.layer.cornerRadius = 12.f;
    _contentView.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardStatusWillChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardStatusWillChange:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (keyboardShown) {
        CGPoint originalCenter = self.view.center;
        originalCenter.y -= [self contentViewYOffsetWhenKeyboardShown];
        _contentView.center = originalCenter;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


#pragma mark - Actions

- (IBAction)doneAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)keyboardStatusWillChange:(NSNotification *)aNotification {
    keyboardShown = [UIKeyboardWillShowNotification isEqualToString:aNotification.name];
    
    [UIView animateWithDuration:.3f animations:^{
        CGPoint originalCenter = self.view.center;
        originalCenter.y -= keyboardShown ? [self contentViewYOffsetWhenKeyboardShown] : 0.f;
        _contentView.center = originalCenter;
    }];
}

- (CGFloat)contentViewYOffsetWhenKeyboardShown {
    return 100.f;
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
