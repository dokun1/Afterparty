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
  // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
  [self checkCurrentUser];
}

- (void)checkCurrentUser {
  if (![PFUser currentUser]) {
    [self performSegueWithIdentifier:kLoginSegue sender:self];
  }
//  APLoginViewController *loginVC = (APLoginViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
//    [self presentViewController:loginVC animated:YES completion:nil];
//  if (![self currentUser]) {
//    APLoginViewController *loginVC = [[APLoginViewController alloc] init];
//    [self presentViewController:loginVC animated:YES completion:nil];
//  }
//  NSString *latestVersion= [[NSUserDefaults standardUserDefaults] objectForKey:@"latestVersion"];
//  if (![[APUtil getVersion] isEqualToString:latestVersion] && [PFUser currentUser] != nil) {
//    [[APConnectionManager sharedManager] updateInstallVersionForUser:[PFUser currentUser] success:^(BOOL succeeded) {
//      [[NSUserDefaults standardUserDefaults] setObject:[APUtil getVersion] forKey:@"latestVersion"];
//      [[NSUserDefaults standardUserDefaults] synchronize];
//    } failure:^(NSError *error) {
//      NSLog(@"Couldnt update version for user = %@", [error localizedDescription]);
//    }];
//  }
//  [self performSelectorInBackground:@selector(newInstallLogic) withObject:nil];
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
