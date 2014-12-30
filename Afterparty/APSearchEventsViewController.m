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
#import <MapKit/MapKit.h>
#import "APEventAnnotation.h"

@import AddressBook;

@interface APSearchEventsViewController () <UISearchBarDelegate, CLLocationManagerDelegate, SearchEventDetailDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>

@property (strong, nonatomic) NSMutableArray *venues;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (assign, nonatomic) BOOL isRefresh;
@property (assign, nonatomic) BOOL isForSearch;
@property (strong, nonatomic) NSString *initialSearch;
@property (assign, nonatomic) BOOL isLoading;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *venueAnnotations;

@end

@implementation APSearchEventsViewController

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
    
    self.mapView.delegate = self;
    
    (self.isForSearch) ? [self searchForEventByID] : [self refreshEvents];
  
    [self.tableView registerNib:[UINib nibWithNibName:@"APSearchEventTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MyEventCell"];
  
    UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshEvents)];
    [self.navigationItem setRightBarButtonItems:@[btnRefresh]];
    self.venueAnnotations = [NSMutableArray array];
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
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        if ([PFUser currentUser] && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.initialSearch = nil;
    [SVProgressHUD dismiss];
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

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
        [self loadEventsToMap];
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

#pragma mark - MKMapViewDelegate Methods

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    if ([annotation isKindOfClass:[APEventAnnotation class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            annotationView.pinColor = MKPinAnnotationColorGreen;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = YES;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    APEventAnnotation *annotation = (APEventAnnotation *)view.annotation;
    APEvent *selectedEvent = annotation.event;
    [self performSegueWithIdentifier:kNearbyEventDetailSegue sender:selectedEvent];
}

- (void)loadEventsToMap {
    CLLocationDegrees minx = NAN;
    CLLocationDegrees miny = NAN;
    CLLocationDegrees maxx = NAN;
    CLLocationDegrees maxy = NAN;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    for(APEvent *event in self.venues) {
        if (![[event.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            continue;
        }
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(NAN, NAN);
        location = event.location;
        if (!isnan(location.latitude) && !isnan(location.longitude)) {
            APEventAnnotation *annotation = [[APEventAnnotation alloc] initWithEvent:event];
            [self.venueAnnotations addObject:annotation];
            if(isnan(minx))
                minx = location.longitude;
            else
                minx = MIN(minx, location.longitude);
            if(isnan(maxx))
                maxx = location.longitude;
            else
                maxx = MAX(maxx, location.longitude);
            if(isnan(miny))
                miny = location.latitude;
            else
                miny = MIN(miny, location.latitude);
            if(isnan(maxy))
                maxy = location.latitude;
            else
                maxy = MAX(maxy, location.latitude);
        }
    }
    CLLocationCoordinate2D currentLocation = self.currentLocation.coordinate;
    
    if(isnan(minx))
        minx = currentLocation.longitude;
    else
        minx = MIN(minx, currentLocation.longitude);
    if(isnan(maxx))
        maxx = currentLocation.longitude;
    else
        maxx = MAX(maxx, currentLocation.longitude);
    if(isnan(miny))
        miny = currentLocation.latitude;
    else
        miny = MIN(miny, currentLocation.latitude);
    if(isnan(maxy))
        maxy = currentLocation.latitude;
    else
        maxy = MAX(maxy, currentLocation.latitude);
    
    if (self.venueAnnotations != nil) {
        [self.mapView addAnnotations:self.venueAnnotations];
    }
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = (maxx - minx) + 0.002;
    span.longitudeDelta = (maxy - miny) + 0.002;
    
    region.span = span;
    region.center = CLLocationCoordinate2DMake((maxy + miny)/2, (maxx + minx)/2);

    if (self.venues.count > 0 && !isnan(region.center.latitude) && !isnan(region.center.longitude)) {
        [self.mapView setCenterCoordinate:region.center animated:NO];
        [self.mapView setRegion:region animated:NO];
        [self.mapView regionThatFits:region];
    }
}

- (void)alterMap {
    self.mapView.showsUserLocation = YES;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.05;
    span.longitudeDelta = 0.05;
    
    region.span = span;
    region.center = self.currentLocation.coordinate;
    
    [self.mapView setCenterCoordinate:region.center animated:NO];
    [self.mapView setRegion:region animated:NO];
    [self.mapView regionThatFits:region];
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            PFFile *imageFile = (PFFile*)[searchedEvent eventImage];
            NSData *imageData = [imageFile getData];
            [searchedEvent setEventImageData:imageData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [APUtil saveEventToMyEvents:searchedEvent];
                [self.tableView reloadData];
            });
        });

    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"couldn't find event"];
    }];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange lowercaseCharRange = [text rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    
    if (lowercaseCharRange.location != NSNotFound) {
        searchBar.text = [searchBar.text stringByReplacingCharactersInRange:range withString:[text uppercaseString]];
        return NO;
    }
    return YES;
}

-(void)refreshEvents {
  if ([PFUser currentUser] && !self.initialSearch) {
      [self.mapView removeAnnotations:self.venueAnnotations];
      [self.venueAnnotations removeAllObjects];
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
  return [APSearchEventTableViewCell suggestedCellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [APSearchEventTableViewCell suggestedCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyEventCell";
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
    [SVProgressHUD showWithStatus:@"loading event"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        APEvent *event = self.venues[indexPath.row];
        [self performSegueWithIdentifier:kNearbyEventDetailSegue sender:event];
    });

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
}

@end
