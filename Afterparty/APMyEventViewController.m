//
//  AfterpartyMyEventViewController.m
//  Afterparty
//
//  Created by David Okun on 11/18/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import "APMyEventViewController.h"
#import "APConstants.h"

@import AssetsLibrary;
@import AVFoundation;

@interface APMyEventViewController () <UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CLLocationManagerDelegate, StackedGridLayoutDelegate, CaptureDelegate, UIAlertViewDelegate, UpdateLocationDelegate>

@property (strong, nonatomic) AVCaptureSession  *session;

@property (strong, nonatomic) NSString          *eventID;
@property (strong, nonatomic) NSString          *eventName;
@property (strong, nonatomic) NSDate            *deleteDate;
@property (strong, nonatomic) UIRefreshControl  *refreshControl;

@property (strong, nonatomic) NSArray           *photoMetadata;

@property (weak, nonatomic  ) NSTimer           *countdownTimer;
@property (weak, nonatomic  ) NSTimer           *switchTimer;
@property (weak, nonatomic  ) NSTimer           *checkTimer;

@property (strong, nonatomic) NSMutableArray    *thumbnailCacheArray;

@property (assign, nonatomic) BOOL              isSavingBulk;

@property (strong, nonatomic) CLLocation        *eventLocation;
@property (strong, nonatomic) CLLocation        *currentLocation;
@property (strong, nonatomic) CLLocationManager *manager;
@property (assign, nonatomic) BOOL              canTakePhoto;
@property (assign, nonatomic) BOOL              shouldAskAboutMove;

@property (strong, nonatomic) NSMutableArray    *selectedPhotos;

@property (strong, nonatomic) FXBlurView        *blurView;

@property dispatch_queue_t photoUploadQueue;
@property dispatch_queue_t photoDownloadQueue;

@end

@implementation APMyEventViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [SVProgressHUD showWithStatus:@"Downloading photo data..."];
  }
  return self;
}

- (void)getLatestMetadata {
  __block NSMutableArray *data = [@[] mutableCopy];
  [[APConnectionManager sharedManager] downloadImageMetadataForEventID:self.eventID success:^(NSArray *objects) {
    [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop) {
      APPhotoInfo *info = [[APPhotoInfo alloc] initWithParseObject:obj forEvent:self.eventID];
      [data addObject:info];
    }];
    [SVProgressHUD dismiss];
    self.photoMetadata = [NSArray arrayWithArray:data];
  } failure:^(NSError *error) {
    [SVProgressHUD showErrorWithStatus:@"could not get photos"];
  }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUI];
    [self setUpCountdown];
}

-(void)viewDidAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.manager stopUpdatingLocation];
    [SVProgressHUD dismiss];
}
#pragma mark -
#pragma mark - UI Methods

-(void)setUpCountdown {
    [self updateCountdown];
    if ([self.deleteDate timeIntervalSinceDate:[NSDate date]] >= (24 * 60 * 60))
        self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkForDeleteTime) userInfo:nil repeats:YES];
    else
        [self checkForDeleteTime];
    
    self.eventEndsLabel.alpha = 0.0f;
    self.countdownLabel.alpha = 0.0f;
}

-(void)setUpUI {
  
  NSDictionary *eventInfo = [[self.eventDict allValues] firstObject];
  self.eventID            = [[self.eventDict allKeys] firstObject];
  self.eventName          = eventInfo[@"eventName"];
  self.deleteDate         = eventInfo[@"deleteDate"];
  self.eventLocation = [[CLLocation alloc] initWithLatitude:[eventInfo[@"eventLatitude"] doubleValue] longitude:[eventInfo[@"eventLongitude"] doubleValue]];
  
  self.manager = [[CLLocationManager alloc] init];
  self.manager.delegate = self;
  self.manager.distanceFilter = kCLDistanceFilterNone;
  self.manager.desiredAccuracy = kCLLocationAccuracyBest;
  
  if ([[[PFUser currentUser] username] isEqualToString:eventInfo[@"createdByUsername"]]) {
    self.shouldAskAboutMove = YES;
  }
  
  self.thumbnailCacheArray = [[NSMutableArray alloc] init];
  self.selectedPhotos = nil;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedRefreshNotification) name:kQueueIsDoneUploading object:nil];
  
  self.photoDownloadQueue = dispatch_queue_create("com.afterparty.downloadQueue", NULL);
  self.view.backgroundColor = [UIColor afterpartyOffWhiteColor];
  self.view.backgroundColor = [UIColor afterpartyTealBlueColor];
  [self.collectionView registerNib:[UINib nibWithNibName:@"APPhotoCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"APPhotoCell"];

  self.layout = [[APStackedGridLayout alloc] init];
  [self.collectionView setCollectionViewLayout:self.layout];
  
  self.isSavingBulk = NO;
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  self.refreshControl.tintColor = [UIColor afterpartyTealBlueColor];
  [self.refreshControl addTarget:self action:@selector(refreshPhotos) forControlEvents:UIControlEventValueChanged];
  [self.collectionView addSubview:self.refreshControl];
  self.collectionView.alwaysBounceVertical = YES;
  self.collectionView.backgroundColor = [UIColor afterpartyOffWhiteColor];
  
  CGRect frame = self.collectionView.frame;
  frame.origin.y = frame.origin.y - 40;
  self.collectionView.frame = frame;
  
  [self.photoButton addTarget:self action:@selector(photoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  
  self.title = self.eventName;
  self.photoButton.enabled = YES;
  
  NSDateFormatter *df = [[NSDateFormatter alloc] init];
  [df setDateFormat:@"MM/dd/yy hh:mm:ss a"];
  NSString *formattedDate = [df stringFromDate:self.deleteDate];

  self.countdownLabel.text = formattedDate;
  [self.countdownLabel styleForType:LabelTypeStandard];

  self.eventEndsLabel.text = @"event ends in...";
  [self.eventEndsLabel styleForType:LabelTypeStandard];

  self.countdownLabel.backgroundColor = [UIColor afterpartyTealBlueColor];
  self.eventEndsLabel.backgroundColor = [UIColor afterpartyTealBlueColor];
  
  [self.manager startUpdatingLocation];
  
  UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped)];
  UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPhotos)];
  [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnSave, btnRefresh, nil]];

  dispatch_async(self.photoDownloadQueue, ^{
    [self getLatestMetadata];
    self.thumbnailCacheArray = [self.photoMetadata mutableCopy];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.collectionView reloadData];
    });
  });
}

-(void)saveButtonTapped {
    [UIAlertView showSimpleAlertWithTitle:@"Warning" andMessage:@"I don't have this feature working yet, but I will soon!"];
    self.isSavingBulk = YES;
    self.collectionView.allowsMultipleSelection = YES;
    [UIView transitionWithView:self.photoButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                           if (self.photoButton.alpha == 0.0f)
                               self.photoButton.alpha = 1.0f;
                           
                           [self.photoButton setImage:[UIImage imageNamed:@"button_savetocloud.png"] forState:UIControlStateNormal];
                           
                       } completion:^(BOOL finished) {
                           UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
                           [self.navigationItem setRightBarButtonItems:@[btnCancel]];
                       }];
}

-(void)cancelButtonTapped {
    self.isSavingBulk = NO;
    self.collectionView.allowsMultipleSelection = NO;
    [UIView transitionWithView:self.photoButton
                      duration:0.3
                       options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
                           if (self.countdownTimer != nil){
                               self.photoButton.alpha = 0.0f;
                               [self.photoButton setImage:nil forState:UIControlStateNormal];
                           }else{
                               [self.photoButton setImage:[UIImage imageNamed:@"button_camera.png"] forState:UIControlStateNormal];
                           }
                           
                       } completion:^(BOOL finished) {
                           UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTapped)];
                           UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPhotos)];
                           [self.navigationItem setRightBarButtonItems:@[btnSave, btnRefresh]];
                       }];
}


-(void)checkForDeleteTime {
    if ([self.deleteDate timeIntervalSinceDate:[NSDate date]] >= (24 * 60 * 60)) {
        return;
    }
    [self.checkTimer invalidate];
    self.checkTimer = nil;
    self.photoButton.enabled = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.photoButton.alpha = 0.0f;
                         self.countdownLabel.alpha = 1.0f;
                     }];
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
    self.switchTimer = [NSTimer scheduledTimerWithTimeInterval:2.7 target:self selector:@selector(switchLabels) userInfo:nil repeats:YES];
}

-(void)switchLabels {
    if (self.eventEndsLabel.alpha == 1.0f) {
        [UIView animateWithDuration:0.7
                         animations:^{
                             self.eventEndsLabel.alpha = 0.0f;
                             self.countdownLabel.alpha = 1.0f;
                         }];
    }else{
        [UIView animateWithDuration:0.7
                         animations:^{
                             self.eventEndsLabel.alpha = 1.0f;
                             self.countdownLabel.alpha = 0.0f;
                         }];
    }
    
}

-(void) updateCountdown {
    NSTimeInterval timeToClosing = [self.deleteDate timeIntervalSinceDate:[NSDate date]];
    
    div_t h = div(timeToClosing, 3600);
    int hours = h.quot;
    div_t m = div(h.rem, 60);
    int minutes = m.quot;
    int seconds = m.rem;
    
    NSString *hoursStr, *minutesStr, *secondsStr;
    if (hours < 10)
        hoursStr = [NSString stringWithFormat:@"0%d", hours];
    else
        hoursStr = [NSString stringWithFormat:@"%d", hours];
    if (minutes < 10)
        minutesStr = [NSString stringWithFormat:@"0%d", minutes];
    else
        minutesStr = [NSString stringWithFormat:@"%d", minutes];
    if (seconds < 10)
        secondsStr = [NSString stringWithFormat:@"0%d", seconds];
    else
        secondsStr = [NSString stringWithFormat:@"%d", seconds];
    
    if (seconds < 0)
        [self dismissButtonTapped];
    else
        self.countdownLabel.text = [NSString stringWithFormat:@"%@:%@:%@", hoursStr, minutesStr, secondsStr];
    if (timeToClosing <= 30) {
        [self.switchTimer invalidate];
        self.switchTimer = nil;
        [UIView animateWithDuration:0.7
                         animations:^{
                             self.eventEndsLabel.alpha = 0.0f;
                             self.countdownLabel.alpha = 1.0f;
                         }];
    }
}

-(void)dismissButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView title] isEqualToString:@"Keep the party going?"]) {
        if (buttonIndex == 1) {
            NSLog(@"lets update the location");
            APMyEventUpdateLocationViewController *vc = [[APMyEventUpdateLocationViewController alloc] initWithCurrentLocation:self.currentLocation forEventID:self.eventID];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - UpdateLocationDelegate methods

-(void)venueSuccessfullyUpdated:(FSVenue *)newVenue {
    self.eventLocation = [[CLLocation alloc] initWithLatitude:newVenue.location.coordinate.latitude
                                                        longitude:newVenue.location.coordinate.longitude];
    [APUtil updateEventVenue:newVenue forEventID:self.eventID];
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - LocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations lastObject];
    self.currentLocation = currentLocation;
    CLLocationDistance meters = [self.eventLocation distanceFromLocation:currentLocation];
    self.canTakePhoto = (meters < 1620);
    if (!self.canTakePhoto && self.shouldAskAboutMove) {
        self.shouldAskAboutMove = NO;
        [[[UIAlertView alloc] initWithTitle:@"Keep the party going?" message:@"It looks like you moved since creating the party - do you want to update the location?" delegate:self cancelButtonTitle:@"Nah" otherButtonTitles:@"OK!", nil] show];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"manager failed: %@", [error localizedDescription]);
}


#pragma mark -
#pragma mark - Action methods for my event

- (void)refreshPhotos {
  [self.thumbnailCacheArray removeAllObjects];
  self.blurView = [[FXBlurView alloc] initWithFrame:self.view.frame];
  [self.blurView setAlpha:0.0f];
  [self.blurView setBlurEnabled:YES];
  [self.blurView setBlurRadius:20];
  [SVProgressHUD showWithStatus:@"Refreshing event photos"];
  [self.view insertSubview:self.blurView aboveSubview:self.collectionView];
  [UIView animateWithDuration:0.5 animations:^{
      [self.blurView setAlpha:1.0f];
  }];
  dispatch_async(self.photoDownloadQueue, ^{
    [self getLatestMetadata];
    dispatch_async(dispatch_get_main_queue(), ^{
      [SVProgressHUD dismiss];
      self.photoButton.enabled = YES;
      self.thumbnailCacheArray = [self.photoMetadata mutableCopy];
      [self.collectionView reloadData];
      [self.refreshControl endRefreshing];
      [UIView animateWithDuration:0.5
                            delay:0.3
                          options:UIViewAnimationOptionCurveLinear
                       animations:^{
                         [self.blurView setAlpha:0.0f];
                       } completion:^(BOOL finished) {
                         self.blurView = nil;
                       }];
    });
  });
}

- (void)photoButtonTapped {
    if (self.isSavingBulk) {
        NSLog(@"need to add method for saving all selected photos");
        [self cancelButtonTapped];
        [SVProgressHUD showSuccessWithStatus:@"Photos saved"];
    }else{
        if (self.canTakePhoto) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
                APCameraOverlayViewController *vc = [[APCameraOverlayViewController alloc] init];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:NO];
            }else{
                // Device has no camera
                NSUInteger randNum = arc4random_uniform(5) + 1;
                NSString *imageName = [NSString stringWithFormat:@"stock%lu.jpeg", (unsigned long)randNum];
                UIImage *image = [UIImage imageNamed:imageName];

                UIImage *thumbnailImage = [image resizedImageWithSize:[self sizePhotoForColumn:image.size]];
                [self uploadImage:image withThumbnail:thumbnailImage];
            }
        }else
            [UIAlertView showSimpleAlertWithTitle:@"Too Far Away" andMessage:@"You must be within a mile of the party center to contribute, ya big jerk."];
    }
}

#pragma mark - CaptureDelegate Methods

-(void)capturedImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    UIImage *thumbnailImage = [image resizedImageWithSize:[self sizePhotoForColumn:image.size]];
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self uploadImage:image withThumbnail:thumbnailImage];
    
}

-(void)uploadImage:(UIImage*)image withThumbnail:(UIImage*)thumbnailImage {
  [SVProgressHUD show];
  [[APPhotoUploadQueue sharedQueue] addPhotoToQueue:image withThumbnail:thumbnailImage forEventID:self.eventID];
}

-(void)receivedRefreshNotification {
  [self refreshPhotos];
}

#pragma mark - 
#pragma mark - Collection View methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self.photoMetadata count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellIdentifier = @"APPhotoCell";
  APPhotoCell *cell = (APPhotoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
  
  [cell.downloadIndicator startAnimating];
  cell.downloadIndicator.center = cell.center;
  cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
  
  [cell setPhotoInfo:self.photoMetadata[indexPath.item]];
  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSavingBulk) {
        APPhotoCell *cell = (APPhotoCell*)[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
        [cell setNeedsDisplay];
        cell.imageView.alpha = 0.5;
        UIView *overlay = [[UIView alloc] initWithFrame:cell.contentView.frame];
        overlay.backgroundColor = [UIColor whiteColor];
        overlay.alpha = 0.3;
        [cell.contentView addSubview:overlay];
        [cell.contentView bringSubviewToFront:overlay];
    }else{
        APPhotoViewController *vc = [[APPhotoViewController alloc] initWithMetadata:self.photoMetadata andSelectedIndex:indexPath.item];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - StackedGridLayoutDelegate Methods 

-(NSInteger)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout *)cvl numberOfColumnsInSection:(NSInteger)section {
    return 2;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout *)cvl itemInsetsForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(CGSize)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout *)cvl sizeForItemWithWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath {
    id obj = self.photoMetadata[indexPath.item];
    if ([obj isKindOfClass:[APPhotoInfo class]]) {
        APPhotoInfo *photoInfo = (APPhotoInfo*)obj;
        return [self sizePhotoForColumn:[photoInfo size]];
    }else{
        UIImage *image = (UIImage*)obj;
        return [self sizePhotoForColumn:[image size]];
    }
}

-(CGSize)sizePhotoForColumn:(CGSize)photoSize {
    CGFloat width = 160;
        
    CGSize newSize = CGSizeMake(width, 0);
    if (photoSize.width > width) {
        CGFloat divisor = photoSize.width / width;
        newSize.height = photoSize.height/ divisor;
    }else{
        CGFloat factor = width / photoSize.width;
        newSize.height = photoSize.height * factor;
    }
    
    return newSize;
}

@end
