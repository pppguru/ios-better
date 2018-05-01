//
//  BTMessageTemplateTVC.m
//  BetterIt
//
//  Created by Maikel on 02/07/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTMessageTemplateTVC.h"

@interface BTMessageTemplateTVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@end

@implementation BTMessageTemplateTVC

#pragma mark - Template Cell

+ (UINib *)cellNib {
    return [UINib nibWithNibName:@"BTMessageTemplateTVC" bundle:nil];
}

+ (NSString *)cellReuseIdentifier {
    return @"messageTemplateTVC";
}

+ (CGFloat)cellHeight {
    return 44.f;
}

- (void)configureCell:(NSObject *)cellObject {
    _lblMessage.text = (NSString *)cellObject;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
