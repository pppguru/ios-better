//
//  BTMainVCBusiness.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "BTMainVCBusiness.h"
#import "Common.h"
#import "BTRootVC.h"
#import "BTSurvey.h"
#import "BTBarChartView.h"
#import "BTModel.h"
#import "BTRestClient.h"
#import "BTSurveyTVC.h"
#import "BTTemplateVC.h"
#import "BTStatsView.h"
#import "BTModel.h"
#import "BTProfileSetupFinalVC.h"
#import "NSString+Additions.h"
#import <Google/Analytics.h>
#import <UIAlertView+Blocks.h>

#define SURVEY_VIEW_SIZE CGSizeMake(320.f, 137.f)

@interface BTMainVCBusiness () <UIScrollViewDelegate, BTTemplateVCDelegate, BTProfileSetupFinalVCDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblBusinessName;
@property (weak, nonatomic) IBOutlet UILabel *lblBusinessAddress;
@property (weak, nonatomic) IBOutlet UIView *surveyDisabledView;
@property (weak, nonatomic) IBOutlet UIScrollView *surveyScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *surveyPageControl;
@property (weak, nonatomic) IBOutlet UIButton *btnAddSurvey;
@property (strong, nonatomic) NSMutableArray *surveys;

@property (weak, nonatomic) IBOutlet UIScrollView *statsScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet BTStatsView *statsNoNegative;
@property (weak, nonatomic) IBOutlet BTStatsView *statsEngage;
@property (weak, nonatomic) IBOutlet UILabel *lblEngage;
@property (weak, nonatomic) IBOutlet UILabel *lblStatsEngage;
@property (weak, nonatomic) IBOutlet BTStatsView *statsReward;
@end

@implementation BTMainVCBusiness

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBusinessSurveys) name:ModelUserUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStats)        name:ModelUserUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForEmailAndPinCode) name:RestClientDidAuthenticateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStats)        name:ModelMessagesUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStats)        name:ModelMessageSessionsUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activateSurveys)     name:ModelUserUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activateSurveys)     name:ModelUserSubscriptionUpdatedNotification object:nil];

    [_surveyScrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAddSurveyAction)]];
    
    [self updateBusinessView];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self activateSurveys];
    [self refreshStats];
    [self checkForEmailAndPinCode];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)userType {
    return nil;
}

#pragma mark - Actions

- (void)openAddSurveyAction {
    [self performSegueWithIdentifier:@"AddSurveySegue" sender:nil];
}

- (void)presentProfileVC:(BOOL)animated {
    
}

- (void)presentMessageVC:(BOOL)animated {
    
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:_statsScrollView]) {
        _pageControl.currentPage = round(scrollView.contentOffset.x / scrollView.bounds.size.width);
    } else {
        _surveyPageControl.currentPage = round(scrollView.contentOffset.x / SURVEY_VIEW_SIZE.width);
    }
}


#pragma mark - Stats

- (void)refreshStats {
    NSArray *messageSessions = Model.messageSessions;
    if (messageSessions.count) {
        float countPInteraction = 0, countNInteraction = 0, countP = 0, countN = 0, countI = 0, countRewards = 0;
        
        NSTimeInterval timeIntervalFor30Days = 60 * 60 * 24 * 30;
        NSDate *dateNow = [NSDate date];
        
        for (BTMessageSession *messageSession in messageSessions) {
            // negative interaction
            NSArray *messages = messageSession.messages;
            for (int i = (int)messages.count-1; i>=0; i--) {
                BTMessage *message = messages[i];
                if ([message isUserMessage]) {
                    if ([dateNow timeIntervalSinceDate:message.createdAt] < timeIntervalFor30Days) {
                        if (messageSession.lastUserStateMessage.type == BTMessageTypeUserStatePositive) {
                            countPInteraction++;
                        } else if (messageSession.lastUserStateMessage.type == BTMessageTypeUserStateNegative) {
                            countNInteraction++;
                        }
                    }
                    break;
                }
            }
            
            // positive count
            if (messageSession.firstMessage.type == BTMessageTypeFeedbackPositive) {
                countP++;
            } else if (messageSession.firstMessage.type == BTMessageTypeFeedbackNegative) {
                countN++;
            } else {
                countI++;
            }
            
            // reward count
            if (messageSession.incentives.count) {
                countRewards++;
            }
        }
        
        _statsEngage.statsData = @[
                                   @{
                                       @"percentage" : @(countP / messageSessions.count),
                                       @"bg"         : @"stats_bg_1"
                                       },
                                   @{
                                       @"percentage" : @(countN / messageSessions.count),
                                       @"bg"         : @"stats_bg_2"
                                       },
                                   @{
                                       @"percentage" : @(countI / messageSessions.count),
                                       @"bg"         : @"stats_bg_3"
                                       },
                                   ];

        NSMutableAttributedString *statString = [[NSMutableAttributedString alloc] init];
        [statString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Positive %d%%\n\n", (int)(countP * 100 / messageSessions.count)] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Gotham-Medium" size:11.f], NSFontAttributeName, DEFAULT_GREEN_COLOR, NSForegroundColorAttributeName, nil]]];
        [statString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Negative %d%%\n\n", (int)(countN * 100 / messageSessions.count)] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Gotham-Medium" size:11.f], NSFontAttributeName, DEFAULT_RED_COLOR, NSForegroundColorAttributeName, nil]]];
        [statString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Ideas %d%%", (int)(countI * 100 / messageSessions.count)] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Gotham-Medium" size:11.f], NSFontAttributeName, DEFAULT_GOLD_COLOR, NSForegroundColorAttributeName, nil]]];
        _lblStatsEngage.attributedText = statString;
        [_statsEngage setNeedsDisplay];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        NSString *pieceString;
        if (messageSessions.count == 1) {
            pieceString = @"1 piece";
        } else {
            pieceString = [NSString stringWithFormat:@"%d pieces", (int) messageSessions.count];
        }
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"You've received %@ of feedback. All feedback is an opportunity to engage with your customers.", pieceString] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Gotham-Book" size:11.f], NSFontAttributeName, DEFAULT_TEXT_COLOR, NSForegroundColorAttributeName, nil]]];
        
        _lblEngage.attributedText = attributedString;
        
        CGFloat percentage = (countPInteraction + countNInteraction) ? (countPInteraction / (countPInteraction + countNInteraction)) : 1;
        _statsNoNegative.statsData = @[
                                       @{
                                           @"percentage" : @(percentage),
                                           @"bg"         : @"stats_bg_1"
                                           },
                                       @{
                                           @"percentage" : @(1-percentage),
                                           @"bg"         : @"stats_bg_2"
                                           }
                                       ];
        _statsNoNegative.text = [NSString stringWithFormat:@"%d%%", (int)(percentage * 100)];
        _statsNoNegative.textColor = DEFAULT_GREEN_COLOR;
        [_statsNoNegative setNeedsDisplay];
        
        percentage = countRewards / messageSessions.count;
        _statsReward.statsData = @[
                                   @{
                                       @"percentage" : @(percentage),
                                       @"bg"         : @"stats_bg_3"
                                       }
                                   ];
        _statsReward.text = [NSString stringWithFormat:@"%d%%", (int)(percentage * 100)];
        _statsReward.textColor = DEFAULT_GOLD_COLOR;
        [_statsReward setNeedsDisplay];
    }
}


#pragma mark - Survey

- (void)activateSurveys {

    BOOL isProSubscribed = [@"PRO" isEqualToString:Model.currentUser.business.subscription.subscriptionPlan];
    
    [self showDisabledView:!isProSubscribed];
    if (isProSubscribed) {
        [self initSurveys];
        [self loadBusinessSurveys];
    }
}

- (void)loadBusinessSurveys {
    [RestClient getAllSurveysForBusiness:Model.currentUser.business.objectId Completion:^(BOOL success, NSString *code, id response) {
        if (success) {
            NSArray *surveys = [BTSurvey objectsWithJSONArray:response[@"surveys"]];
            surveys = [surveys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(surveyType LIKE %@) OR (surveyType LIKE %@)",
                                                            SURVEY_TYPE_CUSTOM, SURVEY_TYPE_DEFAULT]];
            surveys = [surveys sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"surveyType" ascending:YES],
                                                             [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO]]];
            _surveys = [NSMutableArray arrayWithArray:surveys];
            
            [self initSurveys];
        }
    }];
}

- (void)initSurveys {
    [_surveyScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < _surveys.count; i++) {
        BTSurvey *survey = _surveys[i];
        UIView *surveyView = [[UIView alloc] initWithFrame:CGRectMake(SURVEY_VIEW_SIZE.width * i, 0.f,
                                                                      SURVEY_VIEW_SIZE.width, SURVEY_VIEW_SIZE.height)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 13.f, 300.f, 35.f)];
        titleLabel.tag = 1;
        titleLabel.numberOfLines = 2;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = RGB(108, 108, 108);
        titleLabel.font = [UIFont fontWithName:@"Gotham-Book" size:17.f];
        titleLabel.text = survey.question;
        [surveyView addSubview:titleLabel];

        BTBarChartView *chartView = [[BTBarChartView alloc] initWithFrame:CGRectMake(19.f, 60.f, 282.f, 35.f)];
        chartView.tag = 2;
        chartView.percentage = survey.positivePercentage;
        chartView.isEmpty = (survey.totalVotes == 0);
        [surveyView addSubview:chartView];
        
        UILabel *lblTotalVotes = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 100.f, SURVEY_VIEW_SIZE.width, 12.f)];
        lblTotalVotes.tag = 3;
        lblTotalVotes.textColor = RGB(108, 108, 108);
        lblTotalVotes.textAlignment = NSTextAlignmentCenter;
        lblTotalVotes.font = [UIFont fontWithName:@"Gotham-Book" size:11.f];
        lblTotalVotes.text = [NSString stringWithFormat:@"%d votes", (int)survey.totalVotes];
        [surveyView addSubview:lblTotalVotes];
        
        [_surveyScrollView addSubview:surveyView];
    }
    
    [_surveyScrollView setContentSize:CGSizeMake(SURVEY_VIEW_SIZE.width * _surveys.count, 0.f)];
    _surveyPageControl.numberOfPages = _surveys.count;
}

- (void)createSurveyWithQuestion:(NSString *)question {
}

#pragma mark Survey Template Delegate

-(void)templateVC:(BTTemplateVC *)templateVC DidCreateTemplateWithString:(NSString *)templateString {
    BTSurvey *survey = [BTSurvey surveyWithQuestion:templateString];
    [RestClient createSurveyWithQuestion:survey.question
                                 Options:survey.options
                                    Type:survey.type
                                  Status:survey.status
                              Completion:^(BOOL success, NSString *code, id response) {
                                  if (success) {
                                      [_surveys insertObject:[BTSurvey objectWithJSONDictionary:response[@"survey"]] atIndex:0];

                                      templateVC.dataSource = _surveys;
                                      [templateVC reloadData];
                                  }
                              }];
}

- (void)templateVC:(BTTemplateVC *)templateVC DidSelectTemplateAtIndex:(NSInteger)index {
    
}

- (NSString *)templateVC:(BTTemplateVC *)templateVC stringForEditPaneAtIndex:(NSInteger)index {
    BTSurvey *survey = _surveys[index];
    
    if ([SURVEY_TYPE_DEFAULT isEqualToString:survey.surveyType]) {
        return nil;
    }
    
    if ([SURVEY_STATUS_LIVE isEqualToString:survey.status]) {
        if (survey.totalVotes)
            return @"PAUSE";
        else
            return @"DELETE";
    } else
        return @"ACTIVATE";
}

- (void)templateVC:(BTTemplateVC *)templateVC didTapEditAtIndex:(NSInteger)index {
    BTSurvey *survey = _surveys[index];
    
    [RestClient updateSurveyWithId:survey.objectId
                              Type:nil
                            Status:[SURVEY_STATUS_LIVE isEqualToString:survey.status] ? SURVEY_STATUS_PAUSED : SURVEY_STATUS_LIVE
                        Completion:nil];
    
    if ([SURVEY_STATUS_LIVE isEqualToString:survey.status]) {
        if (survey.totalVotes)
            survey.status = SURVEY_STATUS_PAUSED;
        else
            [_surveys removeObjectAtIndex:index];
    } else
        survey.status = SURVEY_STATUS_LIVE;
    
    templateVC.dataSource = _surveys;
    [templateVC reloadData];
}


#pragma mark - Email & PinCode

- (void)checkForEmailAndPinCode {
    if (Model.currentUser.businessId && (!Model.currentUser.email.length || !Model.currentUser.pinCode.length)) {
        [self performSegueWithIdentifier:@"ProfileSetupFinalVCSegue" sender:nil];
    }
}

#pragma mark Profile Setup Final VC

- (void)profileSetupFinalVC:(BTProfileSetupFinalVC *)finalVC didEnterPin:(NSString *)pin Email:(NSString *)email {
    Model.currentUser.pinCode = pin;
    Model.currentUser.email = email;
    
    // update in backend
    [RestClient updateUser:@"business" Profile:@{@"pincode" : pin.MD5, @"email" : email} Completion:^(BOOL success, NSString *code, id response) {
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ModelUserUpdatedNotification object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Misc

- (void)updateBusinessView
{
    BTBusiness *myBusiness = [Model currentUser].business;
    _lblBusinessName.text = myBusiness.name;
    
    NSString *addressString = [myBusiness.address stringByReplacingOccurrencesOfString:@", United States" withString:@""];
    NSArray *addressStringComponents = [addressString componentsSeparatedByString:@", "];
    if (addressStringComponents.count == 2) {
        addressString = [NSString stringWithFormat:@"%@\n%@", addressStringComponents.firstObject, addressStringComponents.lastObject];
    } else if (addressStringComponents.count > 2) {
        NSArray *subComponents = [addressStringComponents subarrayWithRange:NSMakeRange(0, addressStringComponents.count - 2)];
        addressString = [NSString stringWithFormat:@"%@\n%@, %@", [subComponents componentsJoinedByString:@", "], addressStringComponents[addressStringComponents.count-2], addressStringComponents[addressStringComponents.count-1]];
    }
    _lblBusinessAddress.text = addressString;
}

- (void)showDisabledView:(BOOL)show {
    _surveyDisabledView.hidden = !show;
    _btnAddSurvey.hidden = show;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"AddSurveySegue"]) {
        BTTemplateVC *surveyVC = segue.destinationViewController;
        if (!_surveys) {
            _surveys = [NSMutableArray array];
        }
        surveyVC.CellClass = [BTSurveyTVC class];
        surveyVC.dataSource = _surveys;
        surveyVC.delegate = self;
        surveyVC.maximumLength = 80;
        
    } else if ([segue.identifier isEqualToString:@"ProfileSetupFinalVCSegue"]) {
        BTProfileSetupFinalVC *finalVC = segue.destinationViewController;
        finalVC.delegate = self;
    }
}


@end
