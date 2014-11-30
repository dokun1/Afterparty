//
//  APSettingsTableViewController.m
//  Afterparty
//
//  Created by David Okun on 7/8/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSettingsTableViewController.h"
#import <UIKit+AFNetworking.h>
#import <Parse/Parse.h>
#import "APConstants.h"
#import "UIColor+APColor.h"
#import "APLabel.h"
#import "APTextField.h"
#import "APButton.h"
#import "APUtil.h"
#import "APConnectionManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "APSettingsTextViewController.h"

static NSString *kVersionWhatsNewFilePath = @"APWhatsNew";
static NSString *kTermsAndConditionsFilePath = @"APTermsAndConditions";

static NSString *kWhatsNewSegue = @"WhatsNewSegue";
static NSString *kTermsAndConditionsSegue = @"TermsAndConditionsSegue";

@interface APSettingsTableViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UIImage *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoView;
@property (weak, nonatomic) IBOutlet APLabel *usernameLabel;
@property (weak, nonatomic) IBOutlet APTextField *emailTextField;
@property (weak, nonatomic) IBOutlet APLabel *twitterLinkLabel;
@property (weak, nonatomic) IBOutlet APLabel *facebookLinkLabel;
@property (weak, nonatomic) IBOutlet APTextField *blurbTextField;
@property (weak, nonatomic) IBOutlet APLabel *emailFieldLabel;
@property (weak, nonatomic) IBOutlet APLabel *blurbFieldLabel;
@property (weak, nonatomic) IBOutlet APLabel *versionLabel;
@property (weak, nonatomic) IBOutlet APLabel *versionFieldLabel;
@property (weak, nonatomic) IBOutlet APLabel *termsAndConditionsLabel;
@property (weak, nonatomic) IBOutlet APLabel *signOutLabel;
@property (weak, nonatomic) IBOutlet UIImageView *facebookIconView;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIconView;
@property (strong, nonatomic) PFUser *currentUser;

@property (nonatomic) BOOL isLinkedWithFacebook;
@property (nonatomic) BOOL isLinkedWithTwitter;

@end

@implementation APSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        self.currentUser = [PFUser currentUser];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadUserData];
    [self.profilePhotoView setImageWithURL:[NSURL URLWithString:self.currentUser[kPFUserProfilePhotoURLKey]]];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  [SVProgressHUD dismiss];

}

- (void)loadUserData {
    PFUser *user = [PFUser currentUser];
    [self.usernameLabel styleForType:LabelTypeStandard withText:user.username];
    self.usernameLabel.textAlignment = NSTextAlignmentLeft;
    if (self.profileImage) {
        self.profilePhotoView.image = self.profileImage;
    } else {
        [self.profilePhotoView setImageWithURL:[NSURL URLWithString:user[kPFUserProfilePhotoURLKey]]];
    }
    if (user.email) {
        self.emailTextField.text = user.email;
    }
    if (user[kPFUserBlurbKey]) {
        self.blurbTextField.text = user[kPFUserBlurbKey];
    }
    if (user[kPFUserProfilePhotoURLKey]) {
        [self.profilePhotoView setImageWithURL:[NSURL URLWithString:user[kPFUserProfilePhotoURLKey]]];
    }
    self.isLinkedWithFacebook = [PFFacebookUtils isLinkedWithUser:self.currentUser];
    self.isLinkedWithTwitter = [PFTwitterUtils isLinkedWithUser:self.currentUser];
    self.blurbTextField.delegate = self;
    
    [self updateButtonsText];
}

- (void)updateButtonsText {
    [self.twitterLinkLabel styleForType:LabelTypeStandard];
    [self.facebookLinkLabel styleForType:LabelTypeStandard];
    self.twitterLinkLabel.textAlignment = NSTextAlignmentLeft;
    self.facebookLinkLabel.textAlignment = NSTextAlignmentLeft;
    [self.emailTextField styleForSettingsPage];
    [self.blurbTextField styleForSettingsPage];
    [self.emailFieldLabel styleForType:LabelTypeTableViewCellAttribute];
    self.emailFieldLabel.textColor = [UIColor afterpartyBlackColor];
    [self.blurbFieldLabel styleForType:LabelTypeTableViewCellAttribute];
    self.blurbFieldLabel.textColor = [UIColor afterpartyBlackColor];
    [self.usernameLabel styleForType:LabelTypeTableViewCellAttribute];
    self.usernameLabel.textColor = [UIColor afterpartyBlackColor];
#ifdef DEBUG
    [self.versionLabel styleForType:LabelTypeTableViewCellAttribute withText:[NSString stringWithFormat:@"v%@ DEV", [APUtil getVersion]]];
#else
    [self.versionLabel styleForType:LabelTypeTableViewCellAttribute withText:[NSString stringWithFormat:@"v%@", [APUtil getVersion]]];
#endif
    [self.versionFieldLabel styleForType:LabelTypeTableViewCellAttribute];
    [self.termsAndConditionsLabel styleForType:LabelTypeTableViewCellAttribute];
    [self.signOutLabel styleForType:LabelTypeTableViewCellAttribute];
    self.versionFieldLabel.textColor = [UIColor afterpartyBlackColor];
    self.signOutLabel.textColor = [UIColor afterpartyBlackColor];
    self.termsAndConditionsLabel.textColor = [UIColor afterpartyBlackColor];
    self.facebookLinkLabel.text = self.isLinkedWithFacebook ? @"facebook linked!" : @"link with facebook";
    self.facebookIconView.image = self.isLinkedWithFacebook ? [UIImage imageNamed:@"facebookLogo"] : [UIImage imageNamed:@"facebookLogoGray"];
    self.twitterLinkLabel.text = self.isLinkedWithTwitter ? @"twitter linked!" : @"link with twitter";
    self.twitterIconView.image = self.isLinkedWithTwitter ? [UIImage imageNamed:@"twitterLogo"] : [UIImage imageNamed:@"twitterLogoGray"];
    self.versionLabel.textColor = [UIColor afterpartyBlackColor];
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Question for you" message:@"Should tapping this cell give you the option to change your photo, even if you have already linked your social media profile?" delegate:nil cancelButtonTitle:@"I'd better tell David" otherButtonTitles:nil] show];
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self.emailTextField becomeFirstResponder];
        }
        if (indexPath.row == 1) {
            [self.blurbTextField becomeFirstResponder];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self facebookButtonLinkTapped];
        }
        if (indexPath.row == 1) {
            [self twitterButtonLinkTapped];
        }
    }
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            // version cell tapped
        }
        if (indexPath.row == 1) {
            //terms and conditions tapped
        }
        if (indexPath.row == 2) {
            [self signOutButtonTapped];
        }
    }
}

#pragma mark - IBAction Methods

- (void)twitterButtonLinkTapped {
    [SVProgressHUD show];
    [[APConnectionManager sharedManager] linkTwitterWithSuccess:^{
        [SVProgressHUD showSuccessWithStatus:@"linked!"];
        [self loadUserData];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"couldn't link your twitter account"];
    }];
}

- (void)facebookButtonLinkTapped {
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


- (void)signOutButtonTapped {
    [PFUser logOut];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCheckCurrentUser object:nil userInfo:nil];
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [SVProgressHUD show];
    if (textField == self.blurbTextField) {
        [[APConnectionManager sharedManager] saveUserBlurb:self.blurbTextField.text success:^{
            [SVProgressHUD showSuccessWithStatus:@"blurb saved!"];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"couldn't save blurb"];
        }];
    } else if (textField == self.emailTextField) {
        [[APConnectionManager sharedManager] saveUserEmail:self.emailTextField.text success:^{
            [SVProgressHUD showSuccessWithStatus:@"email saved!"];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"couldn't save email"];
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kWhatsNewSegue]) {
        APSettingsTextViewController *vc = (APSettingsTextViewController *)segue.destinationViewController;
        vc.textFilePath = kVersionWhatsNewFilePath;
    }
    else if ([segue.identifier isEqualToString:kTermsAndConditionsSegue]) {
        APSettingsTextViewController *vc = (APSettingsTextViewController *)segue.destinationViewController;
        vc.textFilePath = kTermsAndConditionsFilePath;
    }
}

@end
