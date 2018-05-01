//
//  BTChatVCBusiness.m
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTChatVCBusiness.h"
#import "BTModel.h"
#import "BTSendRewardVC.h"
#import "BTEnabledButton.h"
#import "BTTemplateVC.h"
#import "Common.h"
#import "BTMessageTemplateTVC.h"
#import "BTRewardTemplateTVC.h"
#import "NSArray+Plist.h"


@interface BTChatVCBusiness () <BTSendRewardVCDelegate, BTTemplateVCDelegate>
@property (strong, nonatomic) UIButton *btnSend;
@property (strong, nonatomic) IBOutlet BTEnabledButton *btnSendReward;

@property (assign, nonatomic) BOOL isShowingRewardTemplate;
@end




@implementation BTChatVCBusiness

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.messageSession.user.username;
    
    self.senderId = USERTYPE_BUSINESS;
    self.senderDisplayName = self.messageSession.business.name;
    
    self.btnSend = self.inputToolbar.contentView.rightBarButtonItem;
    [self reloadSendButton];
    
    self.inputToolbar.userInteractionEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.messageSession.lastBusinessStateMessage) {
        [self removeInteractionView];
    }
    
    [super viewDidAppear:animated];
    
    _isShowingRewardTemplate = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialize

- (void)initJSQMessageView {
    [super initJSQMessageView];
    
    // Avatar
    self.opponentAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"bizchat_person_icon"]
                                                                          diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    self.myAvatarImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_biz_icon"]
                                                                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

#pragma mark - Actions

- (IBAction)helpfulAction:(id)sender {
    if (self.isSendingMessage) {
        return;
    }
    
    [super sendMessage:[[BTMessage alloc] initStateMessageWithSessionId:self.messageSession.objectId
                                                              StateType:BTMessageStateSubTypePositive]];
    
    [self removeInteractionView];
}

- (IBAction)notHelpfulAction:(id)sender {
    if (self.isSendingMessage) {
        return;
    }
    
    [super sendMessage:[[BTMessage alloc] initStateMessageWithSessionId:self.messageSession.objectId
                                                              StateType:BTMessageStateSubTypeNegative]];
    
    [self removeInteractionView];
}

- (void)showMessageTemplateAction {
    [self performSegueWithIdentifier:@"MessageTemplateSegue" sender:nil];
}

- (void)showRewardTemplateAction {
    [self performSegueWithIdentifier:@"RewardTemplateSegue" sender:nil];
}


#pragma mark - Send Reward VC Delegate

- (void)sendRewardVC:(BTSendRewardVC *)sendRewardVC didCreateIncentive:(BTIncentive *)incentive {
    if (_isShowingRewardTemplate) {
        NSArray *JSONArray = [NSArray bt_readFromPlistFile:kRewardTemplatesKey];
        NSArray *dataSource = [MTLJSONAdapter modelsOfClass:[BTIncentive class]
                                              fromJSONArray:JSONArray
                                                      error:nil];
        dataSource = [@[incentive] arrayByAddingObjectsFromArray:dataSource];
        [[MTLJSONAdapter JSONArrayFromModels:dataSource] bt_writeToPlistFile:kRewardTemplatesKey];
    }
    [self sendMessage:[[BTMessage alloc] initIncentiveMessageWithSessionId:self.messageSession.objectId Incentive:incentive]];
    [self dismissViewControllerAnimated:!_isShowingRewardTemplate completion:nil];
}


#pragma mark - Interaction View

- (void)removeInteractionView {
    [self.interactionView removeFromSuperview];
    self.interactionView = nil;
    
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    contentInset.bottom = 44.f;
    self.collectionView.contentInset = self.collectionView.scrollIndicatorInsets = contentInset;
    
    self.inputToolbar.userInteractionEnabled = YES;
}


#pragma mark - Send Button

- (void)reloadSendButton {
    if ([self.inputToolbar.contentView.textView.text isEqualToString:@""]) {
        self.inputToolbar.contentView.rightBarButtonItem = self.btnSendReward;
        self.btnSendReward.enabled = YES;
    } else {
        self.inputToolbar.contentView.rightBarButtonItem = self.btnSend;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [super textViewDidChange:textView];
    
    if ([textView isEqual:self.inputToolbar.contentView.textView]) {
        [self reloadSendButton];
    }
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    if (self.isSendingMessage) {
        return;
    }
    
    [super didPressSendButton:button withMessageText:text senderId:senderId senderDisplayName:senderDisplayName date:date];
    
    [self reloadSendButton];
}

#pragma mark - TemplateVC Delegate

- (void)templateVC:(BTTemplateVC *)templateVC DidCreateTemplateWithString:(NSString *)templateString {
    if (!templateString) {
        return;
    }
    
    if ([templateVC.templateName isEqualToString:@"message"]) {
        NSArray *messages = [@[templateString] arrayByAddingObjectsFromArray:templateVC.dataSource];
        templateVC.dataSource = messages;
        [templateVC reloadData];
        
        [[NSUserDefaults standardUserDefaults] setObject:messages forKey:kMessageTemplatesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)templateVCShouldStartCreating:(BTTemplateVC *)templateVC {
    if ([templateVC.templateName isEqualToString:@"reward"]) {
        BTSendRewardVC *sendRewardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SendRewardVC"];
        sendRewardVC.delegate = self;
        
        [templateVC presentViewController:sendRewardVC animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

- (void)templateVC:(BTTemplateVC *)templateVC DidSelectTemplateAtIndex:(NSInteger)index {
    if ([templateVC.templateName isEqualToString:@"message"]) {
        self.inputToolbar.contentView.textView.text = templateVC.dataSource[index];
        [self reloadSendButton];
        
        [templateVC dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        [templateVC dismissViewControllerAnimated:YES completion:^{
            [self sendMessage:[[BTMessage alloc] initIncentiveMessageWithSessionId:self.messageSession.objectId Incentive:templateVC.dataSource[index]]];
        }];
    }
}


#pragma mark - Misc

- (void)setupInputToolbar {
    [super setupInputToolbar];
    
    // Adding long press gesture recognizer to the UITextView doesn't work here
    // as the OS interferes and shows magnifying glass. So added a transparent view
    // in front of the text view that filters the gestures. Show template messages
    // view for long press, and set text view as first responder for tap gesture.
    UIView *longPressView = [[UIView alloc] initWithFrame:self.inputToolbar.contentView.textView.frame];
    longPressView.backgroundColor = [UIColor clearColor];
    longPressView.userInteractionEnabled = YES;
    [longPressView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(showMessageTemplateAction)]];
    [longPressView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.inputToolbar.contentView.textView
                                                                                action:@selector(becomeFirstResponder)]];
    [self.inputToolbar.contentView addSubview:longPressView];

    [_btnSendReward addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(showRewardTemplateAction)]];
    
    self.inputToolbar.contentView.textView.placeHolder = @"Tap to type (tap & hold for options)";
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"SendRewardSegue"]) {
        BTSendRewardVC *sendRewardVC = segue.destinationViewController;
        sendRewardVC.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"MessageTemplateSegue"]) {
        BTTemplateVC *templateVC = segue.destinationViewController;
        templateVC.templateName = @"message";
        templateVC.placeholderText = @"New Message Template";
        templateVC.dataSource = [[NSUserDefaults standardUserDefaults] arrayForKey:kMessageTemplatesKey];
        templateVC.CellClass = [BTMessageTemplateTVC class];
        templateVC.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"RewardTemplateSegue"]) {
        BTTemplateVC *templateVC = segue.destinationViewController;
        templateVC.templateName = @"reward";
        templateVC.placeholderText = @"New Reward Template";
        NSArray *JSONArray = [NSArray bt_readFromPlistFile:kRewardTemplatesKey];
        templateVC.dataSource = [MTLJSONAdapter modelsOfClass:[BTIncentive class]
                                                fromJSONArray:JSONArray
                                                        error:nil];
        templateVC.CellClass = [BTRewardTemplateTVC class];
        templateVC.delegate = self;
        
        _isShowingRewardTemplate = YES;
    }
}


@end
