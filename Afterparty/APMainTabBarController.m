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
#import "APUtil.h"
#import "APConnectionManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController setSelectedIndex:2];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self checkCurrentUser];
}

- (void)checkCurrentUser {
#warning replace with if (![PFUser currentUser])
  if (1 == 1) {
    [self performSegueWithIdentifier:kLoginSegue sender:self];
  }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    if ([APUtil shouldDownloadNewVersion]) {
      [SVProgressHUD showWithStatus:@"new version available"];
    }
  });
  NSString *latestVersion= [[NSUserDefaults standardUserDefaults] objectForKey:@"latestVersion"];
  if (![[APUtil getVersion] isEqualToString:latestVersion] && [PFUser currentUser] != nil) {
    [[APConnectionManager sharedManager] updateInstallVersionForUser:[PFUser currentUser] success:^(BOOL succeeded) {
      [[NSUserDefaults standardUserDefaults] setObject:[APUtil getVersion] forKey:@"latestVersion"];
      [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSError *error) {
    }];
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
