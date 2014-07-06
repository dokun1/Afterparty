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

@interface APMyEventsViewController ()

@property (strong, nonatomic) NSArray *events;

@end

@implementation APMyEventsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor afterpartyOffWhiteColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APSearchEventTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NearbyEventCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    self.events = [APUtil getMyEventsArray];
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
    
    NSString *endDate = [NSString stringWithFormat:@"ends %@",[df stringFromDate:eventInfo[@"endDate"]]];
    NSString *user = [NSString stringWithFormat:@"%@'S", [eventInfo[@"createdByUsername"] uppercaseString]];
    
    UIImage *image = [UIImage imageWithData:eventInfo[@"eventImageData"]];
  
  cell.userLabel.text = user;
  cell.eventNameLabel.text = eventName;
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
          [self performSegueWithIdentifier:@"EventSelectedSegue" sender:eventDict];
          break;
        }
    }
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"EventSelectedSegue"]) {
    APMyEventViewController *vc = (APMyEventViewController*)segue.destinationViewController;
    vc.eventDict = sender;
    vc.hidesBottomBarWhenPushed = YES;
  }
}

@end
