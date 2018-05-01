//
//  BTChatBaseVC.h
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController.h>

#import "BTMessageSession.h"
#import "BTMessage.h"




@interface BTChatBaseVC : JSQMessagesViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIView *interactionView;
@property (strong, nonatomic) IBOutlet UIButton *btnViewRewards;

@property (strong, nonatomic) UIButton *inputAccessoryButton;

@property (weak, nonatomic) BTMessageSession *messageSession;
@property (strong, nonatomic) NSArray *dataSource;

@property (strong, nonatomic) JSQMessagesAvatarImage *myAvatarImage;
@property (strong, nonatomic) JSQMessagesAvatarImage *opponentAvatarImage;

@property (assign, nonatomic) BOOL isSendingMessage;

- (void)initJSQMessageView;
- (void)setupInputToolbar;

- (IBAction)backAction:(id)sender;
- (IBAction)viewRewardsAction:(id)sender;

- (void)reloadMessages;
- (void)sendMessage:(BTMessage *)messageToSend;
@end
