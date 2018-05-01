//
//  AppDelegate.h
//  BetterIt
//
//  Created by devMac on 09/02/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTRootVC.h"

@import CoreLocation;

#define appDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) NSDictionary *pushNotificationInfo;
@property (strong, nonatomic) CLLocation *IPLocation;

- (NSString *)applicationDocumentDirectory;
@end

