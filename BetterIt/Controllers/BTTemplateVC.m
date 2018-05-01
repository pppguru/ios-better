//
//  BTTemplateVC.m
//  BetterIt
//
//  Created by Maikel on 02/07/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTTemplateVC.h"
#import <Google/Analytics.h>


@interface BTTemplateVC () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfCreate;
@property (weak, nonatomic) IBOutlet UIImageView *imgAdd;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation BTTemplateVC
@synthesize CellClass;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[CellClass cellNib] forCellReuseIdentifier:[CellClass cellReuseIdentifier]];
    self.tableView.rowHeight = [CellClass cellHeight];
    
    if (_placeholderText) {
        _tfCreate.placeholder = _placeholderText;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - Actions

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table View
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell<BTTemplateCell> *cell = [tableView dequeueReusableCellWithIdentifier:[CellClass cellReuseIdentifier]];
    [cell configureCell:_dataSource[indexPath.row]];
    
    return cell;
}

#pragma mark Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(templateVC:DidSelectTemplateAtIndex:)]) {
        [self.delegate templateVC:self DidSelectTemplateAtIndex:indexPath.row];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(templateVC:stringForEditPaneAtIndex:)]) {
        return [self.delegate templateVC:self stringForEditPaneAtIndex:indexPath.row] != nil;
    }
    
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(templateVC:stringForEditPaneAtIndex:)]) {
        return [self.delegate templateVC:self stringForEditPaneAtIndex:indexPath.row];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(templateVC:didTapEditAtIndex:)]) {
        [self.delegate templateVC:self didTapEditAtIndex:indexPath.row];
    }
    
    [tableView reloadData];
}


#pragma mark - Text Field

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(templateVCShouldStartCreating:)]) {
        return [self.delegate templateVCShouldStartCreating:self];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _imgAdd.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _imgAdd.hidden = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        if ([self.delegate respondsToSelector:@selector(templateVC:DidCreateTemplateWithString:)]) {
            [self.delegate templateVC:self DidCreateTemplateWithString:textField.text];
        }
    }
    
    textField.text = @"";
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_maximumLength) {
        NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (text.length > _maximumLength) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Misc

- (void)reloadData {
    [self.tableView reloadData];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
