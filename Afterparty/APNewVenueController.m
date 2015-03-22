//
//  APNewVenueController.m
//  Afterparty
//
//  Created by David Okun on 3/14/15.
//  Copyright (c) 2015 Afterparty. All rights reserved.
//

#import "APNewVenueController.h"
#import <Parse/Parse.h>
#import "APButton.h"
#import "APConnectionManager.h"

@import MapKit;

@interface APNewVenueController () <CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIImageView *locationPin;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) APButton *locationSetButton;
@property (strong, nonatomic) UITapGestureRecognizer *locationTapGestureRecognizer;
@property (nonatomic) CLLocationCoordinate2D venuePoint;

@end

@implementation APNewVenueController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    self.locationPin = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 30, self.view.center.y - 60, 60, 60)];
    self.locationPin.contentMode = UIViewContentModeScaleAspectFit;
    self.locationPin.image = [UIImage imageNamed:@"locationIcon"];
    [self.view addSubview:self.locationPin];
    
    self.locationTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(locationSetButtonTapped)];
    self.locationTapGestureRecognizer.numberOfTapsRequired = 1;
    self.locationTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.locationPin addGestureRecognizer:self.locationTapGestureRecognizer];
    
    self.locationSetButton = [[APButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.view.frame) - 60, CGRectGetWidth(self.view.frame) - 20, 50)];
    [self.locationSetButton style];
    [self.locationSetButton setTitle:@"SET LOCATION" forState:UIControlStateNormal];
    [self.locationSetButton addTarget:self action:@selector(locationSetButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.locationSetButton];
    
    [self createLocationManager];
}

- (void)createLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    
    [self.locationManager startUpdatingLocation];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        if ([PFUser currentUser] && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)locationSetButtonTapped {
    self.venuePoint = [self.mapView convertPoint:self.view.center toCoordinateFromView:self.view];
    UIAlertView *nameView = [[UIAlertView alloc] initWithTitle:@"Enter Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    nameView.alertViewStyle = UIAlertViewStylePlainTextInput;
    nameView.tag = 100;
    [nameView show];
}

#pragma mark - NewVenueDelegate Methods

- (void)attemptVenueCreationWithName:(NSString *)venueName {
    APVenue *potentialNewVenue = [[APVenue alloc] init];
    potentialNewVenue.name = venueName;
    potentialNewVenue.location.coordinate = self.venuePoint;
    [[APConnectionManager sharedManager] addVenueToLocationSearch:potentialNewVenue success:^{
        if ([self.delegate respondsToSelector:@selector(controller:didCreateNewVenue:)]) {
            [self.delegate controller:self didCreateNewVenue:potentialNewVenue];
        }
    } failure:^(NSError *error) {
        NSLog(@"some kind of error");
    }];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        if (buttonIndex == 1) {
            if (![[[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
                [self attemptVenueCreationWithName:[alertView textFieldAtIndex:0].text];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a name for your location!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = locations.lastObject;
    [self.locationManager stopUpdatingLocation];
    
    MKCoordinateSpan span;
    span.latitudeDelta = 0.001;
    span.longitudeDelta = 0.001;

    MKCoordinateRegion region;
    region.span = span;
    region.center = self.currentLocation.coordinate;
    
    [self.mapView setCenterCoordinate:region.center animated:YES];
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
}

@end
