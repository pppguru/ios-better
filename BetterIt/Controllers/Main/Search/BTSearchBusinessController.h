//
//  BTSearchBusinessController.h
//  BetterIt
//
//  Created by devMac on 11/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>




@class BTBusiness;
@class BTSearchBusinessController;




@protocol BTSearchBusinessControllerDelegate <NSObject>

- (void)searchBusinessController:(BTSearchBusinessController *)searchController didSelectBusiness:(BTBusiness *)business;

@optional
- (void)searchBusinessControllerDidCancel:(BTSearchBusinessController *)searchController;
@end




@interface BTSearchBusinessController : UINavigationController
@property (assign, nonatomic) id<UINavigationControllerDelegate, BTSearchBusinessControllerDelegate> delegate;

@property (assign, nonatomic) BOOL shouldShowRecentPlaces;
@property (assign, nonatomic) BOOL shouldShowBrands;
@property (assign, nonatomic) BOOL shouldShowBetterIts;
@end
