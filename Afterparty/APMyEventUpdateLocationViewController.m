//
//  APMyEventUpdateLocationViewController.m
//  Afterparty
//
//  Created by David Okun on 4/20/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APMyEventUpdateLocationViewController.h"
#import "APConnectionManager.h"
#import "APVenueTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIColor+APColor.h"
#import "UIAlertView+APAlert.h"
#import "APConstants.h"
#import <UIKit+AFNetworking.h>

@interface APMyEventUpdateLocationViewController () <UISearchBarDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) NSDictionary *info;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (weak, nonatomic) APVenue *selectedVenue;
@property (strong, nonatomic) NSString *eventID;

@end

@implementation APMyEventUpdateLocationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCurrentLocation:(CLLocation *)currentLocation forEventID:(NSString*)eventID {
    if (self = [super init]) {
        self.currentLocation = currentLocation;
        self.eventID = eventID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Set Venue";
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [self.searchBar sizeToFit];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"search venues";
    self.searchBar.tintColor = [UIColor afterpartyTealBlueColor];
    self.tableView.tableHeaderView = self.searchBar;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:kRegularFont size:6]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor afterpartyTealBlueColor];
    [self.refreshControl addTarget:self action:@selector(refreshVenues) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView setBackgroundColor:[UIColor afterpartyOffWhiteColor]];
    
    [self refreshVenues];
    
    UIBarButtonItem *btnChoose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(selectNewVenue:)];
    [self.navigationItem setRightBarButtonItems:@[btnChoose]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APVenueTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"APVenueCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)selectNewVenue:(APVenue*)newVenue {
    self.selectedVenue = newVenue;
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:newVenue.name
                                message:@"Are you sure you want to move this party here?"
                               delegate:self
                      cancelButtonTitle:@"Nah"
                      otherButtonTitles:@"Yes", nil];
    view.tag = 100;
    [view show];
}

#pragma mark - UIAlertViewDelegate method

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView tag] == 100 && buttonIndex == 1) {
        [SVProgressHUD showWithStatus:@"Updating venue"];
        [[APConnectionManager sharedManager] updateEventForEventID:self.eventID withNewVenue:self.selectedVenue success:^(BOOL succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"Venue updated!"];
            [self.delegate venueSuccessfullyUpdated:self.selectedVenue];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Couldn't update venue - try again"];
        }];
    }
}

-(void)refreshVenues {
    [self getVenues];
}

-(void)getVenues {
    [[APConnectionManager sharedManager] getNearbyVenuesForLocation:self.currentLocation success:^(NSArray *objects) {
        self.venues = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSError *error) {
        [UIAlertView showSimpleAlertWithTitle:@"Error" andMessage:@"Couldn't find foursquare locations in your area. Please go back and try again"];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate Methods

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.currentLocation == nil) {
        [self searchBarSearchButtonClicked:searchBar];
        return;
    }
    [searchBar resignFirstResponder];
    [[APConnectionManager sharedManager] searchVenuesByName:searchBar.text atLocation:self.currentLocation success:^(NSArray *objects) {
        self.venues = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSError *error) {
        [UIAlertView showSimpleAlertWithTitle:@"Error" andMessage:@"We couldn't process your search request. Please try again."];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"APVenueCell";
    APVenueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    APVenue *venue = self.venues[indexPath.row];
    
    [cell.venueName setText:venue.name];
    [cell.venueAddress setText:venue.prettyAddress];

    [cell.venueName setFont:[UIFont fontWithName:kRegularFont size:17.0f]];
    [cell.venueAddress setFont:[UIFont fontWithName:kRegularFont size:14.0f]];
    
    [cell.venueIcon setImageWithURL:[NSURL URLWithString:venue.iconURL]];
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    APVenue *venue = self.venues[indexPath.row];
    [self selectNewVenue:venue];
}

@end
