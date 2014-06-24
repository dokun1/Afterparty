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

@interface APLoginViewController () <FBLoginViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

typedef NS_ENUM(NSInteger, LoginState) {
  kNothing,
  kAfterpartyLogin,
  kAfterpartySignup,
  kFacebook,
  kTwitter
};

@property (weak, nonatomic) IBOutlet APTextField *emailAddressLoginField;
@property (weak, nonatomic) IBOutlet APTextField *passwordLoginField;
@property (weak, nonatomic) IBOutlet APLabel     *titleLabel;
@property (weak, nonatomic) IBOutlet APButton    *facebookLoginButton;
@property (weak, nonatomic) IBOutlet APButton    *twitterLoginButton;
@property (weak, nonatomic) IBOutlet APButton    *signUpButton;
@property (weak, nonatomic) IBOutlet APButton    *afterpartyLoginButton;
@property (strong, nonatomic) UIImageView *sunRisingImageView;

- (IBAction)loginButtonTapped:(id)sender;
- (IBAction)signupButtonTapped:(id)sender;
- (IBAction)goBackButtonTapped:(id)sender;
- (IBAction)forgotPasswordTapped:(id)sender;
- (IBAction)twitterSigninButtonTapped:(id)sender;
- (IBAction)facebookSigninButtonTapped:(id)sender;

@property (assign, nonatomic) LoginState     currentState;
@property (strong, nonatomic) FBLoginView    *fbLoginView;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount      *twitterAccount;

@end

@implementation APLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

- (FBLoginView *)facebookLoginView {
  FBLoginView *view = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_likes", @"user_friends"]];
  view.delegate = self;
  view.loginBehavior = FBSessionLoginBehaviorWithFallbackToWebView;
  
  return view;
}

- (IBAction)loginButtonTapped:(id)sender {
  [self fadeOutInitialSceneForLogin:YES];
}

- (void)styleUI {
  [self.emailAddressLoginField styleForLogin];
  [self.passwordLoginField styleForLogin];
  [self.titleLabel styleForType:LabelTypeLoginHeading];
  [self.facebookLoginButton style];
  [self.twitterLoginButton style];
  [self.signUpButton style];
  [self.afterpartyLoginButton style];
  self.signUpButton.backgroundColor = [UIColor clearColor];
  self.facebookLoginButton.backgroundColor = [UIColor clearColor];
  self.twitterLoginButton.backgroundColor = [UIColor clearColor];
  self.afterpartyLoginButton.backgroundColor = [UIColor clearColor];
  self.view.backgroundColor = [UIColor colorWithHexString:@"92C0BB" withAlpha:1.0f];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self fadeInInitialSceneWithDelay:0.8];
  [self animateSunUp];
}

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

- (void)fadeOutInitialSceneForLogin:(BOOL)isForLogin {
  [self.afterpartyLoginButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0];
  [self.signUpButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.1];
  [self.facebookLoginButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.2];
  [self.twitterLoginButton performSelector:@selector(afterparty_makeViewDisappearWithCompletion:) withObject:nil afterDelay:0.3];
  [self performSelector:@selector(fadeInLoginScene) withObject:nil afterDelay:0.7];
}

- (void)fadeInInitialSceneWithDelay:(NSTimeInterval)delay {
  [self.afterpartyLoginButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:delay];
  [self.signUpButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:delay+0.1];
  [self.facebookLoginButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:delay+0.2];
  [self.twitterLoginButton performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:delay+0.3];
}

- (void)fadeOutSignUpScene {
  
}

- (void)fadeInSignUpScene {
  
}

- (void)fadeOutLoginScene {
  
}

- (void)fadeInLoginScene {
  [self.emailAddressLoginField performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0];
  [self.passwordLoginField performSelector:@selector(afterparty_makeViewAppearWithCompletion:) withObject:nil afterDelay:0.1];
}

@end