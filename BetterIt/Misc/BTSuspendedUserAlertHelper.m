//
//  BTSuspendedUserAlertHelper.m
//  BetterIt
//
//  Created by Matias Pan on 3/11/16.
//  Copyright © 2016 Maikel. All rights reserved.
//

#import "BTSuspendedUserAlertHelper.h"
#import <UIKit/UIKit.h>
#import <UIAlertView+Blocks.h>
#import "BTModel.h"

UIAlertView *userAlertView;
UIAlertView *businessAlertView;

@implementation BTSuspendedUserAlertHelper

+ (void)showUserSuspendedAlert {
    if (userAlertView) {
        return;
    }
    
    userAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Your account has been suspended. If you believe this was in error, please email support@betterit.io" cancelButtonItem:[RIButtonItem itemWithLabel:@"Contact Customer Support" action:^{
        
        [[UIApplication sharedApplication] openURL:[self mailURL]];
        userAlertView = nil;
        
    }] otherButtonItems:nil];
    
    [userAlertView show];
    
}

+ (void)showBusinessSuspendedAlert {
    if (businessAlertView) {
        return;
    }
    
    businessAlertView =  [[UIAlertView alloc] initWithTitle:nil message:@"There's an issue with your account. Please contact customer service" cancelButtonItem:[RIButtonItem itemWithLabel:@"Contact Customer Support" action:^{

        [[UIApplication sharedApplication] openURL:[self mailURL]];
        businessAlertView = nil;
        
    }] otherButtonItems:nil];
    
    [businessAlertView show];
}

+ (NSURL *)mailURL {
    NSString *urlString = [NSString stringWithFormat:@"Message from suspended user %@", [Model userForType:BTUserTypeNormal].username];
    
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[urlString UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"mailto:support@betterit.io?subject=%@", output]];
}

@end
