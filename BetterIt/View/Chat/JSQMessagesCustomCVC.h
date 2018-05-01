//
//  JSQMessagesCustomCVC.h
//  BetterIt
//
//  Created by Maikel on 17/06/15.
//  Copyright (c) 2015 Maikel. All rights reserved.
//

#import "JSQMessagesCollectionViewCell.h"

@interface JSQMessagesCustomCVC : JSQMessagesCollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblPhotoDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgFeedbackIcon;

@property (assign, nonatomic) UIEdgeInsets textViewFrameInsets;
@end
