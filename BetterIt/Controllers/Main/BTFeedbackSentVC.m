//
//  BTFeedbackSentVC.m
//  BetterIt
//
//  Created by Maikel on 20/10/15.
//  Copyright © 2015 Maikel. All rights reserved.
//

#import "BTFeedbackSentVC.h"

#import <FacebookSDK/FacebookSDK.h>
#import <ShareKit/ShareKit.h>
#import <ShareKit/SHKFacebook.h>
#import <ShareKit/SHKiOSFacebook.h>
#import <ShareKit/SHKiOSTwitter.h>
#import <ShareKit/SHKMail.h>
#import <ShareKit/SHKTextMessage.h>
#import "BTFortuneCard.h"

@interface BTFeedbackSentVC ()
@property (weak, nonatomic) IBOutlet UILabel *lblFortune;

@end

@implementation BTFeedbackSentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _lblFortune.text = _fortuneText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)fortuneImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(640.f, 640.f), NO, 2.f);
    [BTFortuneCard drawFortune_cardCanvasWithFortuneText:_fortuneText];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Actions

- (IBAction)shareAction:(id)sender {
    [SHK setRootViewController:self];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Share On Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SHKiOSFacebook shareImage:[self fortuneImage] title:@"Get rewards for giving your anonymous feedback to any business with #BetterIt http://bit.ly/betterit"];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Share On Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SHKiOSTwitter shareImage:[self fortuneImage] title:@"Get rewards for giving your anonymous feedback to any business with #BetterIt http://bit.ly/betterit"];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Send Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SHKItem *imageItem = [SHKItem image:[self fortuneImage] title:@"I thought you'd like this fortune..."];
        imageItem.text = @"Get rewards for giving your anonymous feedback to any business with #BetterIt\nhttp://bit.ly/betterit";
        [SHKMail shareItem:imageItem];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Send SMS" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SHKItem *imageItem = [SHKItem image:[self fortuneImage] title:nil];
        imageItem.text = @"Get rewards for giving your anonymous feedback to any business with #BetterIt\nhttp://bit.ly/betterit";
        [SHKTextMessage shareItem:imageItem];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)nextAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
