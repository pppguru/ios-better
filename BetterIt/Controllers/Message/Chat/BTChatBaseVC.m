//
//  BTChatBaseVC.m
//  BetterIt
//
//  Created by devMac on 10/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTChatBaseVC.h"
#import "BTModel.h"
#import "BTRestClient.h"
#import "Common.h"
#import "BTConfig.h"
#import "AppDelegate.h"
#import "BTPhotoFullScreenVC.h"
#import "BTViewRewardsVC.h"
#import "JSQMessagesCustomCVCIncoming.h"
#import "JSQMessagesCustomCVCOutgoing.h"
#import "NSDate+Additions.h"
#import "NSString+ProfanityDetector.h"
#import <UIImageView+WebCache.h>
#import <Google/Analytics.h>


@import Photos;

@interface BTChatBaseVC ()
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) NSLayoutConstraint *inputToolbarBottom_Y;

@property (assign, nonatomic) CGFloat keyboard_Y;
@end



@implementation BTChatBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    self.lblTitle.text = (Model.currentUserType == BTUserTypeNormal) ? _messageSession.business.name : _messageSession.user.username;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;

    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // read from local model
    _dataSource = [Model getAllMessagesInSession:self.messageSession.objectId];
    _keyboard_Y = self.view.bounds.size.height;
    
    // don't show business state
    if (Model.currentUserType == BTUserTypeNormal) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type < %d", BTMessageTypeBusinessState];
        _dataSource = [_dataSource filteredArrayUsingPredicate:predicate];
    }
    
    [self initJSQMessageView];
    [self setupInputToolbar];
    
    [self finishReceivingMessage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:NSStringFromClass([self class])];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.inputToolbar.contentView removeObserver:self forKeyPath:@"bounds"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //NSLog(@"============ Did Receive Memory Warning ============");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    
    if (_interactionView && ![self.view isEqual:_interactionView.superview]) {
        // initialize rate interaction view
        [self.view addSubview:_interactionView];
        
        _inputToolbarBottom_Y = [NSLayoutConstraint constraintWithItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:_interactionView
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.f
                                                              constant:self.inputToolbar.bounds.size.height];
        [self.view addConstraint:_inputToolbarBottom_Y];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_interactionView]-0-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_interactionView)]];
        
        [self.view bringSubviewToFront:_interactionView];
    }
    
    if (_navigationBarView && ![self.view isEqual:_navigationBarView.superview]) {
        [self.view addSubview:_navigationBarView];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_navigationBarView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.f
                                                               constant:0.f]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[_navigationBarView]-0-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_navigationBarView)]];
        
        [self.view bringSubviewToFront:_navigationBarView];
    }
    
    // start reading from back-end
    [self reloadMessages];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadMessages) object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self updateCollectionViewInsets];
}

- (void)updateCollectionViewInsets
{
    UIEdgeInsets scrollInsets = UIEdgeInsetsMake(64.f, 0.f, MAX(self.inputToolbar.bounds.size.height + (_interactionView ? 86.f : 0.f),
                                                               self.view.bounds.size.height - (_keyboard_Y - self.inputToolbar.bounds.size.height)), 0.f);
    self.collectionView.scrollIndicatorInsets = scrollInsets;
    self.collectionView.contentInset = scrollInsets;
}


#pragma mark - Actions

- (IBAction)backAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)viewRewardsAction:(id)sender {
    [self performSegueWithIdentifier:@"ViewRewardsSegue" sender:nil];
}

- (BOOL)messageNeedsReview:(BTMessage *)message {
    return message.text.containsProfanity || [self messageIsDuplicate:message];
}

- (BOOL)messageIsDuplicate:(BTMessage *)message {
    BTUser *user = Model.currentUser;
    
    if (message.text.length < 5) {
        return NO;
    }
    
    NSArray *duplicateMessages = [_dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId == %ld && message.lowercaseString == %@", user.objectId, message.message.lowercaseString]];
    
    return duplicateMessages.count > 0;
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    if (_isSendingMessage) {
        return;
    }
    
    if (Model.currentUser.suspended) {
        [BTSuspendedUserAlertHelper showUserSuspendedAlert];
        return;
    }
    
    if (Model.currentUser.business.suspended) {
        [BTSuspendedUserAlertHelper showBusinessSuspendedAlert];
        return;
    }
    
    if (![text isEqualToString:@""]) {
        BTMessage *message = [[BTMessage alloc] initReplyMessageWithSessionId:self.messageSession.objectId Text:text Image:nil];
        
        message.needsReview = [self messageNeedsReview:message];
        
        [self sendMessage:message];
    }
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < _dataSource.count) {
        return _dataSource[indexPath.item];
    }
    return nil;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    BTMessage *message = _dataSource[indexPath.item];

    if (message.isMine) {
        return _outgoingBubbleImageData;
    } else {
        return _incomingBubbleImageData;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    BTMessage *message = _dataSource[indexPath.item];
    
    if (message.isMine) {
        return _myAvatarImage;
    } else {
        return _opponentAvatarImage;
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = _dataSource[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

//- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//{
//    BTMessage *message = _dataSource[indexPath.item];
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Gotham-Book" size:10.5f], NSFontAttributeName,
//                                 DEFAULT_TEXT_COLOR, NSForegroundColorAttributeName, nil];
//    return [[NSAttributedString alloc] initWithString:message.senderDisplayName attributes:attributes];
//}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    BTMessage *message = _dataSource[indexPath.item];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Gotham-Book" size:10.5f], NSFontAttributeName,
                                DEFAULT_TEXT_COLOR, NSForegroundColorAttributeName, nil];
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *timeElapsedString = [message.createdAt bt_timeElapsedDescription];
    
    NSString *needsReviewString = nil;
    
    if (message.needsReview) {
        needsReviewString = @"Message under review";
        [array addObject:needsReviewString];
    }
    
    if (timeElapsedString) [array addObject:timeElapsedString];
    
    return [[NSAttributedString alloc] initWithString:[array componentsJoinedByString:@" - "] attributes:attributes];
}


#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCustomCVC *cell = (JSQMessagesCustomCVC *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    BTMessage *msg = _dataSource[indexPath.item];
    
    cell.imgPhoto.hidden = !msg.hasImage;
    
    if (msg.hasImage) {
        if (msg.image) {
            cell.imgPhoto.image = msg.image;
        } else {

        }
    }
    
    cell.lblPhotoDescription.text = msg.imageDescription;
    
    if (msg.needsReview) {
        cell.textView.textColor = DEFAULT_GRAY_COLOR;
    } else {
        cell.textView.textColor = msg.isMine ? [UIColor whiteColor] : DEFAULT_TEXT_COLOR;
    }
    
    NSString *feedbackIcon = nil;
    switch (msg.type) {
        case BTMessageTypeFeedbackPositive:
            feedbackIcon = @"chat_positive_icon";
            break;
        case BTMessageTypeFeedbackNegative:
            feedbackIcon = @"chat_negative_icon";
            break;
        case BTMessageTypeFeedbackIdea:
            feedbackIcon = @"chat_idea_icon";
            break;
        default:
            break;
    }
    
    if (feedbackIcon) {
        cell.imgFeedbackIcon.hidden = NO;
        cell.imgFeedbackIcon.image = [UIImage imageNamed:msg.isMine ? [NSString stringWithFormat:@"%@_white", feedbackIcon] : feedbackIcon];
    } else {
        cell.imgFeedbackIcon.hidden = YES;
    }
    
//    if (!msg.isMediaMessage) {
//        
//        cell.textView.textColor = DEFAULT_TEXT_COLOR;
//        
//        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
//                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
//        
//    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 4.f;
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    BTMessage *msg = _dataSource[indexPath.item];
    
    CGFloat imageHeight = 0.f;
    if (msg.hasImage) {
        if (msg.image) {
            CGFloat imageWidth = 180.f;//MIN(msg.image.size.width, 180.f);
            imageHeight = MIN(msg.image.size.height / msg.image.size.width * imageWidth, 180.f);
            
        } else {
            imageHeight = 180.f;
        }
    }
    
    CGFloat imageDescriptionHeight = msg.imageDescription ? 20.f : 0.f;
    return 24.f + imageHeight + imageDescriptionHeight;
}


#pragma mark - Collection View Tap Events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    BTMessage *message = _dataSource[indexPath.item];
    
    if (message.incentive) {
        [self performSegueWithIdentifier:@"ViewRewardsSegue" sender:message];
    } else if (message.hasImage) {
        [self performSegueWithIdentifier:@"ImageDetailSegue" sender:message];
    }
    
    [self.view endEditing:YES];
}


#pragma mark - Input Accessory Button


#pragma mark Overrides

- (void)didPressAccessoryButton:(UIButton *)sender {
    if (_isSendingMessage) {
        return;
    }
    
    [self.view endEditing:YES];
    
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
    if ([PHAsset class]) { // If this class is available, we're running iOS 8
        
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
        PHAsset *lastImageAsset = [fetchResult lastObject];
        
        [[PHImageManager defaultManager]requestImageForAsset:lastImageAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage *result, NSDictionary *info){
            if ([info objectForKey:PHImageErrorKey] == nil && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                NSData *imageData = UIImageJPEGRepresentation(result, .5f);
                
                NSString *imageName = [NSString stringWithFormat:@"%ld.jpg", (long)[NSDate date].timeIntervalSince1970];
                NSString *imageFilePath = [appDelegate.applicationDocumentDirectory stringByAppendingPathComponent:imageName];
                
                [imageData writeToFile:imageFilePath atomically:YES];
                
                BTMessage *imageMessage = [[BTMessage alloc] initReplyMessageWithSessionId:self.messageSession.objectId
                                                                                      Text:self.inputToolbar.contentView.textView.text
                                                                                     Image:imageName];
                [self sendMessage:imageMessage];
            }
        }];
    }
    
}

- (void)choosePhotoFromLibraryAction {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController* _imgPickerController = [[UIImagePickerController alloc] init];
        _imgPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imgPickerController.allowsEditing = YES;

        _imgPickerController.delegate = self;

        [self presentViewController:_imgPickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<NSString *,id> *)editingInfo {
    //NSLog(@"Image Picker Controller Picked Image");
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    NSData *imageData = UIImageJPEGRepresentation(image, .5f);
    NSString *imageName = [NSString stringWithFormat:@"%ld.jpg", (long)[NSDate date].timeIntervalSince1970];
    NSString *imageFilePath = [appDelegate.applicationDocumentDirectory stringByAppendingPathComponent:imageName];
    
    [imageData writeToFile:imageFilePath atomically:YES];
    
    [BTConfig setObject:imageName forKey:kConfigLastImageFilename];
    
    BTMessage *imageMessage = [[BTMessage alloc] initReplyMessageWithSessionId:self.messageSession.objectId
                                                                          Text:self.inputToolbar.contentView.textView.text
                                                                         Image:imageName];
    [self sendMessage:imageMessage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    //NSLog(@"Image Picker Controller Canceled");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIButton *)inputAccessoryButton {
    
    if (!_inputAccessoryButton) {
        UIImage *accessoryImage = [UIImage imageNamed:@"chat_camera"];
        UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:DEFAULT_GRAY_COLOR];
        UIImage *highlightedImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
        
        _inputAccessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.f, 32.f)];
        [_inputAccessoryButton setImage:normalImage forState:UIControlStateNormal];
        [_inputAccessoryButton setImage:highlightedImage forState:UIControlStateHighlighted];
        
        _inputAccessoryButton.backgroundColor = [UIColor clearColor];
        _inputAccessoryButton.tintColor = DEFAULT_GRAY_COLOR;
    }
    
    return _inputAccessoryButton;
}




#pragma mark - MISC

- (void)keyboardFrameChanged:(NSNotification *)aNotification {
    CGRect keyboardFrame = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboard_Y = keyboardFrame.origin.y;
    
    [self updateCollectionViewInsets];
}

- (void)initJSQMessageView {
    
    // Message Bubbles
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] initWithBubbleImage:[UIImage imageNamed:@"chat_bubble"]
                                                                                                    capInsets:UIEdgeInsetsMake(37.f, 6.f, 10.f, 15.f)];
    _outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:RGB(248.f, 197.f, 55.f)];
    _incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:RGB(246.f, 246.f, 246.f)];
    
    // Custom cells
    [self.collectionView registerNib:[JSQMessagesCustomCVCIncoming nib]
          forCellWithReuseIdentifier:[JSQMessagesCustomCVCIncoming cellReuseIdentifier]];
    self.incomingCellIdentifier = [JSQMessagesCustomCVCIncoming cellReuseIdentifier];
    [self.collectionView registerNib:[JSQMessagesCustomCVCOutgoing nib]
          forCellWithReuseIdentifier:[JSQMessagesCustomCVCOutgoing cellReuseIdentifier]];
    self.outgoingCellIdentifier = [JSQMessagesCustomCVCOutgoing cellReuseIdentifier];
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:@"Gotham-Book" size:13.f];
    self.collectionView.collectionViewLayout.messageBubbleTextViewTextContainerInsets = UIEdgeInsetsMake(8.f, 16.f, 8.f, 32.f);
}

- (void)setupInputToolbar {
    self.inputToolbar.contentView.leftBarButtonItem = self.inputAccessoryButton;
    self.inputToolbar.contentView.textView.placeHolderTextColor = DEFAULT_GRAY_COLOR;
    self.inputToolbar.contentView.textView.font = [UIFont systemFontOfSize:13.f];
    
    [self.inputToolbar.contentView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)reloadMessages {
    [RestClient getAllMessagesInSession:self.messageSession.objectId As:Model.currentUserTypeString Completion:^(BOOL success, NSString *code, id response) {
        if (success) {
            NSInteger originalCount = _dataSource.count;
            
            // save at data source
            _dataSource = [BTMessage objectsWithJSONArray:response[@"session"][@"messages"]];
            
            // don't show business state
            if (Model.currentUserType == BTUserTypeNormal) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type < %d", BTMessageTypeBusinessState];
                _dataSource = [_dataSource filteredArrayUsingPredicate:predicate];
            }
            
            [self readUnreadMessages];

            // save at model for later use
            [Model setMessages:_dataSource InSession:self.messageSession.objectId];

            for (int i = 0; i < _dataSource.count; i++) {
                BTMessage *message = _dataSource[i];
                if (message.hasImage && !message.imageLocal) {
                    [Model downloadImageForMessage:message WithBlock:^(NSString *imageName) {
                        if (imageName) {
                            [self.collectionView reloadData];
                        }
                    }];
                }
            }
            
            if (_dataSource.count <= originalCount) {
                return;
            }
            
            [self finishReceivingMessage];
        }

        _btnViewRewards.selected = _btnViewRewards.enabled = _messageSession.incentives.count > 0;
    }];
    
    [self performSelector:@selector(reloadMessages) withObject:nil afterDelay:5.f];
}

- (void)sendMessage:(BTMessage *)messageToSend {
    if (_isSendingMessage) {
        return;
    }
    
    _isSendingMessage = YES;
    
    // update screen immediately
    _dataSource = [_dataSource arrayByAddingObject:messageToSend];
    [self finishSendingMessage];
    
    // call back-end, and save the response message object in model
    [RestClient postMessage:messageToSend.JSONDictionary To:self.messageSession.objectId As:Model.currentUserTypeString Completion:^(BOOL success, NSString *code, id response) {
        if (success) {
            BTMessage *message = [BTMessage objectWithJSONDictionary:response[@"message"]];
            if (message) {
                
                if (messageToSend.imageLocal) {
                    message.imageLocal = messageToSend.imageLocal;
                    [Model registerImageMessage:message];
                }
                
                if (messageToSend.needsReview) {
                    message.needsReview = YES;
                    [RestClient sendAction:@"FLAG" MessageId:message.objectId SessionId:_messageSession.objectId As:Model.currentUserTypeString Completion:nil];
                }
                
                [Model updateMessages:@[message] InSession:self.messageSession.objectId];
                
                _dataSource = [Model getAllMessagesInSession:self.messageSession.objectId];
                
                [self finishSendingMessage];
            }
        }
        
        _isSendingMessage = NO;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([object isEqual:self.inputToolbar.contentView]) {
        if ([keyPath isEqualToString:@"bounds"]) {
            CGRect newFrame = [change[NSKeyValueChangeNewKey] CGRectValue];
            _inputToolbarBottom_Y.constant = newFrame.size.height;
            [self.view layoutIfNeeded];
        }
    }
}

- (void)readUnreadMessages {
    for (BTMessage *message in _dataSource) {
        if (!message.readStatus) {
            [RestClient sendAction:@"READ"
                         MessageId:message.objectId
                         SessionId:_messageSession.objectId
                                As:Model.currentUserTypeString
                        Completion:nil];
            
            message.readStatus = YES;
        }
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"ImageDetailSegue"]) {
        BTPhotoFullScreenVC *photoVC = segue.destinationViewController;
        BTMessage *message = sender;
        photoVC.imageURL = message.imageURL;
        
    } else if ([segue.identifier isEqualToString:@"ViewRewardsSegue"]) {
        BTViewRewardsVC *rewardsVC = segue.destinationViewController;
        rewardsVC.initialIncentiveMessage = sender;
    }
}


@end
