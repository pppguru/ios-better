//
//  AppDelegate.m
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "AppDelegate.h"
#import "Common.h"
#import "BTRestClient.h"
#import "BTModel.h"
#import "BTConfig.h"
#import "NSDate+Additions.h"
#import <UIAlertView+Blocks.h>
#import <FTGooglePlacesAPIService.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "NSArray+Plist.h"
#import "BTNavigationController.h"
#import <Google/Analytics.h>
#import "IAPShare.h"
#import "WifiStatusHelper.h"
#import <INTULocationManager.h>
#import <ShareKit/SHKConfiguration.h>
#import "BTSHKConfigurator.h"
#import "SHKFacebook.h"


@interface AppDelegate () <CLLocationManagerDelegate, SKPaymentTransactionObserver> {
    BOOL showingWifiAlert;
}

@property (strong, nonatomic) UINavigationController *nav;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [FTGooglePlacesAPIService provideAPIKey:kGooglePlacesAPIKey];

    [Fabric with:@[CrashlyticsKit]];

    RestClient;
   
    if (IS_OS_8_OR_LATER) {
        //    [self startMonitoringVisits];

        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);

        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        _pushNotificationInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    }
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelNone;  // remove before app release
    
    // Store Kit
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[IAPShare sharedHelper].iap restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
        if (!error) {
            [self paymentQueue:payment updatedTransactions:payment.transactions];
        } else {
            NSLog(@"Error restoring purchases - %@", error);
        }
    }];
    
    // Share Kit
    DefaultSHKConfigurator *configurator = [[BTSHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [Model saveModel];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    [Model loadModel];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [RestClient rc_authenticateDevice];

    [SHKFacebook handleDidBecomeActive];

    if (![WifiStatusHelper isWiFiEnabled] && !showingWifiAlert && !TARGET_OS_SIMULATOR) {
        
        showingWifiAlert = true;
        
        [[[UIAlertView alloc] initWithTitle:@"Turn on WiFi" message:@"BetterIt is more accurate when your WiFi is turned on even if you're not connected to a network." cancelButtonItem:[RIButtonItem itemWithLabel:@"OK" action:^{
            
            showingWifiAlert = false;
            
        }] otherButtonItems:[RIButtonItem itemWithLabel:@"Settings" action:^{
            
            NSURL *url = [NSURL URLWithString:@"prefs:root=WIFI"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            
            showingWifiAlert = false;
            
        }], nil] show];
    }
    
    if ([INTULocationManager locationServicesState] != INTULocationServicesStateAvailable) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager GET:@"http://ipinfo.io/json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"ip response - %@", responseObject);
            NSArray *loc = [responseObject[@"loc"] componentsSeparatedByString:@","];
            if (loc.count > 1) {
                NSString *lat = [loc[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *lng = [loc[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                _IPLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lng doubleValue]];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ip response error - %@", error);
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [SHKFacebook handleWillTerminate];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSString* scheme = [url scheme];
    if ([scheme hasPrefix:[NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)]]) {
        return [SHKFacebook handleOpenURL:url sourceApplication:sourceApplication];
    }
    return YES;
}

#pragma mark - Visits

- (void)startMonitoringVisits
{
    CLLocationManager *locMgr = [[CLLocationManager alloc] init];
    locMgr.delegate = self;
    locMgr.desiredAccuracy = kCLLocationAccuracyBest;
    [locMgr startMonitoringVisits];
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit
{
    if (![visit.departureDate isEqual:[NSDate distantFuture]]) {
        NSArray *locationQueue = [NSArray bt_readFromPlistFile:kLocationQueueKey];
        locationQueue = [@[visit] arrayByAddingObjectsFromArray:locationQueue];
        [locationQueue bt_writeToPlistFile:kLocationQueueKey];
    }
    
    /**
     *  Make sure that we can actually send the user local notifications before scheduling any
     */
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types & UIUserNotificationTypeAlert) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertTitle = @"Visit";
        localNotification.alertBody = [NSString stringWithFormat:@"From: %@\nTo: %@\nLocation: (%f, %f)",
                                       [self.dateFormatter stringFromDate:visit.arrivalDate],
                                       [self.dateFormatter stringFromDate:visit.departureDate],
                                       visit.coordinate.latitude,
                                       visit.coordinate.longitude];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:15];

        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

//- (void)uploadLocation:(CLLocation *)location {
//    [_locationsQueue addObject:@{@"latitude" : @(location.coordinate.latitude),
//                                 @"longitude" : @(location.coordinate.longitude),
//                                 @"timestamp" : [location.timestamp bt_UTCString]}];
//    
//    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//        [RestClient updateLocations:_locationsQueue Completion:nil];
//        _locationsQueue = [NSMutableArray new];
//    }
//    
//    [BTConfig setObject:_locationsQueue forKey:kLocationQueueKey];
//}

- (NSString *)applicationDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return paths.firstObject;
}


#pragma mark - APNS

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [BTConfig setObject:deviceTokenString forKey:kAPNSTokenKey];
    [RestClient updateUserAPNSTokenWithCompletion:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    BTUserType userType;
    NSString *messageSessionId = userInfo[@"message_session_id"];

    if ([[Model messageSessionsForUser:BTUserTypeBusiness] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId == %@", messageSessionId]].count > 0) {
        userType = BTUserTypeBusiness;
    } else if ([[Model messageSessionsForUser:BTUserTypeNormal] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"objectId == %@", messageSessionId]].count > 0) {
        userType = BTUserTypeNormal;
    } else {
        if ([Model userForType:BTUserTypeBusiness]) {
            userType = BTUserTypeBusiness;
        } else {
            userType = BTUserTypeNormal;
        }
    }
    
    if (application.applicationState == UIApplicationStateActive) {
        [RestClient getAllMessageSessionsAs:Model.currentUserTypeString Completion:^(BOOL success, NSString *code, id response) {
            if (success) {
                [Model setMessageSessionsRaw:response[@"sessions"] forType:Model.currentUserType];
            }
        }];
    } else if (application.applicationState == UIApplicationStateInactive) {
        Model.currentUserType = userType;
        [RootVC reloadPages];
        [[NSNotificationCenter defaultCenter] postNotificationName:ModelUserUpdatedNotification object:nil];
        [RootVC gotoPage:BTPageIndexMessage animate:NO];
    }
}


#pragma mark - Store Kit

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        if (transaction.transactionState == SKPaymentTransactionStatePurchased ||
            transaction.transactionState == SKPaymentTransactionStateRestored) {
            if (transaction.transactionReceipt) {
                [[BTRestClient sharedInstance] subscribeBusinessWithTransactionData:transaction Completion:^(BOOL success, NSString *code, id response) {
                }];
            }
        }
        if (transaction.transactionState != SKPaymentTransactionStatePurchasing) {
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
}
@end
