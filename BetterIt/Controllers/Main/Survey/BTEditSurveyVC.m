//
//  BTEditSurveyVC.m
//  BetterIt
//
//  Created by Maikel on 22/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTEditSurveyVC.h"
#import "BTSurveyTVC.h"
#import "BTSurvey.h"
#import "BTRestClient.h"


@interface BTEditSurveyVC () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *tfQuestion;
@property (weak, nonatomic) IBOutlet UIImageView *imgAddSurvey;
@end


@implementation BTEditSurveyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tableView.rowHeight = 88.f;
    [_tableView registerNib:[UINib nibWithNibName:@"BTSurveyTVC" bundle:nil] forCellReuseIdentifier:@"tvcSurvey"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Text Field

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    _imgAddSurvey.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _imgAddSurvey.hidden = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        [self createSurveyWithQuestion:textField.text];
    }
    
    textField.text = @"";
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table View
#pragma mark Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _surveys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BTSurveyTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"tvcSurvey"];
    cell.surveyObject = _surveys[indexPath.row];
    return cell;
}

#pragma mark - Misc

- (void)createSurveyWithQuestion:(NSString *)question {
    BTSurvey *survey = [BTSurvey surveyWithQuestion:question];
    [RestClient createSurveyWithQuestion:survey.question
                                 Options:survey.options
                                    Type:survey.type
                                  Status:survey.status
                              Completion:^(BOOL success, NSString *code, id response) {
                                  if (success) {
                                      [_surveys addObject:[BTSurvey objectWithJSONDictionary:response[@"survey"]]];
                                      [_tableView reloadData];
                                  }
                              }];
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
