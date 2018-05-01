//
//  MKSearchBar.m
//  Mayflowr
//
//  Created by devMac on 13/10/14.
//  Copyright (c) 2014 Ryan. All rights reserved.
//

#import "MKSearchBar.h"
#import "Common.h"




@implementation MKSearchBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    self.leftViewMode = UITextFieldViewModeAlways;
    
    self.layer.borderWidth = 1.f;
    self.layer.borderColor = RGB(200, 199, 204).CGColor;
    self.layer.cornerRadius = 5.f;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    return CGRectMake(7.f, 7.f, 16.f, 16.f);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
