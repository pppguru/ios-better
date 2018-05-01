//
//  BTRootVC.h
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>


//#define RootVC ((BTRootVC *)[[UIApplication sharedApplication] delegate].window.rootViewController)


extern NSString * const kPageChildProfile;
extern NSString * const kPageChildMain;
extern NSString * const kPageChildMessage;


@interface BTRootVC : UIPageViewController
- (NSString *)currentChildId;
- (UIViewController *)currentChildVC;

- (void)switchToUserType:(NSString *)userType;
- (void)switchToUserType:(NSString *)userType InitialChildId:(NSString *)childId;

- (void)goToNext:(BOOL)animated;
- (void)goToPrev:(BOOL)animated;
- (void)gotoPage:(NSString *)childId animated:(BOOL)animated;
@end
