//
//  BTBarChartView.m
//  BetterIt
//
//  Created by Maikel on 22/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTBarChartView.h"

@interface BTBarChartView ()
@property (strong, nonatomic) UIImageView *imgYesBG;
@property (strong, nonatomic) UIImageView *imgNoBG;
@property (strong, nonatomic) UILabel *lblYesPercentage;
@property (strong, nonatomic) UILabel *lblNoPercentage;
@end


@implementation BTBarChartView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [self setupViews];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    if (_imgNoBG) {
        return;
    }
    
    _imgNoBG = [[UIImageView alloc] initWithFrame:self.bounds];
    _imgNoBG.image = [UIImage imageNamed:@"surveycard_N_result"];
    [self addSubview:_imgNoBG];
    
    _imgYesBG = [[UIImageView alloc] initWithFrame:self.bounds];
    _imgYesBG.image = [UIImage imageNamed:@"surveycard_Y_result"];
    [self addSubview:_imgYesBG];
    
    _lblYesPercentage = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 0.f, 100.f, 35.f)];
    _lblYesPercentage.textColor = [UIColor whiteColor];
    _lblYesPercentage.font = [UIFont fontWithName:@"Gotham-Book" size:17.f];
    [self addSubview:_lblYesPercentage];
    
    _lblNoPercentage = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 115.f, 0.f, 100.f, 35.f)];
    _lblNoPercentage.textAlignment = NSTextAlignmentRight;
    _lblNoPercentage.textColor = [UIColor whiteColor];
    _lblNoPercentage.font = [UIFont fontWithName:@"Gotham-Book" size:17.f];
    [self addSubview:_lblNoPercentage];
    
    self.percentage = 100.f;
    [self resizeYesBar];
}

- (void)resizeYesBar {
    _imgYesBG.hidden = NO;
    
    if (_percentage < 1.f) {
        _imgYesBG.hidden = YES;
        return;
    } else if (_percentage > 99.f) {
        _imgYesBG.layer.mask = nil;
        return;
    }
    
    CGFloat yesLength = (self.bounds.size.width - 54.f) * _percentage / 100.f + 27.f;
    
    UIBezierPath *maskPath = [[UIBezierPath alloc] init];
    [maskPath moveToPoint:CGPointMake(0.f, 0.f)];
    [maskPath addLineToPoint:CGPointMake(yesLength + 10.f, 0.f)];
    [maskPath addLineToPoint:CGPointMake(yesLength - 10.f, 35.f)];
    [maskPath addLineToPoint:CGPointMake(0.f, 35.f)];
    [maskPath closePath];
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = maskPath.CGPath;
    
    _imgYesBG.layer.mask = mask;
}

- (void)setPercentage:(CGFloat)percentage {
    _percentage = MAX(MIN(percentage, 100.f), 0.f);
    int yesPercentage = round(_percentage);
    _lblYesPercentage.text = [NSString stringWithFormat:@"Y %d%%", yesPercentage];
    _lblNoPercentage.text = [NSString stringWithFormat:@"N %d%%", 100 - yesPercentage];
    [self resizeYesBar];
}

- (void)setIsEmpty:(BOOL)isEmpty {
    _isEmpty = isEmpty;
    
    if (_isEmpty) {
        _percentage = 0.f;
        
        _lblYesPercentage.text = [NSString stringWithFormat:@"Y %d%%", 0];
        _lblNoPercentage.text = [NSString stringWithFormat:@"N %d%%", 0];
    }
    
    [self resizeYesBar];
}
@end
