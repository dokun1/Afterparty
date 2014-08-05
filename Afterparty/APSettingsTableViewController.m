//
//  APSettingsTableViewController.m
//  Afterparty
//
//  Created by David Okun on 7/8/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSettingsTableViewController.h"
#import "APSettingsProfileViewController.h"
#import <UIKit+AFNetworking.h>
#import <Parse/Parse.h>
#import "APConstants.h"
#import "UIColor+APColor.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface APSettingsTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) PFUser *currentUser;

@end

@implementation APSettingsTableViewController

- (void)viewDidLoad {
  self.currentUser = [PFUser currentUser];
  self.view.backgroundColor = [UIColor afterpartyOffWhiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.profilePicture setImageWithURL:[NSURL URLWithString:self.currentUser[kPFUserProfilePhotoURLKey]]];
  [SVProgressHUD dismiss];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:kSettingsProfileSegue]) {
    APSettingsProfileViewController *vc = (APSettingsProfileViewController*)segue.destinationViewController;
    if (self.profilePicture.image) {
      vc.profileImage = self.profilePicture.image;
    }
  }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
