//
//  BTStatsView.m
//  BetterIt
//
//  Created by Maikel on 05/07/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTStatsView.h"
#import "Common.h"


#define toRadians(x) ((x)*M_PI / 180.0)
#define innerRadius    58
#define outerRadius    70

@implementation BTStatsView

- (CGSize)intrinsicContentSize {
    return CGSizeMake(163.f, 163.f);
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // draw grey background
    [self drawEmpty:ctx];
    
    // draw each percentage
    CGFloat sum = 0;
    for (NSDictionary *stat in _statsData) {
        CGFloat percentage = [stat[@"percentage"] floatValue];
        UIImage *mask = [self getMaskImageFrom:sum Length:percentage];
        UIImage *bgImage = [UIImage imageNamed:stat[@"bg"]];
        UIImage *image = [self maskImage:bgImage withMask:mask];
        [image drawInRect:CGRectMake((rect.size.width - image.size.width) / 2.f,
                                     (rect.size.height - image.size.height) / 2.f,
                                     image.size.width,
                                     image.size.height)];

        sum += percentage;
    }

    // draw percentage text
    [self drawText:rect];
}

- (void)drawEmpty:(CGContextRef)ctx {
    CGPoint center = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height / 2.f);
    
    CGFloat delta = -2 * M_PI;
    
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.97f green:.97f blue:.97f alpha:1.f].CGColor);

    CGContextSetLineWidth(ctx, 1);
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGContextSetAllowsAntialiasing(ctx, YES);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRelativeArc(path, NULL, center.x, center.y, innerRadius, -(M_PI / 2), delta);
    CGPathAddRelativeArc(path, NULL, center.x, center.y, outerRadius, delta - (M_PI / 2), -delta);
    CGPathAddLineToPoint(path, NULL, center.x, center.y - innerRadius);
    
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    
    CFRelease(path);
}

- (void)drawText:(CGRect)rect {
    if (!_text) {
        return;
    }
    
    NSDictionary * attributes = nil;
    
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Gotham-Light" size:34.f],
                  NSFontAttributeName,
                  _textColor ? _textColor : DEFAULT_GOLD_COLOR,
                  NSForegroundColorAttributeName, nil];
    
    CGRect bounds = [_text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 37.f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    [_text drawAtPoint:(CGPointMake((rect.size.width - bounds.size.width) / 2.f, (rect.size.height - bounds.size.height) / 2.f)) withAttributes:attributes];
}

- (UIImage *)getMaskImageFrom:(CGFloat)from Length:(CGFloat)length {
    CGPoint center = CGPointMake(81.5, 81.5);
    
    if (length > 0.f && length < 1.f) {
        length -= 0.003f;
    }
    CGFloat delta = toRadians(360 * length);
    CGFloat start = toRadians(360 * from) - (M_PI / 2);
    
    UIBezierPath *maskPath = [[UIBezierPath alloc] init];

    [maskPath moveToPoint:center];
    [maskPath addArcWithCenter:center radius:innerRadius startAngle:start endAngle:start + delta clockwise:YES];
    [maskPath addArcWithCenter:center radius:outerRadius startAngle:start + delta endAngle:start clockwise:NO];
    [maskPath closePath];
    
    UIGraphicsBeginImageContextWithOptions(self.intrinsicContentSize, YES, 1);
    [[UIColor whiteColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), self.bounds);
    [[UIColor blackColor] setFill];
    [maskPath fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)mask
{
    CGImageRef imageReference = image.CGImage;
    CGImageRef maskReference = mask.CGImage;
    
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                             CGImageGetHeight(maskReference),
                                             CGImageGetBitsPerComponent(maskReference),
                                             CGImageGetBitsPerPixel(maskReference),
                                             CGImageGetBytesPerRow(maskReference),
                                             CGImageGetDataProvider(maskReference),
                                             NULL, // Decode is null
                                             YES // Should interpolate
                                             );

    CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
    CGImageRelease(imageMask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
    CGImageRelease(maskedReference);
    
    return maskedImage;
}

@end
