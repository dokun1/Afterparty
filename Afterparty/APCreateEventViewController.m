//
//  APCreateEventViewController.m
//  Afterparty
//
//  Created by David Okun on 6/28/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APCreateEventViewController.h"
#import "APLabel.h"
#import "APTextField.h"
#import "APButton.h"
#import "UIColor+APColor.h"
#import "APConnectionManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "APInviteFriendsViewController.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "APFindVenueTableViewController.h"

@import MessageUI;
@import AddressBook;

@interface APCreateEventViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, VenueChoiceDelegate, UIScrollViewDelegate, FriendInviteDelegate, UITextViewDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet APLabel            *titleLabel;
@property (weak, nonatomic) IBOutlet APLabel            *eventOwnerLabel;
@property (weak, nonatomic) IBOutlet APTextField        *eventNameField;
@property (weak, nonatomic) IBOutlet APLabel            *choosePhotoLabel;
@property (weak, nonatomic) IBOutlet APLabel            *chooseEventLocationLabel;
@property (weak, nonatomic) IBOutlet APLabel            *chooseEventDateLabel;
@property (weak, nonatomic) IBOutlet APLabel            *chooseEventFriendsLabel;
@property (weak, nonatomic) IBOutlet UIButton           *choosePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton           *chooseEventLocationButton;
@property (weak, nonatomic) IBOutlet UIButton           *chooseEventDateButton;
@property (weak, nonatomic) IBOutlet UIButton           *chooseEventFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton           *chooseEventPasswordButton;
@property (weak, nonatomic) IBOutlet APLabel            *privatePasswordLabel;
@property (weak, nonatomic) IBOutlet APLabel            *publicPasswordLabel;
@property (weak, nonatomic) IBOutlet UISwitch           *privateEventSwitch;
@property (weak, nonatomic) IBOutlet APButton           *createEventButton;

@property (strong, nonatomic) APEvent                 *currentEvent;
@property (strong, nonatomic) NSArray                 *currentInvitees;
@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) UIDatePicker            *startDatePicker;
@property (strong, nonatomic) UIDatePicker            *endDatePicker;
@property (strong, nonatomic) UIView                  *datePickerContainerView;
@property (strong, nonatomic) UIImage                 *croppedEventPhoto;
@property (strong, nonatomic) UIScrollView            *coverPhotoScrollView;
@property (strong, nonatomic) UIImageView             *coverPhotoImageView;
@property (strong, nonatomic) UITextView              *eventDescriptionView;
@property (strong, nonatomic) TTTAttributedLabel      *eventDescriptionLabel;
@property (strong, nonatomic) UIView                  *separatorView;
@property (strong, nonatomic) UIButton                *confirmEventButton;



- (IBAction)choosePhotoButtonTapped:(id)sender;
- (IBAction)chooseEventLocationButtonTapped:(id)sender;
- (IBAction)chooseEventDateButtonTapped:(id)sender;
- (IBAction)chooseEventFriendsButtonTapped:(id)sender;
- (IBAction)chooseEventPasswordButtonTapped:(id)sender;

@end

@implementation APCreateEventViewController

-(id)initForNewEvent {
  if (self = [super init]) {
    _currentEvent = [[APEvent alloc] init];
    _currentEvent.createdByUsername = [[PFUser currentUser] username];
  }
  return self;
}

-(id)initForEditingWithEvent:(APEvent *)event {
  if (self = [super init]) {
    _currentEvent = event;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self getContactPermission];
  
  [self initializeCustomUI];
  
  [UIApplication sharedApplication].statusBarHidden = YES;
  
  self.coverPhotoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, 320, 170)];
  
  self.coverPhotoScrollView.backgroundColor = [UIColor afterpartyTealBlueColor];
  self.coverPhotoScrollView.contentSize = self.coverPhotoScrollView.bounds.size;
  [self.view addSubview:self.coverPhotoScrollView];
  self.coverPhotoImageView = [[UIImageView alloc] initWithFrame:self.coverPhotoScrollView.bounds];
  [self.coverPhotoScrollView addSubview:self.coverPhotoImageView];
  
  self.coverPhotoScrollView.delegate = self;
  self.coverPhotoScrollView.minimumZoomScale = 0.1;
  self.coverPhotoScrollView.zoomScale = 1.0;
  self.coverPhotoScrollView.maximumZoomScale = 3.0;
  
  [self.coverPhotoImageView setBackgroundColor:[UIColor afterpartyTealBlueColor]];
  [self.view sendSubviewToBack:self.coverPhotoScrollView];
  
  [self.eventNameField setFont:[UIFont fontWithName:kBoldFont size:20.f]];
  [self.eventNameField setTextColor:[UIColor afterpartyOffWhiteColor]];
  [self.eventNameField setText:@""];
  [self.eventNameField setPlaceholder:@"NAME YOUR EVENT"];
  [self.eventNameField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
  [self.eventNameField setDelegate:self];
  [self.eventNameField setReturnKeyType:UIReturnKeyDone];


    // Do any additional setup after loading the view.
}

- (void)initializeCustomUI {
  NSString *partyOwner = [NSString stringWithFormat:@"%@'S", [[PFUser currentUser] username]];

  [self.eventOwnerLabel styleForType:LabelTypeTableViewCellAttribute withText:[partyOwner uppercaseString]];
  [self.choosePhotoLabel styleForType:LabelTypeCreateLabel];
  [self.chooseEventLocationLabel styleForType:LabelTypeCreateLabel];
  [self.chooseEventDateLabel styleForType:LabelTypeCreateLabel];
  [self.chooseEventFriendsLabel styleForType:LabelTypeCreateLabel];
  [self.createEventButton style];
  
  [self.publicPasswordLabel styleForType:LabelTypeCreateLabel];
  [self.publicPasswordLabel setText:@"This event is public." afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
    NSRange greenRange = [self.publicPasswordLabel.text rangeOfString:@"public"];
    if (greenRange.location != NSNotFound) {
      [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor afterpartyBrightGreenColor].CGColor range:greenRange];
    }
    return mutableAttributedString;
  }];
  
  [self.privatePasswordLabel styleForType:LabelTypeCreateLabel withText:@"Add password, it's private."];
  [self.privatePasswordLabel setText:@"Add password, it's private." afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
    NSRange redRange = [self.privatePasswordLabel.text rangeOfString:@"private"];
    if (redRange.location != NSNotFound) {
      [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor afterpartyCoralRedColor] range:redRange];
    }
    return mutableAttributedString;
  }];
  
  [self.privateEventSwitch setTintColor:[UIColor afterpartyCoralRedColor]];
  [self.privateEventSwitch setOnTintColor:[UIColor afterpartyBrightGreenColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark - IBAction Methods

- (IBAction)choosePhotoButtonTapped:(id)sender {
}

- (IBAction)chooseEventLocationButtonTapped:(id)sender {
}

- (IBAction)chooseEventDateButtonTapped:(id)sender {
}

- (IBAction)chooseEventFriendsButtonTapped:(id)sender {
}

- (IBAction)chooseEventPasswordButtonTapped:(id)sender {
}

#pragma mark - AddressBook Methods

-(void)getContactPermission {
  if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
      ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
    NSLog(@"Denied");
    [SVProgressHUD showErrorWithStatus:@"cannot invite anyone"];
  } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
    NSLog(@"Authorized");
  } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
    NSLog(@"Not determined");
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (!granted){
          [SVProgressHUD showErrorWithStatus:@"cannot invite anyone"];
          return;
        }
      });
    });
  }
}
@end
