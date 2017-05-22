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
#import "UIImage+APImage.h"
#import <Bolts/Bolts.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "APIntroViewController.h"
#import <ParseTwitterUtils/PFTwitterUtils.h>

static NSString *kVersionWhatsNewFilePath = @"APWhatsNew";
static NSString *kTermsAndConditionsFilePath = @"APTermsAndConditions";

static NSString *kWhatsNewSegue = @"WhatsNewSegue";
static NSString *kTermsAndConditionsSegue = @"TermsAndConditionsSegue";

@interface APSettingsTableViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IntroControllerDelegate>

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
@property (weak, nonatomic) IBOutlet APLabel *acknowledgementsLabel;
@property (weak, nonatomic) IBOutlet APLabel *termsAndConditionsLabel;
@property (weak, nonatomic) IBOutlet APLabel *websiteLabel;
@property (weak, nonatomic) IBOutlet APLabel *introScreenLabel;
@property (weak, nonatomic) IBOutlet APLabel *signOutLabel;
@property (weak, nonatomic) IBOutlet UIImageView *facebookIconView;
@property (weak, nonatomic) IBOutlet UIImageView *twitterIconView;

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;

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
    [self.facebookIconView setClipsToBounds:YES];
    [self.twitterIconView setClipsToBounds:YES];
    self.facebookIconView.layer.cornerRadius = 5.0f;
    self.twitterIconView.layer.cornerRadius = 5.0f;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [SVProgressHUD dismiss];

}

- (void)loadUserData {
    PFUser *user = [PFUser currentUser];
    self.isLinkedWithFacebook = [PFFacebookUtils isLinkedWithUser:self.currentUser];
    self.isLinkedWithTwitter = [PFTwitterUtils isLinkedWithUser:self.currentUser];
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
    self.blurbTextField.delegate = self;
    
    [self updateButtonsText];
    [self.profilePhotoView setImageWithURL:[NSURL URLWithString:self.currentUser[kPFUserProfilePhotoURLKey]]];

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
    [self.acknowledgementsLabel styleForType:LabelTypeTableViewCellAttribute];
    [self.termsAndConditionsLabel styleForType:LabelTypeTableViewCellAttribute];
    [self.websiteLabel styleForType:LabelTypeTableViewCellAttribute];
    [self.introScreenLabel styleForType:LabelTypeTableViewCellAttribute];
    [self.signOutLabel styleForType:LabelTypeTableViewCellAttribute];
    self.versionFieldLabel.textColor = [UIColor afterpartyBlackColor];
    self.acknowledgementsLabel.textColor = [UIColor afterpartyBlackColor];
    self.signOutLabel.textColor = [UIColor afterpartyBlackColor];
    self.websiteLabel.textColor = [UIColor afterpartyBlackColor];
    self.introScreenLabel.textColor = [UIColor afterpartyBlackColor];
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
        if (!self.isLinkedWithFacebook && !self.isLinkedWithTwitter) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
            [actionSheet showInView:self.view];
        }
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
            // version cell tapped, uses prepareForSegue
        }
        if (indexPath.row == 1) {
            //show acknowledgements and stuff here
        }
        if (indexPath.row == 2) {
            [self termsAndConditionsRowTapped];
        }
        if (indexPath.row == 3) {
            [self websiteButtonTapped];
        }
        if (indexPath.row == 4) {
            [self introScreenButtonTapped];
        }
        if (indexPath.row == 5) {
            [self signOutButtonTapped];
        }
    }
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        return;
    }
    self.imagePickerController = [[UIImagePickerController alloc] init];
    switch (buttonIndex) {
        case 0:
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
        case 1:
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        default:
            break;
    }
    self.imagePickerController.delegate = self;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate Methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    UIImage *croppedImage = [image imageSquareCrop:image];

    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
    [self.profilePhotoView setImage:croppedImage];
    [SVProgressHUD showWithStatus:@"saving avatar"];
    [[APConnectionManager sharedManager] saveImageForUserAvatar:croppedImage withSuccess:^{
        [SVProgressHUD showSuccessWithStatus:@"avatar saved!"];
        [self loadUserData];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"could not save avatar"];
    }];
}

#pragma mark - IBAction Methods

- (void)twitterButtonLinkTapped {
    if (!self.isLinkedWithTwitter) {
        [SVProgressHUD showWithStatus:@"linking twitter"];
        [[APConnectionManager sharedManager] linkTwitterWithSuccess:^{
            [SVProgressHUD showSuccessWithStatus:@"linked!"];
            [self loadUserData];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"couldn't link your twitter account"];
        }];
    }
}

- (void)facebookButtonLinkTapped {
    if (!self.isLinkedWithFacebook) {
        [SVProgressHUD showWithStatus:@"linking facebook"];
        [[APConnectionManager sharedManager] linkFacebookWithSuccess:^{
            [SVProgressHUD showSuccessWithStatus:@"linked!"];
            [[APConnectionManager sharedManager] getFacebookUserDetailsWithSuccessBlock:^(NSDictionary *dictionary) {
                [self loadUserData];
            } failure:^(NSError *error) {
            }];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"couldn't link your facebook account"];
        }];
    }
}

- (void)termsAndConditionsRowTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://afterparty.io/terms.html"]];
}

- (void)websiteButtonTapped {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://afterparty.io"]];
}

- (void)introScreenButtonTapped {
    APIntroViewController *controller = [[APIntroViewController alloc] init];
    controller.introDelegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)signOutButtonTapped {
    [PFUser logOut];
    [FBSession.activeSession close];
    [self.tableView reloadData];
    [APUtil eraseAllEventsFromMyEvents];
    [self loadUserData];
    [self.tabBarController setSelectedIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCheckCurrentUser object:nil userInfo:nil];
}

#pragma mark - IntroDelegate Methods

- (void)controllerDidFinish:(APIntroViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
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
}

@end
