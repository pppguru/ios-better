//
//  BTMessageSessionTVC.h
//  BetterIt
//
//  Created by devMac on 20/03/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#ifndef BetterIt_BTMessageSessionTVC_h
#define BetterIt_BTMessageSessionTVC_h

#import "BTMessageSession.h"


@protocol BTMessageSessionTVCProtocol <NSObject>

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTimestamp;

@property (weak, nonatomic) BTMessageSession *messageSession;

@end



typedef UITableViewCell<BTMessageSessionTVCProtocol> BTMessageSessionTVC;

#endif
