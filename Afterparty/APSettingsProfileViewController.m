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
#import "APUtil.h"

@interface APSettingsProfileViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet APLabel *usernameLabel;
@property (weak, nonatomic) IBOutlet APTextField *emailTextField;
@property (weak, nonatomic) IBOutlet APButton *linkWithTwitterButton;
@property (weak, nonatomic) IBOutlet APButton *linkWithFacebookButton;
@property (weak, nonatomic) IBOutlet APTextField *blurbTextField;
@property (weak, nonatomic) IBOutlet APButton *dataTrackingButton;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet APButton *signOutButton;
@property (weak, nonatomic) IBOutlet APLabel *emailFieldLabel;
@property (weak, nonatomic) IBOutlet APLabel *blurbFieldLabel;
@property (weak, nonatomic) IBOutlet APLabel *versionLabel;

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
    [self.profilePhotoView setImageWithURL:[NSURL URLWithString:user[kPFUserProfilePhotoURLKey]]];
  }
  BOOL isTrackingData = [user[kPFUserDataTrackingKey] boolValue];
  self.isTracking = isTrackingData;
  if (user.email) {
    self.emailTextField.text = user.email;
  }
  if (user[kPFUserBlurbKey]) {
    self.blurbTextField.text = user[kPFUserBlurbKey];
  }
  if (user[kPFUserProfilePhotoURLKey]) {
    [self.profilePhotoView setImageWithURL:[NSURL URLWithString:user[kPFUserProfilePhotoURLKey]]];
  }
  self.blurbTextField.delegate = self;
  
  [self updateButtonsText];
}

- (void)updateButtonsText {
  [self.linkWithTwitterButton styleWithClearBackground];
  [self.linkWithFacebookButton styleWithClearBackground];
  [self.signOutButton styleWithClearBackground];
  [self.dataTrackingButton styleWithClearBackground];
  [self.emailTextField styleForPasswordEntry];
  [self.blurbTextField styleForPasswordEntry];
  [self.emailFieldLabel styleForType:LabelTypeTableViewCellAttribute];
  self.emailFieldLabel.textColor = [UIColor afterpartyTealBlueColor];
  [self.blurbFieldLabel styleForType:LabelTypeTableViewCellAttribute];
  self.blurbFieldLabel.textColor = [UIColor afterpartyTealBlueColor];
  [self.usernameLabel styleForType:LabelTypeTableViewCellAttribute];
  self.usernameLabel.textColor = [UIColor afterpartyTealBlueColor];
  [self.versionLabel styleForType:LabelTypeTableViewCellAttribute withText:[NSString stringWithFormat:@"v%@", [APUtil getVersion]]];
  self.versionLabel.textColor = [UIColor afterpartyTealBlueColor];
}

#pragma mark - IBAction Methods

- (IBAction)twitterButtonLinkTapped:(id)sender {
  [SVProgressHUD show];
  [[APConnectionManager sharedManager] linkTwitterWithSuccess:^{
    [SVProgressHUD showSuccessWithStatus:@"linked!"];
  } failure:^(NSError *error) {
    [SVProgressHUD showErrorWithStatus:@"couldn't link your twitter account"];
  }];
}

- (IBAction)facebookButtonLinkTapped:(id)sender {
  [SVProgressHUD show];
  [[APConnectionManager sharedManager] linkFacebookWithSuccess:^{
    [SVProgressHUD showSuccessWithStatus:@"linked!"];
    [[APConnectionManager sharedManager] getFacebookUserDetailsWithSuccessBlock:^(NSDictionary *dictionary) {
      [self loadUserData];
    } failure:^(NSError *error) {
      NSLog(@"couldnt get details");
    }];
  } failure:^(NSError *error) {
    [SVProgressHUD showErrorWithStatus:@"couldn't link your facebook account"];
  }];
}

- (IBAction)dataTrackingButtonTapped:(id)sender {
    [[[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:@"...are coming soon...soon..." delegate:nil cancelButtonTitle:@"Nice" otherButtonTitles:nil] show];
}

- (IBAction)signOutButtonTapped:(id)sender {
  [PFUser logOut];
  [[NSNotificationCenter defaultCenter] postNotificationName:kCheckCurrentUser object:nil userInfo:nil];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [SVProgressHUD show];
  if (textField == self.blurbTextField) {
    [[APConnectionManager sharedManager] saveUserBlurb:self.blurbTextField.text success:^{
      [SVProgressHUD showSuccessWithStatus:@"blurb saved"];
    } failure:^(NSError *error) {
      [SVProgressHUD showErrorWithStatus:@"couldn't save blurb"];
    }];
  } else if (textField == self.emailTextField) {
    [[APConnectionManager sharedManager] saveUserEmail:self.emailTextField.text success:^{
      [SVProgressHUD showSuccessWithStatus:@"email saved"];
    } failure:^(NSError *error) {
      [SVProgressHUD showErrorWithStatus:@"couldn't save email"];
    }];
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return NO;
}

@end