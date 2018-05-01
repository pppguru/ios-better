//
//  BTNavigationController.h
//  BetterIt
//
//  Created by Maikel on 3/17/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>


#define RootVC ((BTNavigationController *)[[UIApplication sharedApplication] delegate].window.rootViewController)



typedef enum {
    BTPageIndexProfile,
    BTPageIndexMain,
    BTPageIndexMessage
}BTPageIndex;

@interface BTNavigationController : UIViewController
@property (assign, nonatomic) BTPageIndex currentPage;

- (void)reloadPages;

- (void)gotoPage:(BTPageIndex)pageIndex animate:(BOOL)animate;
- (void)gotoPrev:(BOOL)animate;
- (void)gotoNext:(BOOL)animate;
@end
