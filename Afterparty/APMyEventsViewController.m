//
//  AfterpartyMyEventsViewController.m
//  Afterparty
//
//  Created by David Okun on 12/6/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import "APMyEventsViewController.h"
#import "APMyEventViewController.h"
#import "APSearchEventTableViewCell.h"
#import "UIAlertView+APAlert.h"
#import "UIColor+APColor.h"
#import "APUtil.h"
#import "APConstants.h"
#import "APCreateEventViewController.h"

@interface APMyEventsViewController () <CreateEventDelegate>

@property (strong, nonatomic) NSArray *events;

@end

@implementation APMyEventsViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.navigationController.navigationBar.barTintColor = [UIColor afterpartyOffWhiteColor];
    
  [self.tableView registerNib:[UINib nibWithNibName:@"APSearchEventTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NearbyEventCell"];
  UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped)];
  [self.navigationItem setRightBarButtonItems:@[btnAdd]];
  self.view.backgroundColor = [UIColor afterpartyOffWhiteColor];
    
}

- (void)viewDidAppear:(BOOL)animated {
  [self refreshEvents];
}

- (void)refreshEvents {
    [APUtil getMyEventsArrayWithSuccess:^(NSMutableArray *events) {
        self.events = events;
        [self.tableView reloadData];
    }];
}

- (void)addButtonTapped {
    [self performSegueWithIdentifier:kCreateEventSegue sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.events count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 170.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NearbyEventCell";
    APSearchEventTableViewCell *cell = (APSearchEventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)configureCell:(APSearchEventTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    NSDictionary *eventDict = self.events[indexPath.row];
    NSDictionary *eventInfo = [eventDict allValues].firstObject;
    NSString *eventName = eventInfo[@"eventName"];
    
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"hh:mm a MM/dd/yy"];
    });
    
    NSString *user = [NSString stringWithFormat:@"%@'S", [eventInfo[@"createdByUsername"] uppercaseString]];
    
    UIImage *image = [UIImage imageWithData:eventInfo[@"eventImageData"]];
    NSString *endDate;
    cell.userLabel.text = user;
    cell.eventNameLabel.text = eventName;
    NSDate *endDateDate = eventInfo[@"endDate"];
    NSComparisonResult result = [endDateDate compare:[NSDate date]];
    switch (result){
        case NSOrderedAscending:
        case NSOrderedSame:
            cell.bannerView.backgroundColor = [UIColor afterpartyCoralRedColor];
            endDate = [NSString stringWithFormat:@"ended %@",[df stringFromDate:eventInfo[@"endDate"]]];
            break;
        case NSOrderedDescending:{
            cell.bannerView.backgroundColor = [UIColor afterpartyTealBlueColor];
            endDate = [NSString stringWithFormat:@"ends %@",[df stringFromDate:eventInfo[@"endDate"]]];
            break;
        }
    }
    cell.countdownLabel.text = endDate;
    [cell.eventImageView setImage:image];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *eventDict = self.events[indexPath.row];
    NSDictionary *eventInfo = [eventDict allValues].firstObject;
    NSDate *deleteDate = [eventInfo objectForKey:@"deleteDate"];
    NSComparisonResult result = [deleteDate compare:[NSDate date]];
    switch (result){
        case NSOrderedAscending:
          [UIAlertView showSimpleAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Sorry, %@ has ended.", [eventInfo objectForKey:@"eventName"]]];
          break;
        case NSOrderedSame:
          [UIAlertView showSimpleAlertWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Sorry, %@ has ended.", [eventInfo objectForKey:@"eventName"]]];
          break;
        case NSOrderedDescending:{
          [self performSegueWithIdentifier:kMyEventSelectedSegue sender:eventDict];
          break;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:kMyEventSelectedSegue]) {
    APMyEventViewController *vc = (APMyEventViewController*)segue.destinationViewController;
    vc.eventDict = sender;
    vc.hidesBottomBarWhenPushed = YES;
  } else if ([segue.identifier isEqualToString:kCreateEventSegue]) {
    APCreateEventViewController *controller = (APCreateEventViewController*)segue.destinationViewController;
    controller.delegate = self;
  }
}

#pragma mark - CreateEventDelegate Methods

- (void)controllerDidFinish:(APCreateEventViewController *)controller withEventID:(NSString *)eventID{
    [self.tabBarController setSelectedIndex:1];
    [controller dismissViewControllerAnimated:YES completion:nil];
    [APUtil getMyEventsArrayWithSuccess:^(NSMutableArray *events) {
        [events enumerateObjectsUsingBlock:^(NSDictionary *eventDict, NSUInteger idx, BOOL *stop) {
            NSString *checkEventID = eventDict.allKeys.firstObject;
            if ([checkEventID isEqualToString:eventID]) {
                [self performSegueWithIdentifier:kMyEventSelectedSegue sender:eventDict];
                *stop = YES;
            }
        }];
    }];
}

@end
