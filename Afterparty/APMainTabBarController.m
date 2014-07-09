//
//  APMainTabBarController.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APMainTabBarController.h"
#import "APUser.h"
#import "APLoginViewController.h"
#import "UIColor+APColor.h"
#import <Parse/Parse.h>
#import "APConstants.h"

@interface APMainTabBarController ()

@property (nonatomic, strong) APUser *currentUser;

@end

@implementation APMainTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.view.tintColor = [UIColor afterpartyTealBlueColor];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCurrentUser) name:kCheckCurrentUser object:nil];
  // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
  [self checkCurrentUser];
}

- (void)checkCurrentUser {
  if (![PFUser currentUser]) {
    [self performSegueWithIdentifier:kLoginSegue sender:self];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//  UIViewController *destination = segue.destinationViewController;
}


@end
