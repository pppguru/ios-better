//
//  JSQMessagesCustomCVC.m
//  BetterIt
//
//  Created by Maikel on 17/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "JSQMessagesCustomCVC.h"

@interface JSQMessagesCustomCVC ()
@property (weak, nonatomic, readwrite) UITapGestureRecognizer *tapGestureRecognizer;

- (void)jsq_handleTapGesture:(UITapGestureRecognizer *)tap;
@end

@implementation JSQMessagesCustomCVC

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jsq_handleTapGesture:)];
    [self addGestureRecognizer:tap];
    self.tapGestureRecognizer = tap;
}

@end
