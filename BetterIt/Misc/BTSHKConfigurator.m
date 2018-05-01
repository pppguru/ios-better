//
//  BTSHKConfigurator.m
//  BetterIt
//
//  Created by Developer on 04/05/2016.
//  Copyright © 2016 Maikel. All rights reserved.
//

#import <Social/Social.h>
#import "BTSHKConfigurator.h"


@implementation BTSHKConfigurator

- (NSString *)appURL {
    return @"https://itunes.apple.com/us/app/betterit/id977293428?mt=8";
}

- (NSString*)facebookAppId {
    return @"509342802591085";
}

- (NSString*)facebookLocalAppId {
    return @"";
}

- (NSNumber*)forcePreIOS6FacebookPosting {
    BOOL result = NO;
    //if they have an account on their device, then use it, but don't force a device level login
    if (NSClassFromString(@"SLComposeViewController")) {
        result = ![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
    }
    return [NSNumber numberWithBool:result];
}

- (NSString*)twitterConsumerKey {
    return @"zcbEuCg80CU8f3u1qlZ9HeZAa";
}

- (NSString*)twitterSecret {
    return @"hzh0oAXdWaUaXG073bpjmO2dqKlO8hP8EaNWgPBtj3MSM2tgq7";
}

- (NSString*)twitterCallbackUrl {
    return @"http://betterit.twitter.com";
}

- (NSNumber*)twitterUseXAuth {
    return [NSNumber numberWithInt:0];
}

- (NSString*)twitterUsername {
    return @"";
}

- (NSNumber *)useAppleShareUI {
    return @YES;
}

@end
