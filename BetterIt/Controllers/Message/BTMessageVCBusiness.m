//
//  BTMessageVCBusiness.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTMessageVCBusiness.h"
#import "BTRootVC.h"
#import "BTModel.h"
#import "Common.h"
#import "BTRestClient.h"
#import "BTConfig.h"
#import "AppDelegate.h"
#import "BTTemplateCell.h"
#import "BTTemplateVC.h"
#import "BTMessageTemplateTVC.h"
#import "BTRewardTemplateTVC.h"
#import "BTSendRewardVC.h"
#import "NSArray+Plist.h"
#import <JSQMessagesViewController.h>
#import <UIAlertView+Blocks.h>


@interface BTMessageVCBusiness () <JSQMessagesInputToolbarDelegate, UITextViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, BTTemplateVCDelegate, BTSendRewardVCDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnSelectMultiple;
@property (strong, nonatomic) IBOutlet JSQMessagesInputToolbar *inputToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottom;
@property (strong, nonatomic) UIButton *btnSendReward;
@property (strong, nonatomic) UIButton *btnSend;

@property (assign, nonatomic) BOOL isShowingRewardTemplate;
@end

@implementation BTMessageVCBusiness

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initializeToolbar];
    
    self.tableView.tintColor = RGB(240, 190, 17);

    [self.tableView registerNib:[UINib nibWithNibName:@"BTBusinessSessionTVC" bundle:nil] forCellReuseIdentifier:@"tvcMessageSession"];
    
    [super reloadDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    _isShowingRewardTemplate = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (void)dealloc {
    [self.inputToolbar.contentView.textView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - Actions

- (IBAction)selectMultipleAction:(id)sender {
    BOOL editing = !self.tableView.editing;
    UIButton *button = (UIButton *)sender;

    [button setTitle:editing ? @"Cancel" : @"" forState:UIControlStateNormal];
    [button setBackgroundColor:editing ? RGB(249, 249, 249) : [UIColor clearColor]];
    
    [self.tableView setEditing:editing animated:YES];
    
    _inputToolbar.hidden = !editing;
    self.tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, editing ? 44.f : 0.f, 0.f);
    
    [self.view endEditing:YES];
    
    _inputToolbar.contentView.textView.text = @"";
}

- (void)selectMessageTemplateAction {
    [self performSegueWithIdentifier:@"MessageTemplateSegue" sender:nil];
}

- (void)selectRewardTemplateAction {
    [self performSegueWithIdentifier:@"RewardTemplateSegue" sender:nil];
}


#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.editing) {
        [self reloadSendButton];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.editing) {
        [self reloadSendButton];
    }
}

#pragma mark - Input Toolbar

- (void)sendRewardAction {
    
}

- (void)initializeToolbar {
    // Adding long press gesture recognizer to the UITextView doesn't work here
    // as the OS interferes and shows magnifying glass. So added a transparent view
    // in front of the text view that filters the gestures. Show template messages
    // view for long press, and set text view as first responder for tap gesture.
    UIView *longPressView = [[UIView alloc] initWithFrame:_inputToolbar.contentView.textView.frame];
    longPressView.backgroundColor = [UIColor clearColor];
    longPressView.userInteractionEnabled = YES;
    [longPressView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(selectMessageTemplateAction)]];
    [longPressView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:_inputToolbar.contentView.textView
                                                                                action:@selector(becomeFirstResponder)]];
    [_inputToolbar.contentView addSubview:longPressView];
    
    _inputToolbar.contentView.textView.placeHolder = @"Tap to type (tap & hold for options)";
    _inputToolbar.contentView.textView.placeHolderTextColor = RGB(201, 201, 201);
    [_inputToolbar.contentView.textView addObserver:self
                                         forKeyPath:@"contentSize"
                                            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                            context:nil];
    
//    _inputToolbar.contentView.textView.font = [UIFont systemFontOfSize:11.f];
//    UIEdgeInsets contentInsets = _inputToolbar.contentView.textView.textContainerInset;
//    contentInsets.top = 8.f;
//    _inputToolbar.contentView.textView.textContainerInset = contentInsets;
    
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.f, 32.f)];
    UIImage *accessoryImage = [UIImage imageNamed:@"chat_camera"];
    UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor darkGrayColor]];
    
    [cameraButton setImage:normalImage forState:UIControlStateNormal];
    [cameraButton setImage:highlightedImage forState:UIControlStateHighlighted];
        
    cameraButton.backgroundColor = [UIColor clearColor];
    cameraButton.tintColor = [UIColor lightGrayColor];
    _inputToolbar.contentView.leftBarButtonItem = cameraButton;
    
    _btnSend = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];//_inputToolbar.contentView.rightBarButtonItem;
//    [_btnSend setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_btnSend setTitleColor:RGB(201, 201, 201) forState:UIControlStateDisabled];
    
    _btnSendReward = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 44.f, 44.f)];
    [_btnSendReward setImage:[UIImage imageNamed:@"btn_send_reward"] forState:UIControlStateNormal];
    [_btnSendReward addTarget:self action:@selector(sendRewardAction) forControlEvents:UIControlEventTouchUpInside];
    [_btnSendReward addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selectRewardTemplateAction)]];
    
    _inputToolbar.contentView.rightBarButtonItem = _btnSendReward;
    
    _inputToolbar.delegate = self;
    _inputToolbar.contentView.textView.delegate = self;
}

- (void)reloadSendButton {
    if ([self.inputToolbar.contentView.textView.text isEqualToString:@""]) {
        self.inputToolbar.contentView.rightBarButtonItem = self.btnSendReward;
    } else {
        self.inputToolbar.contentView.rightBarButtonItem = self.btnSend;
    }
    self.inputToolbar.contentView.leftBarButtonItem.enabled = self.btnSend.enabled = self.btnSendReward.enabled = [self.tableView indexPathsForSelectedRows].count > 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.inputToolbar.contentView.textView
        && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        
        CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
        
        CGFloat dy = newContentSize.height - oldContentSize.height;
        
        BOOL contentSizeIsIncreasing = (dy > 0);
        
        if (oldContentSize.height > 64.f) {
            BOOL contentOffsetIsPositive = (self.inputToolbar.contentView.textView.contentOffset.y > 0);
            
            if (contentSizeIsIncreasing || contentOffsetIsPositive) {
                [self textViewScrollToBottom:YES];
                return;
            }
        }
        
        _toolbarHeight.constant = newContentSize.height + 16.f;
        
        if (dy < 0) {
            [self textViewScrollToBottom:NO];
        }
        
    }
}

- (void)textViewScrollToBottom:(BOOL)animated {
    UITextView *textView = self.inputToolbar.contentView.textView;
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, textView.contentSize.height - CGRectGetHeight(textView.bounds));
    
    [UIView animateWithDuration:0.01
                          delay:animated ? 0.01 : 0.f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         textView.contentOffset = contentOffsetToShowLastLine;
                     }
                     completion:nil];
}


#pragma mark Delegate

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender {
    [self didPressAccessoryButton:sender];
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender {
    if ([toolbar.contentView.textView.text isEqualToString:@""]) {
        BTSendRewardVC *sendRewardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SendRewardVC"];
        sendRewardVC.delegate = self;
        
        [self presentViewController:sendRewardVC animated:YES completion:nil];
        
    } else {
        [self sendMessage:[[BTMessage alloc] initReplyMessageWithSessionId:0 Text:toolbar.contentView.textView.text Image:nil]];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    [self reloadSendButton];
}


#pragma mark - Keyboard

- (void)keyboardFrameChanged:(NSNotification *)aNotification {
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        _toolbarBottom.constant = self.view.bounds.size.height - [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Input Accessory Button
#pragma mark Overrides

- (void)didPressAccessoryButton:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Take Photo", @"Last Photo Taken", @"Choose Photo from Library", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Image Pick
#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self takePhotoAction];
            break;
        case 1:
            [self lastImageAction];
            break;
            
        case 2:
            [self choosePhotoFromLibraryAction];
            break;
    }
}

#pragma mark Action Sheet Actions

- (void)takePhotoAction {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController* _imgPickerController = [[UIImagePickerController alloc] init];
        _imgPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imgPickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        _imgPickerController.allowsEditing = YES;
        
        _imgPickerController.delegate = self;
        
        [self presentViewController:_imgPickerController animated:YES completion:nil];
    }
}

- (void)lastImageAction {
    NSString *lastImageFilename = [BTConfig objectForKey:kConfigLastImageFilename];
    
    if (lastImageFilename) {
        BTMessage *imageMessage = [[BTMessage alloc] initReplyMessageWithSessionId:0
                                                                              Text:self.inputToolbar.contentView.textView.text
                                                                             Image:lastImageFilename];
        [self sendMessage:imageMessage];
    }
    
}

- (void)choosePhotoFromLibraryAction {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController* _imgPickerController = [[UIImagePickerController alloc] init];
        _imgPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imgPickerController.delegate = self;
        _imgPickerController.allowsEditing = YES;
        
        [self presentViewController:_imgPickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    NSData *imageData = UIImageJPEGRepresentation(image, .5f);
    NSString *imageName = [NSString stringWithFormat:@"%ld.jpg", (long)[NSDate date].timeIntervalSince1970];
    NSString *imageFilePath = [appDelegate.applicationDocumentDirectory stringByAppendingPathComponent:imageName];
    
    [imageData writeToFile:imageFilePath atomically:YES];
    
    [BTConfig setObject:imageName forKey:kConfigLastImageFilename];
    
    BTMessage *imageMessage = [[BTMessage alloc] initReplyMessageWithSessionId:0
                                                                          Text:self.inputToolbar.contentView.textView.text
                                                                         Image:imageName];
    [self sendMessage:imageMessage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Send Message

- (void)sendMessage:(BTMessage *)messageToSend {
    if (self.tableView.indexPathsForSelectedRows.count == 0) {
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message sent."
                                                        message:@"Your message has been sent."
                                               cancelButtonItem:[RIButtonItem itemWithLabel:@"Undo"]
                                               otherButtonItems:[RIButtonItem itemWithLabel:@"OK" action:^{
        
        for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
            BTMessageSession *messageSession = self.dataSource[indexPath.row];
            messageToSend.sessionId = messageSession.objectId;
            
            // call back-end, and save the response message object in model
            [RestClient postMessage:messageToSend.JSONDictionary
                                 To:messageSession.objectId
                                 As:Model.currentUserTypeString
                         Completion:^(BOOL success, NSString *code, id response) {
                             if (success) {
                                 BTMessage *message = [BTMessage objectWithJSONDictionary:response[@"message"]];
                                 if (message) {
                                     if (messageToSend.imageLocal) {
                                         message.imageLocal = messageToSend.imageLocal;
                                         [Model registerImageMessage:message];
                                     }
                                     
                                     [Model updateMessages:@[message] InSession:messageSession.objectId];
                                     
                                     [[NSNotificationCenter defaultCenter] postNotificationName:ModelMessageSessionsUpdatedNotification object:nil];
                                 }
                             }
                         }];
            
        }

        [self selectMultipleAction:_btnSelectMultiple];
    }], nil];
    
    [alertView show];
    
    [self.view endEditing:YES];
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
        _inputToolbar.contentView.textView.text = templateVC.dataSource[index];
        [self reloadSendButton];
        
        [templateVC dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        [templateVC dismissViewControllerAnimated:YES completion:^{
            [self sendMessage:[[BTMessage alloc] initIncentiveMessageWithSessionId:0 Incentive:templateVC.dataSource[index]]];
        }];
    }
}


#pragma mark - Send Reward Delegate

- (void)sendRewardVC:(BTSendRewardVC *)sendRewardVC didCreateIncentive:(BTIncentive *)incentive {
    if (!incentive) {
        return;
    }

    if (_isShowingRewardTemplate) {
        NSArray *rewardTemplates = [MTLJSONAdapter modelsOfClass:[BTIncentive class]
                                                   fromJSONArray:[NSArray bt_readFromPlistFile:kRewardTemplatesKey]
                                                           error:nil];
        
        rewardTemplates = [@[incentive] arrayByAddingObjectsFromArray:rewardTemplates];
        
        [[MTLJSONAdapter JSONArrayFromModels:rewardTemplates] bt_writeToPlistFile:kRewardTemplatesKey];
    }
    
    [self dismissViewControllerAnimated:!_isShowingRewardTemplate completion:^{
        [self sendMessage:[[BTMessage alloc] initIncentiveMessageWithSessionId:0 Incentive:incentive]];
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"MessageTemplateSegue"]) {
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
