//
//  BTChatVCUser.m
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTChatVCUser.h"
#import "BTConfig.h"
#import "AppDelegate.h"




@interface BTChatVCUser () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnInteractionGood;
@property (weak, nonatomic) IBOutlet UIButton *btnInteractionBad;

@end




@implementation BTChatVCUser

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.senderId = USERTYPE_NORMAL;
    self.senderDisplayName = @"You";
    
    self.title = self.messageSession.business.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Initialize

- (void)initJSQMessageView {
    [super initJSQMessageView];
    
    // Avatar
    self.opponentAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_biz_icon"]
                                                                          diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    self.myAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"bizchat_person_icon"]
                                                                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}


#pragma mark - Overrides

- (void)reloadMessages {
    [super reloadMessages];
    
    _btnInteractionGood.enabled = _btnInteractionBad.enabled = ([self userStateMessageCount] < 2);
}


#pragma mark - Actions

- (IBAction)goodAction:(id)sender {
    if (self.isSendingMessage) {
        return;
    }
    
    _btnInteractionGood.enabled = _btnInteractionBad.enabled = ([self userStateMessageCount] < 1);
    
    [super sendMessage:[[BTMessage alloc] initStateMessageWithSessionId:self.messageSession.objectId
                                                              StateType:BTMessageStateSubTypePositive]];
}

- (IBAction)badAction:(id)sender {
    if (self.isSendingMessage) {
        return;
    }
    
    NSInteger count = [self userStateMessageCount];
    _btnInteractionGood.enabled = _btnInteractionBad.enabled = (count < 1);
    
    if (count < 2) {
        [super sendMessage:[[BTMessage alloc] initStateMessageWithSessionId:self.messageSession.objectId
                                                                  StateType:BTMessageStateSubTypeNegative]];
    }
}

- (NSInteger)userStateMessageCount {
    NSArray *messages = self.messageSession.messages;
    
    int count = 0;
    for (NSInteger i = messages.count-1; i >= 0; i--) {
        BTMessage *message = messages[i];
        
        if ([message isUserMessage]) {
            if (message.type == BTMessageTypeUserStatePositive ||
                message.type == BTMessageTypeUserStateNegative) {
                count++;
                if (count > 1) {
                    return 2;
                }
            }
        } else {
            return count;
        }
    }
    
    return count;
}

#pragma mark - Incentives

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    [super collectionView:collectionView didTapCellAtIndexPath:indexPath touchLocation:touchLocation];
    
    BTMessage *message = self.dataSource[indexPath.row];
    if (message.type == BTMessageTypeIncentive) {
        [self performSegueWithIdentifier:@"ViewRewardsSegue" sender:message];
    }
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [super prepareForSegue:segue sender:sender];
}


@end
