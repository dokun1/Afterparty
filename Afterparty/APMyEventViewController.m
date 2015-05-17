//
//  AfterpartyMyEventViewController.m
//  Afterparty
//
//  Created by David Okun on 11/18/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import "APMyEventViewController.h"
#import "APConstants.h"
#import <pop/POP.h>
#import "APCollectionViewGalleryFlowLayout.h"
#import "APCreateEventViewController.h"

@import AssetsLibrary;
@import AVFoundation;
@import MessageUI;

@interface APMyEventViewController () <UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CLLocationManagerDelegate, StackedGridLayoutDelegate, CaptureDelegate, UIAlertViewDelegate, VenueChoiceDelegate, MFMessageComposeViewControllerDelegate, CreateEventDelegate>

@property (strong, nonatomic) AVCaptureSession  *session;

@property (strong, nonatomic) NSString          *eventID;
@property (strong, nonatomic) NSString          *eventName;
@property (strong, nonatomic) NSDate            *deleteDate;
@property (strong, nonatomic) NSString          *password;
@property (strong, nonatomic) UIRefreshControl  *refreshControl;
@property (copy, nonatomic) NSString            *eventCreatedUsername;
@property (copy, nonatomic) NSData              *eventCoverImageData;

@property (strong, nonatomic) APEvent           *currentEvent;

@property (strong, nonatomic) NSArray           *photoMetadata;

@property (weak, nonatomic  ) NSTimer           *countdownTimer;
@property (weak, nonatomic  ) NSTimer           *switchTimer;
@property (weak, nonatomic  ) NSTimer           *checkTimer;

@property (assign, nonatomic) BOOL              isSavingBulk;

@property (strong, nonatomic) CLLocation        *eventLocation;
@property (strong, nonatomic) CLLocation        *currentLocation;
@property (strong, nonatomic) CLLocationManager *manager;
@property (assign, nonatomic) BOOL              canTakePhoto;
@property (assign, nonatomic) BOOL              shouldAskAboutMove;

@property (strong, nonatomic) NSMutableArray    *selectedPhotos;

@property (strong, nonatomic) UICollectionViewFlowLayout *photoViewLayout;

@property (strong, nonatomic) NSString *longPressPhotoID;

@property dispatch_queue_t photoUploadQueue;
@property dispatch_queue_t photoDownloadQueue;

@end

@implementation APMyEventViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    //init logic
      _photoMetadata = [NSArray array];
  }
  return self;
}

- (void)getLatestMetadata {
  __block NSMutableArray *data = [@[] mutableCopy];
  [[APConnectionManager sharedManager] downloadImageMetadataForEventID:self.eventID success:^(NSArray *objects) {
    [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop) {
      APPhotoInfo *info = [[APPhotoInfo alloc] initWithParseObject:obj forEvent:self.eventID];
        if ([info.reports intValue] < 3) {
            [data addObject:info];
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.photoMetadata) {
            self.photoMetadata = [NSArray array];
        }
        self.photoMetadata = data;
        [self.collectionView reloadData];
    });
  } failure:^(NSError *error) {
      dispatch_async(dispatch_get_main_queue(), ^{
          [SVProgressHUD showErrorWithStatus:@"could not get photos"];
      });
  }];
    if (self.eventID) {
        [self setCurrentEvent];
    }
}

- (void)setCurrentEvent {
    __weak APMyEventViewController *weakself = self;
    [[APConnectionManager sharedManager] getEventForId:self.eventID success:^(APEvent *event) {
        self.currentEvent = event;
        self.currentEvent.eventImageData = self.eventCoverImageData;
        [self setBarButtons];
    } failure:^(NSError *error) {
        if (error) { //error will be nil if there is no object to retrieve, so dont try again if there's just no object, but that would be weird anyway
            [weakself setCurrentEvent];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self setUpCountdown];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLongPressNotification:) name:@"photoLongPressedNotification" object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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
    self.password           = eventInfo[@"eventPassword"];
    self.eventCreatedUsername = eventInfo[@"createdByUsername"];
    self.eventCoverImageData = eventInfo[@"eventImageData"];
    self.eventLocation = [[CLLocation alloc] initWithLatitude:[eventInfo[@"eventLatitude"] doubleValue] longitude:[eventInfo[@"eventLongitude"] doubleValue]];

    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    self.manager.distanceFilter = kCLDistanceFilterNone;
    self.manager.desiredAccuracy = kCLLocationAccuracyBest;
  
    if ([[[PFUser currentUser] username] isEqualToString:self.eventCreatedUsername]) {
        self.shouldAskAboutMove = YES;
    }

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
    self.countdownLabel.textColor = [UIColor whiteColor];
    self.eventEndsLabel.textColor = [UIColor whiteColor];
  
    [self.manager startUpdatingLocation];
  
    [self setBarButtons];
  
    self.photoMetadata = [[NSArray alloc] init];
  
    [self refreshPhotos];
}

- (void)setBarButtons {
    UIBarButtonItem *btnSelect = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped)];
    UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPhotos)];
    if ([[[PFUser currentUser] username] isEqualToString:self.eventCreatedUsername] && self.currentEvent) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(editButtonTapped)];
        [self.navigationItem setRightBarButtonItems:@[btnSelect, btnRefresh, editButton]];
    } else {
        [self.navigationItem setRightBarButtonItems:@[btnSelect, btnRefresh]];
    }
}

#pragma mark - EditEventActions

- (void)editButtonTapped {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Event", @"Share Event", nil];
    actionSheet.tag = 6969;
    [actionSheet showInView:self.view.window];
}

- (void)shareEventSelected {
    NSString *message = [NSString stringWithFormat:@"Psst...there's a party going on here: http://www.deeplink.me/afterparty.io/event.html?eventID=%@", self.eventID];
    if (![[self.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSString *addOn = [NSString stringWithFormat:@" and the password is %@", self.password];
        message = [NSString stringWithFormat:@"%@%@", message, addOn];
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    switch (result) {
        case MessageComposeResultCancelled:
            [SVProgressHUD dismiss];
            break;
        case MessageComposeResultFailed:
            [SVProgressHUD showErrorWithStatus:@"invitations failed"];
            break;
        case MessageComposeResultSent:
            [SVProgressHUD showSuccessWithStatus:@"invitations sent"];
            break;
        default:
            break;
    }
}

- (void)editEventSelected {
    NSLog(@"event edit selected");
    [self performSegueWithIdentifier:kEditMyEventSegue sender:self.currentEvent];
}

#pragma mark - CreateEventDelegate methods

- (void)controllerDidFinishEditing:(APCreateEventViewController *)controller withEventID:(NSString *)eventID {
    //do i need this here? let's experiment.
}


-(void)saveButtonTapped {
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
                           UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(photoButtonTapped)];
                           [self.navigationItem setRightBarButtonItems:@[btnSave, btnCancel]];
                       }];
}

-(void)cancelButtonTapped {
    self.isSavingBulk = NO;
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
                           [self deselectAllCells];
                           self.collectionView.allowsMultipleSelection = NO;
                           UIBarButtonItem *btnSelect = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped)];
                           UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPhotos)];
                           [self.navigationItem setRightBarButtonItems:@[btnSelect, btnRefresh]];
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
    if (hours < 10) {
        hoursStr = [NSString stringWithFormat:@"0%d", hours];
    } else {
        hoursStr = [NSString stringWithFormat:@"%d", hours];
    }
    if (minutes < 10) {
        minutesStr = [NSString stringWithFormat:@"0%d", minutes];
    } else {
        minutesStr = [NSString stringWithFormat:@"%d", minutes];
    }
    if (seconds < 10) {
        secondsStr = [NSString stringWithFormat:@"0%d", seconds];
    } else {
        secondsStr = [NSString stringWithFormat:@"%d", seconds];
    }
    
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
            APFindVenueTableViewController *vc = [[APFindVenueTableViewController alloc] init];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - UpdateLocationDelegate methods

- (void)controller:(APFindVenueTableViewController *)controller didChooseVenue:(APVenue *)venue {
    self.eventLocation = [[CLLocation alloc] initWithLatitude:venue.location.coordinate.latitude
                                                    longitude:venue.location.coordinate.longitude];
    [APUtil updateEventVenue:venue forEventID:self.eventID];
    [[APConnectionManager sharedManager] updateEventAfterEdit:self.currentEvent success:^() {} failure:^(NSError *error) {
        NSLog(@"Some kind of error sending an update");
    }];
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - LocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations lastObject];
    self.currentLocation = currentLocation;
    CLLocationDistance meters = [self.eventLocation distanceFromLocation:currentLocation];
    self.canTakePhoto = (meters < 850);
    if (!self.canTakePhoto && self.shouldAskAboutMove) {
        self.shouldAskAboutMove = NO;
        [[[UIAlertView alloc] initWithTitle:@"Keep the party going?" message:@"It looks like you moved since creating the party - do you want to update the location?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

#pragma mark - Long Press Methods

- (void)receivedLongPressNotification:(NSNotification *)notification {
    NSString *photoID = notification.userInfo[@"photoID"];
    self.longPressPhotoID = photoID;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Go Back" destructiveButtonTitle:@"Report" otherButtonTitles:@"Save", nil];
    sheet.tag = 9000;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 6969) {
        switch (buttonIndex) {
            case 0:
                [self editEventSelected];
                break;
            case 1:
                [self shareEventSelected];
                break;
            case 2:
            default:
                break;
        }
    }
    if (actionSheet.tag == 9000) {
        if (buttonIndex == 0) {
            NSArray *reportedPhotos = [APUtil getReportedPhotoIDs];
            if (![reportedPhotos containsObject:self.longPressPhotoID]) {
                [APUtil saveReportedPhotoID:self.longPressPhotoID];
                [SVProgressHUD showWithStatus:@"reporting..."];
                [[APConnectionManager sharedManager] reportImageForImageRefID:self.longPressPhotoID success:^(BOOL succeeded) {
                    if (succeeded) {
                        [self getLatestMetadata];
                        [[[UIAlertView alloc] initWithTitle:nil message:@"The photo you reported has been deleted from our servers. We apologize for the inconvenience." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    } else {
                        [SVProgressHUD showSuccessWithStatus:@"photo reported"];
                    }
                } failure:^(NSError *error) {
                    [SVProgressHUD showErrorWithStatus:@"please try again"];
                }];
            } else {
                [SVProgressHUD showErrorWithStatus:@"already reported"];
            }
        }
        if (buttonIndex == 1) {
            [SVProgressHUD showWithStatus:@"saving..."];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self.photoMetadata enumerateObjectsUsingBlock:^(APPhotoInfo *photoInfo, NSUInteger idx, BOOL *stop) {
                    if ([photoInfo.refID isEqualToString:self.longPressPhotoID]) {
                        NSData *imgData = [NSData dataWithContentsOfURL:photoInfo.photoURL];
                        UIImage *img = [UIImage imageWithData:imgData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [APUtil saveImageToCameraRoll:img];
                            [SVProgressHUD showSuccessWithStatus:@"photo saved!"];
                        });
                        *stop = YES;
                    }
                }];
            });
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"reset%@", self.longPressPhotoID] object:nil];
    self.longPressPhotoID = nil;
}

#pragma mark -
#pragma mark - Action methods for my event

- (void)refreshPhotos {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(self.photoDownloadQueue, ^{
        [self getLatestMetadata];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            self.photoButton.enabled = YES;
            [self.refreshControl endRefreshing];
        });
    });
}

- (void)photoButtonTapped {
    if (self.isSavingBulk) {
      if (self.selectedPhotos && self.selectedPhotos.count > 0) {
        [self saveBulkPhotos];
        [SVProgressHUD showWithStatus:@"saving photos..."];
      }
        [self cancelButtonTapped];

    }else{
        if (self.canTakePhoto) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
                APCameraOverlayViewController *vc = [[APCameraOverlayViewController alloc] init];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:NO];
            }else{
                // Device has no camera
                NSUInteger randNum = arc4random_uniform(7) + 1;
                NSString *imageName = [NSString stringWithFormat:@"stock%lu.png", (unsigned long)randNum];
                UIImage *image = [UIImage imageNamed:imageName];

                [self uploadImage:image];
            }
        }else
            [UIAlertView showSimpleAlertWithTitle:@"Too Far Away" andMessage:@"You must be within a half mile of the party center to contribute. Try moving closer!"];
    }
}

- (void)saveBulkPhotos {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    for (NSIndexPath *indexPath in self.selectedPhotos) {
      APPhotoInfo *photoInfo = self.photoMetadata[indexPath.item];
      NSData *imgData = [NSData dataWithContentsOfURL:photoInfo.photoURL];
      UIImage *img = [UIImage imageWithData:imgData];
      dispatch_async(dispatch_get_main_queue(), ^{
          [APUtil saveImageToCameraRoll:img];
      });
    }
    [self.selectedPhotos removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
      [SVProgressHUD showSuccessWithStatus:@"photos saved!"];
        [self deselectAllCells];
    });
  });
}

- (void)deselectAllCells {
    for (int i = 0; i < self.photoMetadata.count; i++) {
        APPhotoCell *cell = (APPhotoCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [cell setSelected:NO];
    }
}

#pragma mark - CaptureDelegate Methods

-(void)capturedImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [self uploadImage:image];
}

- (void)cameraControllerDidCancel:(APCameraOverlayViewController *)controller {
  [self.navigationController setNavigationBarHidden:NO];
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  [self.navigationController popToViewController:self animated:YES];
}

-(void)uploadImage:(UIImage*)image {
    [PFAnalytics trackEvent:@"photoUpload"];
    [[APPhotoUploadQueue sharedQueue] addPhotoToQueue:image forEventID:self.eventID];
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
    if (!self.isSavingBulk) {
        [cell setSelected:NO];
    }
  return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSavingBulk) {
      if (!self.selectedPhotos) {
        self.selectedPhotos = [NSMutableArray array];
      }
      if ([self.selectedPhotos containsObject:indexPath]) {
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [self.selectedPhotos removeObject:indexPath];
      }else{
        [self.selectedPhotos addObject:indexPath];
      }

    }else{
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        APCollectionViewGalleryFlowLayout *layout = [[APCollectionViewGalleryFlowLayout alloc] init];
        APPhotoViewController *controller = [[APPhotoViewController alloc] initWithMetadata:self.photoMetadata atIndexPath:indexPath forCollectionViewLayout:layout];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kEditMyEventSegue]) {
        APCreateEventViewController *editVC = (APCreateEventViewController *)segue.destinationViewController;
        editVC.delegate = self;
        [editVC setEventForEditing:(APEvent *)sender];
    }
}

#pragma mark - StackedGridLayoutDelegate Methods 

-(NSInteger)collectionView:(UICollectionView *)cv layout:(UICollectionViewLayout *)cvl numberOfColumnsInSection:(NSInteger)section {
    return (self.view.frame.size.width > kIPhone6Width ? 3 : 2);
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
    CGFloat width = self.view.frame.size.width / (self.view.frame.size.width > kIPhone6Width ? 3 : 2);
        
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
