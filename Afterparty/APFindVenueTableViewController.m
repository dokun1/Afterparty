//
//  APCreateEventChooseVenueTableViewController.m
//  Afterparty
//
//  Created by David Okun on 5/13/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APFindVenueTableViewController.h"
#import "APConnectionManager.h"
#import "APVenueTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIColor+APColor.h"


@interface APFindVenueTableViewController () <UISearchBarDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDictionary *info;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) CLLocation *currentLocation;

@end

@implementation APFindVenueTableViewController

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

    [self setTitle:@"SET VENUE"];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [self.searchBar sizeToFit];
    [self.searchBar setDelegate:self];
    [self.searchBar setPlaceholder:@"search venues"];
    [self.searchBar setTintColor:[UIColor afterpartyTealBlueColor]];
    
    [self.tableView setTableHeaderView:self.searchBar];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:kRegularFont size:6]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:[UIColor afterpartyTealBlueColor]];
    [self.refreshControl addTarget:self action:@selector(refreshVenues) forControlEvents:UIControlEventValueChanged];
    
    self.currentLocation = nil;
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    [self.tableView setBackgroundColor:[UIColor colorWithHexString:@"e5e5e5" withAlpha:1.0]];
    
    [self refreshVenues];
    
    UIBarButtonItem *btnDismiss = [[UIBarButtonItem alloc] initWithTitle:@"DISMISS" style:UIBarButtonItemStylePlain target:self action:@selector(dismissScreen)];
    [self.navigationItem setRightBarButtonItems:@[btnDismiss]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APVenueTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"APVenueCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (self.currentLocation == nil) {
        self.currentLocation = [locations lastObject];
        [self.locationManager stopUpdatingLocation];
        [self getVenues];
    }
    self.currentLocation = [locations lastObject];
}

#pragma mark - UISearchBarDelegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.currentLocation == nil) {
        [self searchBarSearchButtonClicked:searchBar];
        return;
    }
    [searchBar resignFirstResponder];
    [SVProgressHUD showWithStatus:@"searching"];
    [[APConnectionManager sharedManager] searchVenuesByName:searchBar.text atLocation:self.currentLocation success:^(NSArray *objects) {
        [SVProgressHUD dismiss];
        self.venues = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"no results for %@", searchBar.text]];
    }];
}

#pragma mark - UI Methods

-(void)dismissScreen {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GetVenues Methods

-(void)refreshVenues {
    [self.locationManager startUpdatingLocation];
}

-(void)getVenues {
    [SVProgressHUD showWithStatus:@"finding nearby foursquare venues"];
    [[APConnectionManager sharedManager] getNearbyVenuesForLocation:self.currentLocation success:^(NSArray *objects) {
        [SVProgressHUD dismiss];
        self.venues = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"could not find any venues"];
    }];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - TableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"APVenueCell";
    APVenueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    FSVenue *venue = self.venues[indexPath.row];
    
    [cell.venueName setText:venue.name];
    [cell.venueAddress setText:venue.location.address];
    NSString *venueDistance = ([venue.location.distance floatValue] < 528) ? [NSString stringWithFormat:@"%@ft", venue.location.distance] : [NSString stringWithFormat:@"%.1fmi", [venue.location.distance floatValue]/5280];
    [cell.venueDistance setText:venueDistance];
    [cell.venueName setFont:[UIFont fontWithName:kRegularFont size:17.0f]];
    [cell.venueAddress setFont:[UIFont fontWithName:kRegularFont size:14.0f]];
    [cell.venueDistance setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FSVenue *venue = self.venues[indexPath.row];
  [self.delegate controller:self didChooseVenue:venue];
  
}

@end