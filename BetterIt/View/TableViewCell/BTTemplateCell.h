//
//  BTTemplateCell.h
//  BetterIt
//
//  Created by Maikel on 02/07/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol BTTemplateCell <NSObject>
+ (UINib *)cellNib;
+ (NSString *)cellReuseIdentifier;
+ (CGFloat)cellHeight;

- (void)configureCell:(NSObject *)cellObject;
@end
