//
//  BTSurveyCardView.m
//  BetterIt
//
//  Created by Maikel on 21/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTSurveyCardView.h"


@interface BTSurveyCardView ()
@end

@implementation BTSurveyCardView

+ (id)cardView {
    BTSurveyCardView *cardView = [[[NSBundle mainBundle] loadNibNamed:@"BTSurveyCardView" owner:nil options:nil] lastObject];
    
    // make sure cardView is not nil or the wrong class!
    if ([cardView isKindOfClass:[BTSurveyCardView class]]) {
        return cardView;
    }
    else
        return nil;
}

#pragma mark - Actions

- (IBAction)headerAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cardViewDidTapHeader:)]) {
        [self.delegate cardViewDidTapHeader:self];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
