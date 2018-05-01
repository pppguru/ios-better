//
//  BTMessageBaseVC.h
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTMessageBaseVC : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UIView *headerView;
@property(weak, nonatomic) IBOutlet UIView *filterView;
@property(weak, nonatomic) IBOutlet UILabel *lblFilterBy;
@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *pickerView_Y;

@property (strong, nonatomic) NSArray *dataSource;

- (void)reloadDataSource;
@end
