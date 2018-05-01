//
//  BTCardView.h
//  BetterIt
//
//  Created by Maikel on 2/25/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CSGrowingTextView.h>



@protocol BTCardViewDelegate;

@interface BTCardView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblCount;
@property (weak, nonatomic) IBOutlet CSGrowingTextView  *tvMessage;

@property (assign, nonatomic) BOOL active;
@property (assign, nonatomic) BOOL selected;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *iconName;
@property (copy, nonatomic) NSString *imageFilename;
@property (strong, nonatomic) UIColor *countLabelTextColor;
@property (copy, nonatomic) NSString *borderColor;

@property (assign, nonatomic) id<BTCardViewDelegate> delegate;

+ (id)cardView;
- (NSString *)text;
- (void)resetCard;
- (void)showOrHideTip:(BOOL)isHidden;
@end




@protocol BTCardViewDelegate <NSObject>

- (void)cardViewDidTapHeader:(BTCardView *)cardView;
- (void)cardViewDidTapPhotoButton:(BTCardView *)cardView;
- (void)cardViewTextChanged:(BTCardView *)cardView;
- (void)cardViewWillDeletePhoto:(BTCardView *)cardView;

@end