//
//  BTTemplateVC.h
//  BetterIt
//
//  Created by Maikel on 02/07/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTTemplateCell.h"


@protocol BTTemplateVCDelegate;

@interface BTTemplateVC : UIViewController
@property (strong, nonatomic) NSArray *dataSource;

@property (copy, nonatomic) NSString *templateName;
@property (copy, nonatomic) NSString *placeholderText;
@property (copy, nonatomic) Class<BTTemplateCell> CellClass;

@property (assign, nonatomic) NSInteger maximumLength;

@property (assign, nonatomic) id<BTTemplateVCDelegate> delegate;

- (void)reloadData;
@end


@protocol BTTemplateVCDelegate <NSObject>
- (void)templateVC:(BTTemplateVC *)templateVC DidSelectTemplateAtIndex:(NSInteger)index;

@optional
- (BOOL)templateVCShouldStartCreating:(BTTemplateVC *)templateVC;
- (void)templateVC:(BTTemplateVC *)templateVC DidCreateTemplateWithString:(NSString *)templateString;

- (NSString *)templateVC:(BTTemplateVC *)templateVC stringForEditPaneAtIndex:(NSInteger)index;
- (void)templateVC:(BTTemplateVC *)templateVC didTapEditAtIndex:(NSInteger)index;
@end