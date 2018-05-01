//
//  BTCardView.m
//  BetterIt
//
//  Created by Maikel on 2/25/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTCardView.h"
#import "Common.h"
#import "AppDelegate.h"
#import "UIView+Gradient.h"


@interface BTCardView () <CSGrowingTextViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel            *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton           *imgIcon;
@property (weak, nonatomic) IBOutlet UIButton           *btnPhoto;
@property (weak, nonatomic) IBOutlet UIImageView        *imgPhoto;

@property (weak, nonatomic) IBOutlet UIImageView *imgBorderTop;
@property (weak, nonatomic) IBOutlet UIImageView *imgBorderLeft;
@property (weak, nonatomic) IBOutlet UIImageView *imgBorderBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgPhoto_Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;
@end



@implementation BTCardView

+ (id)cardView {
    BTCardView *cardView = [[[NSBundle mainBundle] loadNibNamed:@"BTCardView" owner:nil options:nil] lastObject];
    
    // make sure cardView is not nil or the wrong class!
    if ([cardView isKindOfClass:[BTCardView class]]) {
        
        cardView.tvMessage.growDirection = CSGrowDirectionNone;
        cardView.tvMessage.delegate = cardView;
        cardView.tvMessage.maximumNumberOfLines = 10000;
        cardView.tvMessage.enablesNewlineCharacter = YES;
        cardView.tvMessage.internalTextView.autocorrectionType = UITextAutocorrectionTypeYes;
        cardView.tvMessage.internalTextView.spellCheckingType = UITextSpellCheckingTypeYes;
        
        return cardView;
    }
    else
        return nil;
}

- (IBAction)headerAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cardViewDidTapHeader:)]) {
        [self.delegate cardViewDidTapHeader:self];
    }
}

- (IBAction)photoAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cardViewDidTapPhotoButton:)]) {
        [self.delegate cardViewDidTapPhotoButton:self];
    }
}

#pragma mark - Getters & Setters
#pragma mark Getters

- (NSString *)text {
    return _tvMessage.internalTextView.text;
}

#pragma mark Setters

- (void)setActive:(BOOL)active {
    _active = active;
    
    if ([_borderColor isEqualToString:@"none"]) {
        _lblTitle.textColor = DEFAULT_GOLD_COLOR;
    }
    else{
        _lblTitle.textColor = _active ? RGB(108, 108, 108) : RGB(200, 200, 200);
    }
    
    _imgIcon.selected = _active;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    
    _tvMessage.hidden = _lblCount.hidden = _btnPhoto.hidden = _imgPhoto.hidden = !_selected;

    if (_selected) {
        [_tvMessage becomeFirstResponder];
    } else {
        [_tvMessage resignFirstResponder];
    }
    
    _scrollView.scrollEnabled = _selected;
    if (!_selected) {
        _scrollView.contentOffset = CGPointZero;
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    _lblTitle.text = _title;
}

- (void)setIconName:(NSString *)iconName {
    _iconName = iconName;
    
    [_imgIcon setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_%@", _iconName, @"inactive"]] forState:UIControlStateNormal];
    [_imgIcon setImage:[UIImage imageNamed:iconName] forState:UIControlStateSelected];
}

- (void)setCountLabelTextColor:(UIColor *)countLabelTextColor {
    _countLabelTextColor = countLabelTextColor;
    _lblCount.textColor = _countLabelTextColor;
}

- (void)setImageFilename:(NSString *)imageFilename {
    _imageFilename = imageFilename;
    
    NSData *imageData = [NSData dataWithContentsOfFile:[[appDelegate applicationDocumentDirectory] stringByAppendingPathComponent:_imageFilename]];
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        _imgPhoto.image = image;
        _imgPhoto_Height.constant = image.size.height / image.size.width * _imgPhoto.bounds.size.width;
    } else {
        _imgPhoto.image = nil;
        _imgPhoto_Height.constant = 0.f;
    }
    
    [self setActive:(imageData != nil)];
    
    [self layoutIfNeeded];
}

- (void)setBorderColor:(NSString *)borderColor {
    _borderColor = borderColor;
    _imgBorderTop.image = [UIImage imageNamed:[NSString stringWithFormat:@"card_%@_top", borderColor]];
    _imgBorderLeft.image = [UIImage imageNamed:[NSString stringWithFormat:@"card_%@_left", borderColor]];
    _imgBorderBottom.image = [UIImage imageNamed:[NSString stringWithFormat:@"card_%@_bottom", borderColor]];
    
    if ([_borderColor isEqualToString:@"none"]) {
        _lblTitle.textColor = DEFAULT_GOLD_COLOR;
        _lblTitle.numberOfLines = 2;
        _lblTitle.adjustsFontSizeToFitWidth = YES;
    }
}

#pragma mark - CSGrowingTextView Delegate

- (BOOL)growingTextView:(CSGrowingTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.location == 0 && range.length == 0 && text.length == 0) {
        if ([self.delegate respondsToSelector:@selector(cardViewWillDeletePhoto:)]) {
            [self.delegate cardViewWillDeletePhoto:self];
        }
    }
    
    return YES;
}

- (void)growingTextViewDidChange:(CSGrowingTextView *)textView {
    if ([self.delegate respondsToSelector:@selector(cardViewTextChanged:)]) {
        [self.delegate cardViewTextChanged:self];
    }
}

- (void)growingTextView:(CSGrowingTextView *)growingTextView willChangeHeight:(CGFloat)height {
    BOOL isGrowing = (height > _textHeight.constant);
    _textHeight.constant = height;
    [self layoutIfNeeded];
    if ([growingTextView isFirstResponder] && isGrowing) {
        [self.scrollView scrollRectToVisible:CGRectMake(0.f, self.scrollView.contentSize.height - 1.f, 1.f, 1.f) animated:YES];
    }
}


#pragma mark - MISC

- (void)resetCard {
    _tvMessage.internalTextView.text = @"";
    _lblCount.text = @"350";
    [self setImageFilename:nil];
    [self setSelected:NO];
    [self setActive:NO];
    [self showOrHideTip:NO];
}

- (void)showOrHideTip:(BOOL)isHidden{
    if (isHidden) {
        _lblTitle.text = @"";
    }
    else{
        _lblTitle.text = _title;
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
