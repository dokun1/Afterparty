//
//  AfterpartySearchEventsViewController.m
//  Afterparty
//
//  Created by David Okun on 11/13/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import "APSearchEventsViewController.h"
#import <Parse/Parse.h>
#import "APSearchEventTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "APSearchEventDetailViewController.h"
#import "UIColor+APColor.h"
#import "UIAlertView+APAlert.h"
#import "APEvent.h"
#import "APConstants.h"
#import "APUtil.h"

@import AddressBook;

@interface APSearchEventsViewController () <UISearchBarDelegate, CLLocationManagerDelegate, SearchEventDetailDelegate, UINavigationControllerDelegate, UINavigationBarDelegate>

@property (strong, nonatomic) NSMutableArray *venues;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (assign, nonatomic) BOOL isRefresh;
@property (assign, nonatomic) BOOL isForSearch;
@property (strong, nonatomic) NSString *initialSearch;
@property (assign, nonatomic) BOOL isLoading;

@end

@implementation APSearchEventsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSearchForEvent:(NSString *)eventID {
    self = [super init];
    if (self) {
        self.initialSearch = eventID;
        self.isForSearch = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor afterpartyOffWhiteColor];

  self.navigationController.delegate = self;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSearchNotification:) name:kSearchSpecificEventNotification object:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor afterpartyTealBlueColor]];
    [self.refreshControl addTarget:self action:@selector(refreshEvents) forControlEvents:UIControlEventValueChanged];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [self.searchBar sizeToFit];
    [self.searchBar setDelegate:self];
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar setPlaceholder:@"search afterparties"];
    [self.searchBar setTintColor:[UIColor afterpartyTealBlueColor]];
    
    [self.tableView setTableHeaderView:self.searchBar];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor afterpartyOffWhiteColor]];
    
    (self.isForSearch) ? [self searchForEventByID] : [self refreshEvents];
  
    [self.tableView registerNib:[UINib nibWithNibName:@"APSearchEventTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NearbyEventCell"];
  
  UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshEvents)];
  [self.navigationItem setRightBarButtonItems:@[btnRefresh]];
}

- (void)didReceiveSearchNotification:(NSNotification*)notification {
  self.initialSearch = (NSString*)notification.object;
  self.tabBarController.selectedIndex = 0;
  [self searchForEventByID];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (!self.isLoading) {
    [self refreshEvents];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.initialSearch = nil;
    [SVProgressHUD dismiss];
}

#pragma mark - LocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.currentLocation = [locations lastObject];
  [self.locationManager stopUpdatingLocation];
  [SVProgressHUD showWithStatus:@"finding events"];
  self.isLoading = YES;
  if ([PFUser currentUser]) {
    [[APConnectionManager sharedManager] getNearbyEventsForLocation:self.currentLocation success:^(NSArray *objects) {
      self.isLoading = NO;
      self.venues = [objects mutableCopy];
      dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.venues count] == 0) {
          [SVProgressHUD showErrorWithStatus:@"No events nearby"];
        }else{
          [SVProgressHUD dismiss];
        }
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
      });
    } failure:^(NSError *error) {
      [SVProgressHUD showErrorWithStatus:@"Server error"];
      self.isLoading = NO;
    }];
  }
}

#pragma mark - UISearchBarDelegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [[APConnectionManager sharedManager] searchEventsByName:searchBar.text success:^(NSArray *objects) {
        self.venues = [objects mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSError *error) {
        [UIAlertView showSimpleAlertWithTitle:@"Error" andMessage:@"There was an error searching for events by that name. Please try a different search."];
    }];
}

-(void)searchForEventByID {
    [SVProgressHUD showWithStatus:@"searching for event"];
    [self.searchBar resignFirstResponder];
    [[APConnectionManager sharedManager] searchEventsByID:self.initialSearch success:^(NSArray *objects) {
        [SVProgressHUD dismiss];
        self.venues = [objects mutableCopy];
        APEvent *searchedEvent = self.venues.firstObject;
        [APUtil saveEventToMyEvents:searchedEvent];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"couldn't find event"];
    }];
}

-(void)refreshEvents {
  if ([PFUser currentUser] && !self.initialSearch) {
      [self.locationManager startUpdatingLocation];
  }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.venues count];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 170.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NearbyEventCell";
    APSearchEventTableViewCell *cell = (APSearchEventTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[APSearchEventTableViewCell alloc] init];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(APSearchEventTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    APEvent *event = self.venues[indexPath.row];
    NSString *eventName = event.eventName;
    
    static NSDateFormatter *df = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"hh:mm a MM/dd/yy"];
    });
    
    NSString *user = [NSString stringWithFormat:@"%@'S", [event.createdByUsername uppercaseString]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        PFFile *imageFile = (PFFile*)[event eventImage];
        NSData *imageData = [imageFile getData];
        [event setEventImageData:imageData];
        UIImage *coverImage = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.eventImageView setImage:coverImage];
        });
    });
    
    NSString *imageName = [NSString stringWithFormat:@"stockSearch%d.jpg", [event.coverPhotoID intValue]];
    UIImage *image = [UIImage imageNamed:imageName];
  
  [cell.eventNameLabel styleForType:LabelTypeTableViewCellTitle withText:eventName];
  [cell.countdownLabel styleForType:LabelTypeTableViewCellAttribute];
  [cell.userLabel styleForType:LabelTypeTableViewCellAttribute withText:user];
  
    if (!cell.imageView.image)
        [cell.eventImageView setImage:image];
    
    NSString *endDate;
    NSComparisonResult result = [event.endDate compare:[NSDate date]];
    switch (result){
        case NSOrderedAscending:
        case NSOrderedSame:
            cell.bannerView.backgroundColor = [UIColor afterpartyCoralRedColor];
            endDate = [NSString stringWithFormat:@"ended %@",[df stringFromDate:event.endDate]];
            break;
        case NSOrderedDescending:{
            cell.bannerView.backgroundColor = [UIColor afterpartyTealBlueColor];
            endDate = [NSString stringWithFormat:@"ends %@",[df stringFromDate:event.endDate]];
            break;
        }
    }
    cell.countdownLabel.text = endDate;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  APEvent *event = self.venues[indexPath.row];
  [self performSegueWithIdentifier:kNearbyEventDetailSegue sender:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:kNearbyEventDetailSegue]) {
    APSearchEventDetailViewController *vc = (APSearchEventDetailViewController*)segue.destinationViewController;
    [vc setCurrentEvent:sender];
    vc.delegate = self;
    vc.hidesBottomBarWhenPushed = YES;
  }
}

#pragma mark - SearchEventDetailsDelegate methods

- (void)controllerDidSelectEvent:(APSearchEventDetailViewController *)controller {
  [self.navigationController popToViewController:self animated:YES];
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
  NSLog(@"done popping!!");
}

@end
