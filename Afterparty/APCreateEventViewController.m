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
#import "APTextView.h"
#import "UIColor+APColor.h"
#import "APConnectionManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "APInviteFriendsViewController.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "APFindVenueTableViewController.h"
#import "APUtil.h"

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
@property (strong, nonatomic) APTextView              *eventDescriptionView;
@property (strong, nonatomic) TTTAttributedLabel      *eventDescriptionLabel;
@property (strong, nonatomic) UIView                  *separatorView;
@property (strong, nonatomic) APButton                *confirmEventButton;



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

- (void)viewDidLoad {
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

-(void)createEventDescriptionUI {
  self.eventDescriptionView = [[APTextView alloc] initWithFrame:CGRectMake(10, self.coverPhotoScrollView.frame.size.height + 130, 300, 140)];
  [self.eventDescriptionView setDelegate:self];
  [self.eventDescriptionView styleWithFontSize:15.f];
  [self.eventDescriptionView.layer setBorderColor:[[UIColor clearColor] CGColor]];
  [self.eventDescriptionView.layer setBorderWidth:0.f];
  [self.eventDescriptionView setAlpha:0.0f];
  [self.eventDescriptionView setBackgroundColor:[UIColor afterpartyOffWhiteColor]];
  [self.eventDescriptionView setReturnKeyType:UIReturnKeyDone];
  [self.view addSubview:self.eventDescriptionView];
  
  self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(-1, self.coverPhotoScrollView.frame.size.height + 120, 322, 0.5f)];
  [self.separatorView setBackgroundColor:[UIColor lightGrayColor]];
  [self.separatorView setAlpha:0.0f];
  [self.view addSubview:self.separatorView];
  
  self.eventDescriptionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, self.coverPhotoScrollView.frame.size.height + 52, 300, 80)];
  [self.eventDescriptionLabel setNumberOfLines:2];
  [self.eventDescriptionLabel setFont:[UIFont fontWithName:kRegularFont size:14.f]];
  [self.eventDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
  [self updateDescriptionCharacterText];
  [self.eventDescriptionLabel setAlpha:0.0f];
  [self.view addSubview:self.eventDescriptionLabel];
  
  self.confirmEventButton = [[APButton alloc] init];
  [self.confirmEventButton style];
  [self.confirmEventButton setFrame:self.createEventButton.frame];
  [self.confirmEventButton setAlpha:0.0f];
  [self.confirmEventButton addTarget:self action:@selector(confirmEventButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.confirmEventButton];
}

-(void)updateDescriptionCharacterText {
  NSString *descriptionText = self.eventDescriptionView.text;
  NSString *charsRemaining = [NSString stringWithFormat:@"%lu", 140-(unsigned long)[descriptionText length]];
  if ([descriptionText isEqualToString:@"Start typing here."]) {
    charsRemaining = @"140";
  }
  NSString *labelText = [NSString stringWithFormat:@"You've got %@ characters left to tell us all about the event. Choose your words wisely.", charsRemaining];
  [self.eventDescriptionLabel setText:labelText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
    //customize to make the number in bold and maybe colored?
    return mutableAttributedString;
  }];
}

#pragma mark - UITextView Delegate Methods

-(void)textViewDidChange:(UITextView *)textView {
  if ([textView.text length] >= 1) {
    if ([[textView.text substringFromIndex:([textView.text length]-1)] isEqualToString:@"\n"]) {
      [textView endEditing:YES];
    }
  }
  [self updateDescriptionCharacterText];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
  if ([textView.text isEqualToString:@"Start typing here."]) {
    [textView setText:@""];
  }
  [UIView animateWithDuration:0.2 animations:^{
    [textView setFrame:CGRectMake(10, 70, 300, 140)];
  }];
};

-(void)textViewDidEndEditing:(UITextView *)textView {
  if ([textView.text length] >= 1) {
    NSString *text = [textView.text substringToIndex:([textView.text length]-1)];
    [textView setText:text];
  }
  [UIView animateWithDuration:0.2 animations:^{
    [textView setFrame:CGRectMake(10, self.coverPhotoScrollView.frame.size.height + 130, 300, 140)];
  }];
}

#pragma mark - UIDatePicker Methods

-(UIDatePicker*)createStartDatePicker {
  UIDatePicker *picker = [[UIDatePicker alloc] init];
  [picker setDate:[NSDate date]];
  [picker setMinuteInterval:15];
  self.datePickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 202)];
  [self.datePickerContainerView addSubview:picker];
  [picker setFrame:CGRectMake(0, self.datePickerContainerView.bounds.size.height - 162, 320, 162)];
  APButton *dismissButton = [[APButton alloc] init];
  [dismissButton addTarget:self action:@selector(dismissEndDatePicker) forControlEvents:UIControlEventTouchUpInside];
  [dismissButton style];
  dismissButton.titleLabel.text = @"DISMISS";
  [self.datePickerContainerView addSubview:dismissButton];
  [dismissButton setFrame:CGRectMake(self.view.bounds.size.width - 100, 0, 80, 40)];
  [self.datePickerContainerView setBackgroundColor:[UIColor afterpartyTealBlueColor]];
  [self.view addSubview:self.datePickerContainerView];  [picker setMinimumDate:[NSDate date]];
  return picker;
}

-(UIDatePicker*)createEndDatePicker {
  if (!self.currentEvent.startDate) {
    [SVProgressHUD showErrorWithStatus:@"must pick start time first"];
    return nil;
  }
  UIDatePicker *picker = [[UIDatePicker alloc] init];
  [picker setMinimumDate:self.currentEvent.startDate];
  [picker setMinuteInterval:15];
  self.datePickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 202)];
  [self.datePickerContainerView addSubview:picker];
  [picker setFrame:CGRectMake(0, self.datePickerContainerView.bounds.size.height - 162, 320, 162)];
  APButton *dismissButton = [[APButton alloc] init];
  [dismissButton addTarget:self action:@selector(dismissEndDatePicker) forControlEvents:UIControlEventTouchUpInside];
  [dismissButton style];
  dismissButton.titleLabel.text = @"DISMISS";
  [self.datePickerContainerView addSubview:dismissButton];
  [dismissButton setFrame:CGRectMake(self.view.bounds.size.width - 100, 0, 80, 40)];
  [self.datePickerContainerView setBackgroundColor:[UIColor afterpartyTealBlueColor]];
  [self.view addSubview:self.datePickerContainerView];
  [picker setDate:[NSDate dateWithTimeIntervalSinceNow:60*60*4]];
  return picker;
}

-(void)presentStartDatePicker {
  if (!self.startDatePicker && !self.datePickerContainerView) {
    return;
  }
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.datePickerContainerView setCenter:self.view.center];
                   } completion:^(BOOL finished) {
                     self.currentEvent.startDate = self.startDatePicker.date;
                   }];
}

-(void)dismissStartDatePicker {
  if (!self.startDatePicker && !self.datePickerContainerView) {
    return;
  }
  NSLog(@"start date picker; %@", self.startDatePicker.date);
  self.currentEvent.startDate = self.startDatePicker.date;
//  [self.chooseStartDateLabel setText:[NSString stringWithFormat:@"Starts at %@", [APUtil formatDateForEventDetailScreen:self.startDatePicker.date]]];
//  [self.chooseStartDateButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.datePickerContainerView setFrame:CGRectMake(0, self.view.bounds.size.height, 320, 202)];
                   } completion:^(BOOL finished) {
                     [self.datePickerContainerView removeFromSuperview];
                     self.datePickerContainerView = nil;
                   }];
}

-(void)presentEndDatePicker {
  if (!self.endDatePicker && !self.datePickerContainerView) {
    return;
  }
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.datePickerContainerView setCenter:self.view.center];
                   } completion:^(BOOL finished) {
                     self.currentEvent.endDate = self.endDatePicker.date;
                   }];
}

-(void)dismissEndDatePicker {
  if (!self.endDatePicker && !self.datePickerContainerView) {
    return;
  }
  NSLog(@"end date picker; %@", self.endDatePicker.date);
  self.currentEvent.endDate = self.endDatePicker.date;
  NSTimeInterval secondsInTwentyFourHours = 24 * 60 * 60;
  NSDate *deleteDate = [self.endDatePicker.date dateByAddingTimeInterval:secondsInTwentyFourHours];
  self.currentEvent.deleteDate = deleteDate;
//  [self.chooseEndDateLabel setText:[NSString stringWithFormat:@"Ends at %@", [APUtil formatDateForEventDetailScreen:self.endDatePicker.date]]];
//  [self.chooseEndDateButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.datePickerContainerView setFrame:CGRectMake(0, self.view.bounds.size.height, 320, 202)];
                   } completion:^(BOOL finished) {
                     [self.datePickerContainerView removeFromSuperview];
                     self.datePickerContainerView = nil;
                   }];
}

-(void)dismissScreen {
  [self dismissViewControllerAnimated:YES completion:nil];
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
