//
//  BTSearchBusinessTVC.m
//  BetterIt
//
//  Created by Maikel on 2/27/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTSearchBusinessTVC.h"
#import "BTBusiness.h"




@interface BTSearchBusinessTVC ()
@end




@implementation BTSearchBusinessTVC

- (void)awakeFromNib {
    // Initialization code
    _imgPhoto.layer.cornerRadius = 5.f;
    _imgPhoto.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
