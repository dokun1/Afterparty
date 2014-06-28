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
  
  [self.chooseEventDateButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
  [self.chooseEventFriendsButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
  [self.chooseEventPasswordButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
  [self.chooseEventLocationButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
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

#pragma mark - UIScrollViewDelegate Methods

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.coverPhotoImageView;
}

-(void)setZoomScales {
  CGSize boundsSize = self.coverPhotoScrollView.bounds.size;
  CGSize imageSize = self.coverPhotoImageView.bounds.size;
  
  CGFloat xScale = boundsSize.width/imageSize.width;
  CGFloat yScale = boundsSize.height/imageSize.height;
  CGFloat minScale = MAX(xScale,yScale);
  
  self.coverPhotoScrollView.minimumZoomScale = minScale;
  self.coverPhotoScrollView.zoomScale = minScale;
  self.coverPhotoScrollView.maximumZoomScale = 3.0;
}

#pragma mark - UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  [self.currentEvent setEventName:self.eventNameField.text];
  return NO;
}

#pragma mark - UIImagePickerDelegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
  [self.coverPhotoImageView removeFromSuperview];
  self.coverPhotoImageView = nil;
  self.coverPhotoImageView = [[UIImageView alloc] initWithImage:image];
  [self.choosePhotoButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
  [self setZoomScales];
  [self.coverPhotoScrollView addSubview:self.coverPhotoImageView];
  [self.picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VenueChoiceDelegate Methods

-(void)controllerDidChooseVenue:(FSVenue *)venue {
  [self.currentEvent setEventVenue:venue];
  [self.currentEvent setLocation:venue.location.coordinate];
  NSString *address = @"";
  if (venue.location.address) {
    address = venue.location.address;
  }
  [self.currentEvent setEventAddress:address];
  [self.chooseEventLocationLabel setText:venue.name];
  [self.chooseEventLocationButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
  [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - FriendInviteDelegate

-(void)didConfirmInvitees:(NSArray *)invitees {
  self.currentInvitees = invitees;
  [self.chooseEventFriendsLabel setText:([self.currentInvitees count] != 1)?[NSString stringWithFormat:@"%lu friends are invited.", (unsigned long)[self.currentInvitees count]]:[NSString stringWithFormat:@"%lu friend is invited.", (unsigned long)[self.currentInvitees count]]];
  [self.chooseEventFriendsButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
  [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - MFMailComposeViewControllerDelegate methods

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
  [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendInvitationsForEventID:(NSString*)eventID {
  [self.confirmEventButton setEnabled:NO];
  [self.confirmEventButton setAlpha:0.0f];
  if(![MFMessageComposeViewController canSendText]) {
    [SVProgressHUD showErrorWithStatus:@"can't send invitations"];
    return;
  }
  
  NSMutableArray *numbers = [NSMutableArray array];
  [self.currentInvitees enumerateObjectsUsingBlock:^(NSDictionary *contactDict, NSUInteger idx, BOOL *stop) {
    [numbers addObject:contactDict[@"phone"]];
  }];
  
  
  NSString * message = [NSString stringWithFormat:@"Psst...there's a party going on here: afterparty://eventID:%@", eventID];
  
  MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
  messageController.messageComposeDelegate = self;
  [messageController setRecipients:numbers];
  [messageController setBody:message];
  
  [self presentViewController:messageController animated:YES completion:nil];
}

-(void)changeEventButtonColor {
  self.createEventButton.titleLabel.text = @"HANG ON, YOU'RE MISSING STUFF!";
  [self.createEventButton setBackgroundColor:[UIColor afterpartyCoralRedColor]];
}

-(void)confirmEventButtonTapped:(id)sender {
  [SVProgressHUD showWithStatus:@"saving event"];
  [self.currentEvent setEventDescription:self.eventDescriptionView.text];
  [[APConnectionManager sharedManager] saveEvent:self.currentEvent success:^(BOOL succeeded) {
    [[APConnectionManager sharedManager] lookupEventByName:self.currentEvent.eventName user:[PFUser currentUser] success:^(NSArray *objects) {
      PFObject *object = [objects lastObject];
      APEvent *thisEvent = [[APEvent alloc] initWithParseObject:object];
      NSData *photoData = UIImagePNGRepresentation(self.currentEvent.eventImage);
      [thisEvent setEventImageData:photoData];
      [APUtil saveEventToMyEvents:thisEvent];
      [self sendInvitationsForEventID:object.objectId];
    } failure:^(NSError *error) {
      [SVProgressHUD showErrorWithStatus:@"unknown error occurred"];
    }];
    [SVProgressHUD showSuccessWithStatus:@"event saved!"];
  } failure:^(NSError *error) {
    [SVProgressHUD showErrorWithStatus:@"error saving, try again"];
  }];
}

-(void)fadeOutFirstLabels {
  [UIView animateWithDuration:0.3
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     self.choosePhotoLabel.alpha          = 0.0f;
                     self.chooseEventDateLabel.alpha      = 0.0f;
                     self.chooseEventFriendsLabel.alpha   = 0.0f;
                     self.chooseEventLocationLabel.alpha  = 0.0f;
                     self.publicPasswordLabel.alpha       = 0.0f;
                     self.privatePasswordLabel.alpha      = 0.0f;
                     self.privateEventSwitch.alpha        = 0.0f;
                     self.chooseEventPasswordButton.alpha = 0.0f;
                     
                     self.choosePhotoButton.alpha         = 0.0f;
                     self.chooseEventLocationButton.alpha = 0.0f;
                     self.chooseEventDateButton.alpha     = 0.0f;
                     self.chooseEventFriendsButton.alpha  = 0.0f;
                     self.createEventButton.alpha         = 0.0f;
                     [self.coverPhotoScrollView setScrollEnabled:NO];
                   } completion:^(BOOL finished) {
                     [self createEventDescriptionUI];
                     [self fadeInSecondLabels];
                   }];
}

-(void)fadeInFirstLabels {
  [UIView animateWithDuration:0.3
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     self.choosePhotoLabel.alpha          = 1.0f;
                     self.chooseEventDateLabel.alpha      = 1.0f;
                     self.chooseEventFriendsLabel.alpha   = 1.0f;
                     self.chooseEventLocationLabel.alpha  = 1.0f;
                     self.publicPasswordLabel.alpha       = 1.0f;
                     self.privatePasswordLabel.alpha      = 1.0f;
                     self.privateEventSwitch.alpha        = 1.0f;
                     self.chooseEventPasswordButton.alpha = 1.0f;
                     
                     self.choosePhotoButton.alpha         = 1.0f;
                     self.chooseEventLocationButton.alpha = 1.0f;
                     self.chooseEventDateButton.alpha     = 1.0f;
                     self.chooseEventFriendsButton.alpha  = 1.0f;
                     self.createEventButton.alpha         = 1.0f;
                     [self.coverPhotoScrollView setScrollEnabled:YES];
                   } completion:^(BOOL finished) {
                     [self fadeInSecondLabels];
                   }];
}

-(void)fadeInSecondLabels {
  [UIView animateWithDuration:0.3
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     self.eventDescriptionView.alpha  = 1.0f;
                     self.eventDescriptionLabel.alpha = 1.0f;
                     self.separatorView.alpha         = 1.0f;
                     self.confirmEventButton.alpha    = 1.0f;
                   } completion:nil];
}

-(void)fadeOutSecondLabels {
  [UIView animateWithDuration:0.3
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     self.eventDescriptionView.alpha  = 0.0f;
                     self.eventDescriptionLabel.alpha = 0.0f;
                     self.separatorView.alpha         = 0.0f;
                     self.confirmEventButton.alpha    = 0.0f;
                   } completion:^(BOOL finished) {
                     [self fadeInFirstLabels];
                   }];
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
