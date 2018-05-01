//
//  BTSearchBusinessTVC.h
//  BetterIt
//
//  Created by Maikel on 2/27/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BTBusiness;

@interface BTSearchBusinessTVC : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UILabel *lblBusinessName;
@property (weak, nonatomic)   IBOutlet UILabel *lblAddress;
@property (strong, nonatomic) IBOutlet UILabel *lblDistance;

@property (weak, nonatomic) IBOutlet UIImageView *imgAppTile;
@property (weak, nonatomic) IBOutlet UILabel *lblUnclaimed;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblBusinessName_Right;
@end
