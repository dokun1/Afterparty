//
//  APLoginViewController.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APLoginViewController.h"
#import "APTextField.h"
#import "APLabel.h"
#import "APButton.h"
#import <FXBlurView.h>
#import <FacebookSDK/Facebook.h>
#import "UIColor+APColor.h"
#import "UIView+APViewAnimations.h"
#import "APConnectionManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface APLoginViewController () <FBLoginViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

typedef NS_ENUM(NSInteger, LoginState) {
  kNothing,
  kAfterpartyLogin,
  kAfterpartySignup,
  kFacebook,
  kTwitter
};

@property (weak, nonatomic) IBOutlet APTextField *usernameLoginField;
@property (weak, nonatomic) IBOutlet APTextField *passwordLoginField;
@property (weak, nonatomic) IBOutlet APTextField *emailAddressLoginField;
@property (weak, nonatomic) IBOutlet APLabel     *titleLabel;
@property (weak, nonatomic) IBOutlet APButton    *facebookLoginButton;
@property (weak, nonatomic) IBOutlet APButton    *twitterLoginButton;
@property (weak, nonatomic) IBOutlet APButton    *signUpButton;
@property (weak, nonatomic) IBOutlet APButton    *signUpCredentialsButton;
@property (weak, nonatomic) IBOutlet APButton    *afterpartyLoginButton;
@property (weak, nonatomic) IBOutlet APButton    *afterpartyCredentialsLoginButton;
@property (weak, nonatomic) IBOutlet APButton    *goBackButton;

@property (strong, nonatomic) UIImageView *sunRisingImageView;

- (IBAction)loginButtonTapped:(id)sender;
- (IBAction)signupButtonTapped:(id)sender;
- (IBAction)forgotPasswordTapped:(id)sender;
- (IBAction)twitterSigninButtonTapped:(id)sender;
- (IBAction)facebookSigninButtonTapped:(id)sender;
- (IBAction)loginCredentialsButtonTapped:(id)sender;
- (IBAction)signUpCredentialsButton:(id)sender;
- (IBAction)goBackButtonTapped:(id)sender;

@property (assign, nonatomic) LoginState     currentState;
@property (strong, nonatomic) FBLoginView    *fbLoginView;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount      *twitterAccount;

@end

@implementation APLoginViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (!_sunRisingImageView) {
    _sunRisingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sunRising"]];
    [self.view addSubview:_sunRisingImageView];
  }
  _sunRisingImageView.frame = CGRectMake(0, self.view.frame.size.height, 320, 202);
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self styleUI];
}

- (void)styleUI {
  [self.usernameLoginField styleForLogin];
  [self.emailAddressLoginField styleForLogin];
  [self.passwordLoginField styleForLogin];
  [self.titleLabel styleForType:LabelTypeLoginHeading];
  [self.facebookLoginButton style];
  [self.twitterLoginButton style];
  [self.signUpButton style];
  [self.signUpCredentialsButton style];
  [self.afterpartyLoginButton style];
  [self.afterpartyCredentialsLoginButton style];
  [self.goBackButton style];
  self.signUpButton.backgroundColor = [UIColor clearColor];
  self.signUpCredentialsButton.backgroundColor = [UIColor clearColor];
  self.facebookLoginButton.backgroundColor = [UIColor clearColor];
  self.twitterLoginButton.backgroundColor = [UIColor clearColor];
  self.afterpartyLoginButton.backgroundColor = [UIColor clearColor];
  self.afterpartyCredentialsLoginButton.backgroundColor = [UIColor clearColor];
  self.goBackButton.backgroundColor = [UIColor clearColor];
  self.view.backgroundColor = [UIColor colorWithHexString:@"92C0BB" withAlpha:1.0f];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self fadeInInitialSceneWithDelay:0.8];
  [self animateSunUp];
}

#pragma mark - Sun Animation Methods

- (void)animateSunUp {
  [UIView animateWithDuration:2.0 delay:0.f usingSpringWithDamping:0.75 initialSpringVelocity:5.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    CGRect sunFrame = self.sunRisingImageView.frame;
    sunFrame.origin.y = self.view.bounds.size.height - (self.sunRisingImageView.frame.size.height - 25);
    self.sunRisingImageView.frame = sunFrame;

  } completion:^(BOOL finished) {
    
  }];
}

- (void)animateSunDown {
  [UIView animateWithDuration:3.5 delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    CGRect sunFrame = self.sunRisingImageView.frame;
    sunFrame.origin.y = self.view.bounds.size.height;
    self.sunRisingImageView.frame = sunFrame;
  } completion:nil];
}

#pragma mark - Field Animation Methods

- (void)fadeOutInitialSceneForLogin:(BOOL)isForLogin {
  [self.afterpartyLoginButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0];
  [self.signUpButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.1];
  [self.facebookLoginButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.2];
  [self.twitterLoginButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.3];
  if (isForLogin) {
    [self performSelector:@selector(fadeInLoginScene) withObject:nil afterDelay:0.7];
  } else {
    [self performSelector:@selector(fadeInSignUpScene) withObject:nil afterDelay:0.7];
  }
}

- (void)fadeInInitialSceneWithDelay:(NSTimeInterval)delay {
  [self.afterpartyLoginButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:delay];
  [self.signUpButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:delay+0.1];
  [self.facebookLoginButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:delay+0.2];
  [self.twitterLoginButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:delay+0.3];
}

- (void)fadeOutSignUpScene {
  [self.usernameLoginField performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0];
  [self.passwordLoginField performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.1];
  [self.emailAddressLoginField performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.2];
  [self.signUpCredentialsButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.3];
  [self.goBackButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.4];
}

- (void)fadeInSignUpScene {
  self.currentState = kAfterpartySignup;
  [self.usernameLoginField performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0];
  [self.passwordLoginField performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0.1];
  [self.emailAddressLoginField performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0.2];
  [self.signUpCredentialsButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0.3];
  [self.goBackButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0.4];
}

- (void)fadeOutLoginScene {
  [self.usernameLoginField performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0];
  [self.passwordLoginField performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.1];
  [self.afterpartyCredentialsLoginButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.2];
  [self.goBackButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.3];
}

- (void)fadeInLoginScene {
  self.currentState = kAfterpartyLogin;
  [self.usernameLoginField performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0];
  [self.passwordLoginField performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0.1];
  [self.afterpartyCredentialsLoginButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0.2];
  [self.goBackButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0.3];
}

#pragma mark - IBAction Methods

- (IBAction)loginCredentialsButtonTapped:(id)sender {
  [SVProgressHUD show];
  [self.usernameLoginField resignFirstResponder];
  [self loginUser];
}

- (IBAction)signupButtonTapped:(id)sender {
  [self fadeOutInitialSceneForLogin:NO];
}

- (IBAction)loginButtonTapped:(id)sender {
  [self fadeOutInitialSceneForLogin:YES];
}

- (IBAction)signUpCredentialsButton:(id)sender {
  [self.usernameLoginField resignFirstResponder];
  [SVProgressHUD show];
  [[APConnectionManager sharedManager] signUpUser:self.usernameLoginField.text
                                         password:self.passwordLoginField.text
                                            email:self.emailAddressLoginField.text
                                          success:^(BOOL succeeded) {
                                            [self loginUser];
                                          } failure:^(NSError *error) {
                                            [SVProgressHUD showErrorWithStatus:nil];
                                          }];
}

- (IBAction)goBackButtonTapped:(id)sender {
  if (self.currentState == kAfterpartySignup) {
    [self fadeOutSignUpScene];
  } else {
    [self fadeOutLoginScene];
  }
  self.currentState = kNothing;
  [self performSelector:@selector(fadeInInitialSceneWithDelay:) withObject:nil afterDelay:0.8];
}

- (IBAction)twitterSigninButtonTapped:(id)sender {
  self.currentState = kTwitter;
  
  self.accountStore = [[ACAccountStore alloc] init];
  
  //  We only want to receive Twitter accounts
  ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  
  [self.accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (!granted) {
        [SVProgressHUD showErrorWithStatus:@"Could not get access to your accounts"];
        return;
      }
      NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
      if ([accounts count] > 1) {
        [SVProgressHUD dismiss];
        [self showActionSheetForTwitterAccounts:accounts];
      }else if ([accounts count] == 1){
        self.twitterAccount = [accounts firstObject];
        [self loginWithTwitterAccount:self.twitterAccount andEmail:@""];
      }else{
        [SVProgressHUD showErrorWithStatus:@"No twitter account linked with phone"];
      }
    });
  }];
}

- (IBAction)facebookSigninButtonTapped:(id)sender {
  self.currentState = kFacebook;
  [SVProgressHUD show];
  [[APConnectionManager sharedManager] loginWithFacebookUsingPermissions:@[@"public_profile", @"email", @"user_friends"] success:^(PFUser *user) {
    [SVProgressHUD dismiss];
    [[APConnectionManager sharedManager] getFacebookUserDetailsWithSuccessBlock:^(NSDictionary *dictionary) {
    } failure:^(NSError *error) {
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
  } failure:^(NSError *error) {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
  }];
}

- (IBAction)forgotPasswordTapped:(id)sender {
  
}

- (void)loginUser {
  [[APConnectionManager sharedManager] loginWithUsername:self.usernameLoginField.text password:self.passwordLoginField.text success:^(PFUser *user) {
    [SVProgressHUD showSuccessWithStatus:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
  } failure:^(NSError *error) {
    [SVProgressHUD showErrorWithStatus:nil];
  }];
}

#pragma mark - Twitter Account Action Sheet Methods

-(void)showActionSheetForTwitterAccounts:(NSArray*)accounts {
  UIActionSheet *sheet = [[UIActionSheet alloc] init];
  [sheet setDelegate:self];
  [sheet setTitle:@"Accounts"];
  [sheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
  [accounts enumerateObjectsUsingBlock:^(ACAccount *account, NSUInteger idx, BOOL *stop) {
    [sheet addButtonWithTitle:account.username];
  }];
  [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
  self.twitterAccount = accounts[buttonIndex];
  [self loginWithTwitterAccount:self.twitterAccount andEmail:@""];
}

- (void)loginWithTwitterAccount:(ACAccount*)account andEmail:(NSString*)email {
  [SVProgressHUD show];
  [[APConnectionManager sharedManager] loginWithTwitterAccount:account success:^(PFUser *user) {
    [SVProgressHUD dismiss];
    [[APConnectionManager sharedManager] getTwitterUserDetailsForUsername:self.twitterAccount.username success:^(NSDictionary *dictionary) {
      NSLog(@"%@", dictionary);
    } failure:^(NSError *error) {
      NSLog(@"failure");
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
  } failure:^(NSError *error) {
    NSLog(@"failure");
    [SVProgressHUD showErrorWithStatus:nil];
  }];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}  
@end