//
//  APCreateEventLandingViewController.m
//  Afterparty
//
//  Created by David Okun on 6/28/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APCreateEventLandingViewController.h"
#import "APCreateEventViewController.h"
#import "APConstants.h"

@interface APCreateEventLandingViewController () <CreateEventDelegate>

@end

@implementation APCreateEventLandingViewController

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
  [self performSegueWithIdentifier:kCreateEventSegue sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:kCreateEventSegue]) {
    APCreateEventViewController *controller = (APCreateEventViewController*)segue.destinationViewController;
    controller.delegate = self;
  }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - CreateEventDelegate Methods

- (void)controllerDidFinish:(APCreateEventViewController *)controller {
    [self.tabBarController setSelectedIndex:1];
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
