//
//  BTMainVCUser.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTMainVCUser.h"
#import "AppDelegate.h"
#import "Common.h"
#import "BTConfig.h"
#import "BTModel.h"
#import "BTRestClient.h"
#import "BTRootVC.h"
#import "BTCardView.h"
#import "BTSearchBusinessController.h"
#import "BTSurveyCardView.h"
#import "BTSurvey.h"
#import "BTSurveyManager.h"
#import "NSMutableArray+Shuffle.h"
#import <UIActionSheet+Blocks.h>
#import <UIImageView+WebCache.h>
#import <INTULocationManager/INTULocationManager.h>
#import <Google/Analytics.h>
#import "INTULocationManager+CurrentLocation.h"
#import "BTFeedbackSentVC.h"


#define FEEDBACK_MAX_LENGTH 350
#define DEFAULT_KEYBOARD_HEIGHT 330.f


@interface BTMainVCUser () <BTSearchBusinessControllerDelegate, BTCardViewDelegate>
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentView_Y;
@property (weak, nonatomic) IBOutlet UIButton *btnSendFeedback;

@property (strong, nonatomic) IBOutlet UIView *cardViewHolder;
@property (weak, nonatomic) IBOutlet UIView *selectedBusinessView;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelectedBusiness;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedBusinessName;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedBusinessAddress;

@property (strong, nonatomic) NSArray *cardViews;
@property (strong, nonatomic) NSArray *cardViewHeightConstraints;
@property (weak, nonatomic) IBOutlet UIView *cardTemplateView;
@property (weak, nonatomic) IBOutlet BTSurveyCardView *surveyCardView;
@property (weak, nonatomic) IBOutlet UIView *surveyEndView;
@property (weak, nonatomic) IBOutlet UIView *surveyButtonsView;
@property (weak, nonatomic) IBOutlet UILabel *lblFortuneText;
@property (weak, nonatomic) IBOutlet UIImageView *imgSurveyThanks;

@property (strong, nonatomic) IBOutlet UIToolbar *inputAccessoryToolbar;
@property (weak, nonatomic) IBOutlet UIButton *btnToolbarPrev;
@property (weak, nonatomic) IBOutlet UIButton *btnToolbarNext;
@property (weak, nonatomic) IBOutlet UIButton *btnToolbarDone;

@property (assign, nonatomic) NSInteger selectedCardIndex;
@property (strong, nonatomic) NSArray *cardViewMetaData;

@property (strong, nonatomic) NSArray *surveys;
@property (strong, nonatomic) NSArray *surveysToShow;
@property (weak, nonatomic) BTSurvey *currentSurvey;

@property (assign, nonatomic) INTULocationRequestID locationRequestId;
@property (strong, nonatomic) NSArray *nearestBusinesses;
@property (strong, nonatomic) BTBusiness *selectedBusiness;

@property (strong, nonatomic) UIWindow *alertWindow;
@end

@import Photos;


@implementation BTMainVCUser {
    __block BOOL isLoading;
    __block BOOL shouldAutoUpdateBusiness;
    __block CLLocation *lastSearchLocation;

    CGFloat displayedKeyboardHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    displayedKeyboardHeight = DEFAULT_KEYBOARD_HEIGHT;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardStatusWillChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardStatusWillChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCardView) name:NotificationTopNavigationBarDidStartScrolling object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartLoadingNearestBusinesses) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForSuspendedFlagAndAlertUser) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setIsNotFirstUse) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForSuspendedFlagAndAlertUser) name:RestClientDidAuthenticateNotification object:nil];
    
    [self initInputAccessoryToolbar];
    [self initCardViews];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNextSurvey)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    [_surveyCardView addGestureRecognizer:swipeGestureRecognizer];
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

    [self updateSendFeedbackButton];
    [self openSurveyView:NO animate:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutCardViews];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self closeCardView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startLoadingNearestBusinesses) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNextSurvey) object:nil];
}

- (void)setIsNotFirstUse {
    [BTConfig setObject:@YES forKey:kIsNotFirstUseOfApp];
}


#pragma mark - Actions
#pragma mark Photo
- (IBAction)searchAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"SearchBusinessSegue" sender:nil];
    });
}

- (void)takePhotoAction {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imgPickerController = [[UIImagePickerController alloc] init];
        imgPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgPickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imgPickerController.allowsEditing = YES;
        
        imgPickerController.delegate = self;
        
        [self presentViewController:imgPickerController animated:YES completion:nil];
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
                
                BTCardView *cardView = (BTCardView *)_cardViews[_selectedCardIndex];
                cardView.imageFilename = imageName;
                
                [self updateSendFeedbackButton];
            }
        }];
    }
}

- (void)choosePhotoFromLibraryAction {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIImagePickerController *imgPickerController = [[UIImagePickerController alloc] init];
        imgPickerController.delegate = self;

        imgPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPickerController.allowsEditing = YES;
        
        [self presentViewController:imgPickerController animated:YES completion:nil];
    }
}

#pragma mark Survey

- (IBAction)closeSurveyViewAction:(id)sender {
    [self openSurveyView:NO animate:YES];
}

- (IBAction)surveyYesAction:(id)sender {
    [self enableSurveyButtons:NO];
    
    if (![SURVEY_TYPE_DEFAULT isEqualToString:_currentSurvey.surveyType]) {
        _surveyCardView.chartView.percentage = 100 * (_currentSurvey.positiveVotes + 1) / (_currentSurvey.totalVotes + 1);
        _surveyCardView.chartView.hidden = NO;
    } else {
        [UIView animateWithDuration:.3f animations:^{
            _imgSurveyThanks.alpha = 1.f;
        }];
    }
    
    [self postAnswer:@"Y" ForSurvey:_currentSurvey];
    [BTSurveyManager answeredSurvey:_currentSurvey.objectId];

    [self performSelector:@selector(showNextSurvey) withObject:nil afterDelay:1.f];
}

- (IBAction)surveyNoAction:(id)sender {
    [self enableSurveyButtons:NO];
    
    if (![SURVEY_TYPE_DEFAULT isEqualToString:_currentSurvey.surveyType]) {
        _surveyCardView.chartView.percentage = 100 * _currentSurvey.positiveVotes / (_currentSurvey.    totalVotes + 1);
        _surveyCardView.chartView.hidden = NO;
    } else {
        [UIView animateWithDuration:.3f animations:^{
            _imgSurveyThanks.alpha = 1.f;
        }];
    }
    
    [self postAnswer:@"N" ForSurvey:_currentSurvey];
    [BTSurveyManager answeredSurvey:_currentSurvey.objectId];

    [self performSelector:@selector(showNextSurvey) withObject:nil afterDelay:1.f];
}

#pragma mark Feedback

- (IBAction)sendFeedbackAction:(id)sender {
    if (!_selectedBusiness) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Please select the business you're going to leave feedback for"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }

    BOOL messageSent = NO;
    
    for (BTCardView *cardView in _cardViews) {
        // if user input is there
        if (![@"" isEqualToString:cardView.text] || cardView.imageFilename.length) {
            BTMessage *messageToSend = [[BTMessage alloc] initFeedbackMessageWithSubType:(BTMessageFeedbackSubType)cardView.tag
                                                                                    Text:cardView.text
                                                                                   Image:cardView.imageFilename];
            
            //Add one more step to check the selected business
            if (!_selectedBusiness || _selectedBusiness.objectId == 0) {
                [self registerSelectedBusiness];
                return;
            }
            
            [RestClient postFeedback:messageToSend.JSONDictionary
                                  To:_selectedBusiness.objectId
                          Completion:^(BOOL success, NSString *code, id response) {
                             
                             if (!success) {
                                 // TODO : should show error?
                                 return;
                             }
                             
                             // TODO : Should move this to the outside of block
                             BTMessage *message = [BTMessage objectWithJSONDictionary:response[@"message"]];
                             
                             if (messageToSend.imageLocal) {
                                 message.imageLocal = messageToSend.imageLocal;
                                 [Model registerImageMessage:message];
                             }

                             BTMessageSession *messageSession = [Model messageSessionBySessionId:message.sessionId];
                             
                             if (messageSession) {
                                 [Model updateMessages:@[message] InSession:message.sessionId];
                                 
                                 // TODO : Refresh Views
                                 
                                 return;
                             }

                             [RestClient getAllMessagesInSession:message.sessionId As:Model.currentUserTypeString Completion:^(BOOL success, NSString *code, id response) {
                                 if (success) {

                                     BTMessageSession *messageSession = [BTMessageSession objectWithJSONDictionary:response[@"session"]];
                                     
                                     if (messageSession) {
                                         [Model updateMessageSession:messageSession];
                                         [Model updateMessages:@[message] InSession:message.sessionId];
                                     }

                                 }
                                 
                                 [[NSNotificationCenter defaultCenter] postNotificationName:ModelMessageSessionsUpdatedNotification object:nil];

                             }];

            }];
            
            messageSent = YES;
        }
        
        // reset card view
        [cardView resetCard];
    }
    
    if (messageSent) {
        [self performSegueWithIdentifier:@"FeedbackSentSegue" sender:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // reset selected business view
            self.selectedBusiness = nil;
            [self updateSelectedBusinessView];

            [self updateSendFeedbackButton];
            [self restartLoadingNearestBusinesses];
        });
    }
}

#pragma mark Input Accessory

- (IBAction)prevAction:(id)sender {
    if (_selectedCardIndex > 0) {
        _selectedCardIndex--;
        [self layoutCardViews];
    }
}

- (IBAction)nextAction:(id)sender {
    if (_selectedCardIndex < 2) {
        _selectedCardIndex++;
        [self layoutCardViews];
    }
}

- (IBAction)doneAction:(id)sender {
    [self closeCardView];
}





#pragma mark - Image Pick
#pragma mark Delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self layoutCardViews];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary<NSString *,id> *)editingInfo {
    //NSLog(@"Finish picking iamge");

}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = info[UIImagePickerControllerEditedImage];

    NSData *imageData = UIImageJPEGRepresentation(image, .5f);
    
    NSString *imageName = [NSString stringWithFormat:@"%ld.jpg", (long)[NSDate date].timeIntervalSince1970];
    NSString *imageFilePath = [appDelegate.applicationDocumentDirectory stringByAppendingPathComponent:imageName];
    
    [imageData writeToFile:imageFilePath atomically:YES];
    
    BTCardView *cardView = (BTCardView *)_cardViews[_selectedCardIndex];
    cardView.imageFilename = imageName;
    
    [BTConfig setObject:imageName forKey:kConfigLastImageFilename];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self updateSendFeedbackButton];
}


#pragma mark - CardView Delegate

- (void)cardViewDidTapPhotoButton:(BTCardView *)cardView {
    [self stopLoadingNearestBusinesses];
    
    _alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _alertWindow.rootViewController = [UIViewController new];
    _alertWindow.windowLevel = 10000001;
    _alertWindow.hidden = NO;
    
    __weak __typeof(self) weakSelf = self;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.alertWindow.hidden = YES;
        weakSelf.alertWindow = nil;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.alertWindow.hidden = YES;
        weakSelf.alertWindow = nil;
        [weakSelf takePhotoAction];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Last Photo Taken" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.alertWindow.hidden = YES;
        weakSelf.alertWindow = nil;
        [weakSelf lastImageAction];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Choose Photo from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.alertWindow.hidden = YES;
        weakSelf.alertWindow = nil;
        [weakSelf choosePhotoFromLibraryAction];
    }]];
    
    [_alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)cardViewDidTapHeader:(BTCardView *)cardView {
    NSUInteger cardIndex = [_cardViews indexOfObject:cardView];
    
    if (cardIndex == 3) {
        [self openSurveyView:YES animate:YES];
        
    } else {
        if (cardIndex == _selectedCardIndex) {
            _selectedCardIndex = -1;
        } else {
            _selectedCardIndex = cardIndex;
        }
    }
    
    [self layoutCardViews];
}

- (void)cardViewTextChanged:(BTCardView *)cardView {
    [self stopLoadingNearestBusinesses];
    
    int length = FEEDBACK_MAX_LENGTH - (int)cardView.text.length;
    cardView.lblCount.text = [NSString stringWithFormat:@"%d Characters", length];
    cardView.lblCount.textColor = length < 0 ? [UIColor redColor] : RGB(201, 201, 201);

    cardView.active = (cardView.text.length > 0) || (cardView.imageFilename.length > 0);
    [self updateSendFeedbackButton];
}

- (void)cardViewWillDeletePhoto:(BTCardView *)cardView {
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to remove the photo?" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }]];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
//    [self presentViewController:alertController animated:YES completion:nil];
//    
    cardView.imageFilename = nil;
    [self updateSendFeedbackButton];
}


#pragma mark - Business Search Controller Delegate

- (void)searchBusinessController:(BTSearchBusinessController *)searchController didSelectBusiness:(BTBusiness *)business {
    self.selectedBusiness = business;

    [self stopLoadingNearestBusinesses];
    [self registerSelectedBusiness];
    [self updateSelectedBusinessView];
    
    [searchController dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBusinessControllerDidCancel:(BTSearchBusinessController *)searchController {
}


#pragma mark - View
#pragma mark Input Tool bar

- (void)initInputAccessoryToolbar {
    for (UIView *toolbarButton in @[_btnToolbarPrev, _btnToolbarNext, _btnToolbarDone]) {
        toolbarButton.layer.cornerRadius = 5.f;
        toolbarButton.layer.masksToBounds = YES;
    }
}

#pragma mark Card View

- (void)initCardViews {
    _cardViewHolder.translatesAutoresizingMaskIntoConstraints = NO;
    
    _cardViewMetaData = @[@{@"name" : @"positive",
                            @"title" : @"Positive",
                            @"icon" : @"icn_thumbsup",
                            @"color" : @"green"},
                          @{@"name" : @"negative",
                            @"title" : @"Negative",
                            @"icon" : @"icn_thumbsdown",
                            @"color" : @"red"},
                          @{@"name" : @"idea",
                            @"title" : @"Idea",
                            @"icon" : @"icn_ideas",
                            @"color" : @"yellow"},
                          @{@"name" : @"more",
                            @"title" : @"Tip: Leave feedback in one or more category above or tap here for surveys",
                            @"icon" : @"main_tap_survey",
                            @"color" : @"none"}
                          ];
    
    NSMutableArray *cardViews = [NSMutableArray array];
    
    for (int i = 0; i < 4; i++) {
        BTCardView *cardView = [BTCardView cardView];
        cardView.tag = i+1;
        
        NSDictionary *cardViewInfo = _cardViewMetaData[i];
        cardView.title = cardViewInfo[@"title"];
        cardView.iconName = cardViewInfo[@"icon"];
        cardView.selected = NO;
        cardView.active = NO;
        cardView.borderColor = cardViewInfo[@"color"];
        cardView.tvMessage.internalTextView.inputAccessoryView = _inputAccessoryToolbar;
        cardView.delegate = self;
        
        [_cardViewHolder insertSubview:cardView atIndex:0];
        [cardViews addObject:cardView];
    }
    
    _cardViews = cardViews;
    
    _selectedCardIndex = -1;
    [self layoutCardViews];
}

- (void)layoutCardViews {
    
    int countActive = 0;
    for (int i = 0; i < _cardViews.count; i++) {
        BTCardView *cardView = _cardViews[i];
        
        if (cardView.active) {
            countActive ++;
        }
        
        if (i == _selectedCardIndex) {
            cardView.selected = YES;
            //[cardView removeFromSuperview];
            CGRect cardViewFrame = _cardViewHolder.bounds;
            cardViewFrame.size.height = self.view.bounds.size.height - displayedKeyboardHeight;
            cardView.frame = cardViewFrame;
            [cardView layoutIfNeeded];
            //[_cardViewHolder addSubview:cardView];
            [_cardViewHolder bringSubviewToFront:cardView];
            [cardView.tvMessage.internalTextView becomeFirstResponder];
            
        } else {
            cardView.selected = NO;
            CGRect cardViewFrame = _cardViewHolder.bounds;
            cardViewFrame.size.height = cardViewFrame.size.height / _cardViews.count;
            cardViewFrame.origin.y = cardViewFrame.size.height * i;
            cardView.frame = cardViewFrame;
            [_cardViewHolder sendSubviewToBack:cardView];
        }
        
        if (i == _cardViews.count - 1) { //if it is last item
            if (countActive > 1) [cardView showOrHideTip:YES];
            else [cardView showOrHideTip:NO];
        }
        
    }
    
    _cardTemplateView.hidden = _selectedCardIndex > -1;
}

- (void)closeCardView {
    [self.view endEditing:YES];

    _selectedCardIndex = -1;
    [self layoutCardViews];
}

#pragma mark Selected Business View

- (void)updateSelectedBusinessView {
    if (_selectedBusiness) {
        _selectedBusinessView.hidden = NO;
        _lblSelectedBusinessName.text = _selectedBusiness.name;
        
        if (_selectedBusiness.type == BTBusinessTypeBrand) {
            _lblSelectedBusinessAddress.text = @"BRAND";
        } else {
            NSString *addressString = [_selectedBusiness.address stringByReplacingOccurrencesOfString:@", United States" withString:@""];
            NSArray *addressStringComponents = [addressString componentsSeparatedByString:@", "];
            if (addressStringComponents.count == 2) {
                addressString = [NSString stringWithFormat:@"%@\n%@", addressStringComponents.firstObject, addressStringComponents.lastObject];
            } else if (addressStringComponents.count > 2) {
                NSArray *subComponents = [addressStringComponents subarrayWithRange:NSMakeRange(0, addressStringComponents.count - 2)];
                addressString = [NSString stringWithFormat:@"%@\n%@, %@", [subComponents componentsJoinedByString:@", "], addressStringComponents[addressStringComponents.count-2], addressStringComponents[addressStringComponents.count-1]];
            }
            _lblSelectedBusinessAddress.text = addressString;
        }
        
        _imgSelectedBusiness.layer.cornerRadius = 5.f;
        _imgSelectedBusiness.layer.masksToBounds = YES;
        [_imgSelectedBusiness sd_setImageWithURL:[NSURL URLWithString:_selectedBusiness.imageURL]
                                placeholderImage:[UIImage imageNamed:@"biz_setup_card_bizicon@1x"]];
    } else {
        _selectedBusinessView.hidden = YES;
    }
}



#pragma mark - Businesses

- (void)restartLoadingNearestBusinesses {
    [self stopLoadingNearestBusinesses];
    _nearestBusinesses = nil;

    shouldAutoUpdateBusiness = YES;
    [self startLoadingNearestBusinesses];
}

- (void)checkForSuspendedFlagAndAlertUser {
    if ([[Model currentUser] suspended]) {
        [BTSuspendedUserAlertHelper showUserSuspendedAlert];
        return;
    }
    
    if (Model.currentUser.business.suspended) {
        [BTSuspendedUserAlertHelper showBusinessSuspendedAlert];
        return;
    }
}

- (void)startLoadingNearestBusinesses
{
    if (_locationRequestId || !shouldAutoUpdateBusiness) {
        return;
    }
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];

    _locationRequestId = [locMgr subscribeToLocationUpdatesWithBlock:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        if (status == INTULocationStatusSuccess) {
            // A new updated location is available in currentLocation, and achievedAccuracy indicates how accurate this particular location is.
//            NSLog(@"Location updated - %@", currentLocation);ppp
            if (!_nearestBusinesses) {
                [self loadNearestBusinesses:currentLocation];
            } else if (achievedAccuracy >= INTULocationAccuracyHouse) {
                if (!isLoading) {
                    if ([currentLocation distanceFromLocation:lastSearchLocation] > 30.f) {
                        [self loadNearestBusinesses:currentLocation];
                    } else {
                        [self selectBusinessNearestFromLocation:currentLocation];
                    }
                }
            }
        } else {
            // An error occurred, more info is available by looking at the specific status returned. The subscription has been automatically canceled.
            NSLog(@"Error getting user locations - %ld", status);
            
            _locationRequestId = 0;
            [self performSelector:@selector(startLoadingNearestBusinesses) withObject:nil afterDelay:5.f];
        }
    }];
}

- (void)stopLoadingNearestBusinesses
{
    if (_locationRequestId) {
        [[INTULocationManager sharedInstance] cancelLocationRequest:_locationRequestId];
        _locationRequestId = 0;
    }
    shouldAutoUpdateBusiness = NO;
}

- (void)loadNearestBusinesses:(CLLocation *)currentLocation {
    if (isLoading) {
        return;
    }
    
    isLoading = YES;
    
    [Model fetchBusinessesWithLocation:currentLocation
                             pageToken:nil
                                   key:nil
                       completionBlock:^(bool completed, NSString *key, NSArray *results, NSString *nextPageToken) {
                           if (completed) {
                               isLoading = NO;
                           
                               if (results.count) {
                                   _nearestBusinesses = results;
                                   lastSearchLocation = currentLocation;
                                   
                                   [self selectBusinessNearestFromLocation:currentLocation];
                               }
                           }
                       }];
}

- (void)registerSelectedBusiness {
    // business is selected, but not yet registered in the back-end
    if (_selectedBusiness && _selectedBusiness.objectId == 0) {
        NSLog(@"Business name to register is '%@'", _selectedBusiness.name);
        // register selected business
        [RestClient registerBusinessWithPlaceId:_selectedBusiness.googlePlaceId Completion:^(BOOL success, NSString *code, id response) {
            if (success) {
                self.selectedBusiness = [BTBusiness objectWithJSONDictionary:response[@"business"]];
                [self loadSurveysForSelectedBusiness];
                [self updateSelectedBusinessView];
            }
            else{
                [self registerSelectedBusiness];
            }
        }];
    } else {
        [self loadSurveysForSelectedBusiness];
    }
}

- (void)selectBusinessNearestFromLocation:(CLLocation *)location {
    if ([BTConfig objectForKey:kIsNotFirstUseOfApp] && shouldAutoUpdateBusiness) {
        // sort nearest businesses according to distance from current location, and choose the nearest one
        BTBusiness *nearestBusiness = [BTModel arraySortedByDistance:_nearestBusinesses fromLocation:location].firstObject;
        
        if (!self.selectedBusiness || ![self.selectedBusiness.googlePlaceId isEqualToString:nearestBusiness.googlePlaceId]) {
            self.selectedBusiness = nearestBusiness;
        }
        
        [self registerSelectedBusiness];
        [self updateSelectedBusinessView];
    }
}


#pragma mark - Misc
#pragma mark Keyboard

- (void)keyboardStatusWillChange:(NSNotification *)aNotification {
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:.3f animations:^{
        
        if ([UIKeyboardWillShowNotification isEqualToString:aNotification.name]) {
            _contentView_Y.constant = -30.f;
            
            CGRect newKeyboardFrame = [aNotification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            CGFloat newKeyboardHeight = newKeyboardFrame.size.height + self.inputAccessoryToolbar.frame.size.height + 18;
            displayedKeyboardHeight = newKeyboardHeight;
            
            [self layoutCardViews];
        } else {
            _contentView_Y.constant = 70.f;
        }

        [self.view layoutIfNeeded];
    }];
}

#pragma mark Send Feedback Button

- (void)updateSendFeedbackButton {
    // disable when no business is selected
    if (!_selectedBusiness) {
        _btnSendFeedback.enabled = NO;
        return;
    }
    
    // disable when any of feedback messages exceed max character limit
    for (BTCardView *cardView in _cardViews) {
        if (cardView.text.length > MESSAGE_MAX_CHARACTER) {
            _btnSendFeedback.enabled = NO;
            return;
        }
    }

    // enable if at least one valid feedback
    for (BTCardView *cardView in _cardViews) {
        if (cardView.active) {
            _btnSendFeedback.enabled = YES;
            return;
        }
    }
    
    _btnSendFeedback.enabled = NO;
}

#pragma mark - Survey

- (void)loadSurveysForSelectedBusiness {
    if (!_selectedBusiness.objectId) {
        _surveys = nil;
        return;
    }
    
    [RestClient getAllSurveysForBusiness:_selectedBusiness.objectId Completion:^(BOOL success, NSString *code, id response) {
        if (success) {
            _surveys = [BTSurvey objectsWithJSONArray:response[@"surveys"]];
            _currentSurvey = nil;
        }
    }];
}

- (void)showNextSurvey {
    if (!_surveysToShow.count) {
        return;
    }
    
    if (!_currentSurvey) {
        _currentSurvey = _surveysToShow.firstObject;
    } else if (![_surveysToShow.lastObject isEqual:_currentSurvey]) {
        _currentSurvey = _surveysToShow[[_surveysToShow indexOfObject:_currentSurvey] + 1];
    } else {
        _surveyEndView.hidden = NO;
        [self enableSurveyButtons:NO];
        return;
    }

    if ([SURVEY_TYPE_FORTUNE isEqualToString:_currentSurvey.surveyType]) {
        _surveyEndView.hidden = NO;
        _lblFortuneText.text = _currentSurvey.question;
        [self enableSurveyButtons:NO];
        return;
    }

    _surveyEndView.hidden = YES;
    _surveyCardView.title = _currentSurvey.question;
    _surveyCardView.chartView.percentage = _currentSurvey.positivePercentage;
    _imgSurveyThanks.alpha = 0.f;

    _surveyCardView.chartView.hidden = YES;
    
    [self enableSurveyButtons:YES];
}

- (void)openSurveyView:(BOOL)open animate:(BOOL)animate {
    if (open) {
        if (!_selectedBusiness) {
            return;
        }
        [self stopLoadingNearestBusinesses];
    }
    _selectedBusinessView.userInteractionEnabled = open;
    
    // open/close main content view
    [UIView transitionWithView:_cardViewHolder
                      duration:animate ? .8f : 0.f
                       options:open ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        _surveyCardView.hidden = !open;
                        
                    } completion:^(BOOL finished) {
                        if (open) {
                            _surveyButtonsView.hidden = NO;
                        } else {
                            _btnSendFeedback.hidden = NO;
                        }
                    }];
    
    // hide bottom buttons
    _btnSendFeedback.hidden = YES;
    _surveyButtonsView.hidden = YES;
    
    if (!open) {
        return;
    }
    
    if (_surveys.count) {
        _currentSurvey = nil;
        
        // build surveys to show this time
        NSMutableArray *surveysToShow = [NSMutableArray array];
        NSMutableArray *fortunesToShow = [NSMutableArray array];
        for (BTSurvey *survey in _surveys) {
            if ([SURVEY_TYPE_FORTUNE isEqualToString:survey.surveyType]) {
                [fortunesToShow addObject:survey];
            } else {
                if ([SURVEY_STATUS_LIVE isEqualToString:survey.status] && ![BTSurveyManager isSurveyAnswered:survey.objectId]) {
                    [surveysToShow addObject:survey];
                }
            }
        }
        
        if (surveysToShow.count) {
            [surveysToShow shuffle];
        }

        if (fortunesToShow.count) {
            [surveysToShow addObject:fortunesToShow.firstObject];
        }
        
        _surveysToShow = surveysToShow;
        
        [self showNextSurvey];
        
    } else {
        _surveyEndView.hidden = NO;
        [self enableSurveyButtons:NO];
    }
}

- (void)enableSurveyButtons:(BOOL)enable {
    for (UIButton *button in _surveyButtonsView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.enabled = enable;
        }
    }
}

- (void)postAnswer:(NSString *)answer ForSurvey:(BTSurvey *)survey {
    NSNumber *optionId = [survey idForOptionNamed:answer];
    if (!optionId) {
        return;
    }
    [RestClient answerSurveyWithId:survey.objectId Answers:@[optionId] Completion:^(BOOL success, NSString *code, id response) {
        if (success) {
            //NSLog(@"Successfully posted Answer!");
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SearchBusinessSegue"]) {
        BTSearchBusinessController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.shouldShowRecentPlaces = NO;
    } else if ([segue.identifier isEqualToString:@"FeedbackSentSegue"]) {
        BTFeedbackSentVC *sentVC = segue.destinationViewController;
        sentVC.fortuneText = ((BTSurvey *)_surveys.lastObject).question;
    }
}


@end
