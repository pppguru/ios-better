//
//  BTMessageBaseVC.m
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTMessageBaseVC.h"
#import "BTModel.h"
#import "BTMessageSessionTVC.h"
#import "BTChatBaseVC.h"
#import "BTRestClient.h"
#import "Common.h"
#import "BTNavigationController.h"
#import <UIAlertView+Blocks.h>
#import <Google/Analytics.h>


@interface BTMessageBaseVC () <UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate>
@property(strong, nonatomic) NSArray *pickerDataSource;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

static dispatch_queue_t reloadQueue;

@implementation BTMessageBaseVC {
    BOOL pickerViewShowing;
    NSInteger pickerViewSelectedRow;
    
    dispatch_queue_t reloadQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:ModelMessageSessionsUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:ModelMessagesUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationBarScrolled) name:NotificationTopNavigationBarDidStopScrolling object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestMessageSessions) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    _pickerDataSource = @[@"All", @"Rewards", @"Unread", @"Read", @"Archived", @"Positive Feedback", @"Negative Feedback", @"Ideas Shared", @"Positive Chat Status", @"Negative Chat Status"];
    
    [_filterView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterByAction:)]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filterByAction:)];
    tapGestureRecognizer.delegate = self;
    [_pickerView addGestureRecognizer:tapGestureRecognizer];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(requestMessageSessions) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    _tableView.rowHeight = 64.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadDataSource];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _tableView.separatorInset = UIEdgeInsetsZero;
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        _tableView.layoutMargins = UIEdgeInsetsZero;
    }
}




#pragma mark - Actions

- (void)filterByAction:(UIGestureRecognizer *)gestureRecognizer {
    [self showFilterByPickerView:!pickerViewShowing];
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
    BTMessageSessionTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"tvcMessageSession"];
    BTMessageSession *messageSession = (BTMessageSession *)self.dataSource[indexPath.row];
    
    cell.messageSession = messageSession;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    
    if (messageSession.incentives.count) {
        cell.backgroundColor = DEFAULT_LIGHT_GRAY_COLOR;
        for (BTIncentive *incentive in messageSession.incentives) {
            if (!incentive.used) {
                cell.backgroundColor = DEFAULT_LIGHT_GOLD_COLOR;
                break;
            }
        }
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self performSegueWithIdentifier:@"ChatRoomSegue" sender:self.dataSource[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    BTMessageSession *messageSession = (BTMessageSession *)self.dataSource[indexPath.row];
    
    return messageSession.isArchived ? @"Unarchive" : @"Archive";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    BTMessageSession *messageSession = (BTMessageSession *)self.dataSource[indexPath.row];
    
    NSString *alertString = nil, *actionString = nil;
    
    if (messageSession.isArchived) {
        alertString = @"unarchive";
        actionString = @"UNBLOCK";
    } else {
        alertString = @"archive";
        actionString = @"BLOCK";
    }
    
    [RestClient sendAction:actionString SessionId:messageSession.objectId As:Model.currentUserTypeString Completion:^(BOOL success, NSString *code, id response) {
        if (success) {
            messageSession.isArchived = !messageSession.isArchived;
            [self reloadDataSource];
        }
    }];
}

#pragma mark - Picker View
#pragma mark Data Source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _pickerDataSource.count;
}

#pragma mark Delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _pickerDataSource[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    pickerViewSelectedRow = row;
}




#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    // return
    return true;
}




#pragma mark - MISC

- (void)navigationBarScrolled {
    if (RootVC.currentPage == BTPageIndexMessage) {
        [self requestMessageSessions];
        [self reloadDataSource];
    }
}

- (void)reloadDataSource {
    
    if (!reloadQueue) {
        reloadQueue = dispatch_queue_create("com.betterit.messages.reload", NULL);
    }
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(reloadQueue, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSArray *dataSource = Model.messageSessions;
        NSPredicate *predicate = nil;
        
        switch (pickerViewSelectedRow) {
            case 0:     // All
                predicate = [NSPredicate predicateWithFormat:@"isArchived == false"];
                break;
                
            case 1:     // Rewards
                predicate = [NSPredicate predicateWithFormat:@"((numberOfIncentives > 0) AND (isArchived == false))"];
                break;
                
            case 2:     // Unread
                predicate = [NSPredicate predicateWithFormat:@"((unreadMessages > 0) AND (isArchived == false))"];
                break;
                
            case 3:     // Read
                predicate = [NSPredicate predicateWithFormat:@"((unreadMessages == 0) AND (isArchived == false))"];
                break;
                
            case 4:     // Archived
                predicate = [NSPredicate predicateWithFormat:@"isArchived == true"];
                break;
                
            case 5:     // Positive Feedback
                predicate = [NSPredicate predicateWithFormat:@"((firstMessage.type == %d) AND (isArchived == false))", BTMessageTypeFeedbackPositive];
                break;
                
            case 6:     // Negative Feedback
                predicate = [NSPredicate predicateWithFormat:@"((firstMessage.type == %d) AND (isArchived == false))", BTMessageTypeFeedbackNegative];
                break;
                
            case 7:     // Ideas Shared
                predicate = [NSPredicate predicateWithFormat:@"((firstMessage.type == %d) AND (isArchived == false))", BTMessageTypeFeedbackIdea];
                break;
                
            case 8:     // Positive Chat Status
                predicate = [NSPredicate predicateWithFormat:@"((lastUserStateMessage.type == %d) AND (isArchived == false))", BTMessageTypeUserStatePositive];
                break;
                
            case 9:     // Negative Chat Status
                predicate = [NSPredicate predicateWithFormat:@"((lastUserStateMessage.type == %d) AND (isArchived == false))", BTMessageTypeUserStateNegative];
                break;
                
            default:
                break;
        }
        
        if (predicate) {
            dataSource = [dataSource filteredArrayUsingPredicate:predicate];
        }
        
        strongSelf.dataSource = [dataSource sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BTMessageSession *ms1 = obj1;
            BTMessageSession *ms2 = obj2;
            
            if (ms1.unreadMessages > 0 && ms2.unreadMessages == 0) {
                return NSOrderedAscending;
            } else if (ms1.unreadMessages == 0 && ms2.unreadMessages > 0) {
                return NSOrderedDescending;
            }
            
            return [ms2.firstMessage.createdAt compare:ms1.firstMessage.createdAt];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.tableView reloadData];
        });
    });
}

- (void)requestMessageSessions {
    [RestClient getAllMessageSessionsAs:Model.currentUserTypeString Completion:^(BOOL success, NSString *code, id response) {
        if (success) {
            [Model setMessageSessionsRaw:response[@"sessions"] forType:Model.currentUserType];
        }
        [_refreshControl endRefreshing];
    }];
}

- (void)showFilterByPickerView:(BOOL)show {
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:.3f animations:^{
        _pickerView_Y.constant = show ? 68.f : -148.f;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        pickerViewShowing = show;
        
        if (!show) {
            _lblFilterBy.text = _pickerDataSource[pickerViewSelectedRow];
            [self reloadDataSource];
        }
    }];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ChatRoomSegue"]) {
        BTChatBaseVC *chatVC = ((UINavigationController *)segue.destinationViewController).viewControllers.firstObject;
        
        chatVC.messageSession = sender;
    }
}


@end
