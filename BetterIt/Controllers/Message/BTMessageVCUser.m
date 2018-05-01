//
//  BTMessageVCUser.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTMessageVCUser.h"
#import "BTUserSessionTVC.h"
#import "BTChatVCUser.h"
#import "BTViewRewardsVC.h"
#import "Common.h"



@interface BTMessageVCUser () <BTUserSessionTVCDelegate>
@end




@implementation BTMessageVCUser

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BTUserSessionTVC" bundle:nil] forCellReuseIdentifier:@"tvcMessageSession"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Table View
#pragma mark Data Source

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    BTUserSessionTVC *cell = [tableView dequeueReusableCellWithIdentifier:@"tvcMessageSession"];
//    BTMessageSession *messageSession = (BTMessageSession *)self.dataSource[indexPath.row];
//    
//    cell.messageSession = messageSession;
//    cell.delegate = self;
//    
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
//    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
//    
//    if (messageSession.incentives.count) {
//        cell.backgroundColor = DEFAULT_LIGHT_GRAY_COLOR;
//        for (BTIncentive *incentive in messageSession.incentives) {
//            if (!incentive.used) {
//                cell.backgroundColor = DEFAULT_LIGHT_GOLD_COLOR;
//                break;
//            }
//        }
//    } else {
//        cell.backgroundColor = [UIColor whiteColor];
//    }
//
//    return cell;
//}

#pragma mark Delegate




#pragma mark - BTUserSessionTVC Delegate

-(void)userSessionTVCDidTapViewRewards:(BTUserSessionTVC *)userSessionTVC {
    [self performSegueWithIdentifier:@"ViewRewardsSegue" sender:userSessionTVC.messageSession];
}




#pragma mark - Misc
#pragma mark Data Source






#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"ViewRewardsSegue"]) {
        BTViewRewardsVC *rewardsVC = segue.destinationViewController;
        rewardsVC.messageSession = sender;
    }
}



@end
