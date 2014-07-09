//
//  APSettingsProfileViewController.m
//  Afterparty
//
//  Created by David Okun on 7/9/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSettingsProfileViewController.h"
#import "APLabel.h"
#import "APButton.h"
#import "APTextField.h"
#import <Parse/Parse.h>
#import <UIKit+AFNetworking.h>
#import "UIColor+APColor.h"
#import "APConstants.h"
#import "APConnectionManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface APSettingsProfileViewController ()

@property (weak, nonatomic) IBOutlet APLabel *usernameLabel;
@property (weak, nonatomic) IBOutlet APTextField *emailTextField;
@property (weak, nonatomic) IBOutlet APButton *linkWithTwitterButton;
@property (weak, nonatomic) IBOutlet APButton *linkWithFacebookButton;
@property (weak, nonatomic) IBOutlet APTextField *blurbTextField;
@property (weak, nonatomic) IBOutlet APButton *dataTrackingButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet APButton *signOutButton;

@property (assign, nonatomic) BOOL isTracking;
@property (assign, nonatomic) BOOL isLinkedWithFacebook;
@property (assign, nonatomic) BOOL isLinkedWithTwitter;

- (IBAction)twitterButtonLinkTapped:(id)sender;
- (IBAction)facebookButtonLinkTapped:(id)sender;
- (IBAction)dataTrackingButtonTapped:(id)sender;
- (IBAction)signOutButtonTapped:(id)sender;

@end

@implementation APSettingsProfileViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadUserData];
  self.view.backgroundColor = [UIColor afterpartyOffWhiteColor];
    // Do any additional setup after loading the view.
}

- (void)loadUserData {
  PFUser *user = [PFUser currentUser];
  [self.usernameLabel styleForType:LabelTypeStandard withText:user.username];
  if (self.profileImage) {
    self.profilePhotoView.image = self.profileImage;
  } else {
    [self.profilePhotoView setImageWithURL:[NSURL URLWithString:user[@"profilePhotoURL"]]];
  }
  BOOL isTrackingData = [user[@"dataTracking"] boolValue];
  self.isTracking = isTrackingData;
  if (user.email) {
    self.emailTextField.text = user.email;
  }
  if (user[@"blurb"]) {
    self.blurbTextField.text = user[@"blurb"];
  }
  
  [self updateButtonsText];
}

- (void)updateButtonsText {
  self.dataTrackingButton.titleLabel.text = (self.isTracking) ? @"opt out of data tracking" : @"opt into data tracking";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction Methods

- (IBAction)twitterButtonLinkTapped:(id)sender {
  
}

- (IBAction)facebookButtonLinkTapped:(id)sender {
  
}

- (IBAction)dataTrackingButtonTapped:(id)sender {
  self.isTracking = !self.isTracking;
  [[APConnectionManager sharedManager] saveUserTrackingParameter:self.isTracking success:^{
    [SVProgressHUD showSuccessWithStatus:@"data tracking preferences saved"];
    [self updateButtonsText];
  } failure:^(NSError *error) {
    self.isTracking = !self.isTracking;
    [SVProgressHUD showErrorWithStatus:@"try again later"];
  }];
}

- (IBAction)signOutButtonTapped:(id)sender {
  [PFUser logOut];
  [[NSNotificationCenter defaultCenter] postNotificationName:kCheckCurrentUser object:nil userInfo:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
