//
//  NoAnimationPushSegue.m
//  BetterIt
//
//  Created by devMac on 12/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "NoAnimationPushSegue.h"

@implementation NoAnimationPushSegue

- (void)perform {
    [[self.sourceViewController navigationController] pushViewController:self.destinationViewController animated:NO];
}

@end
