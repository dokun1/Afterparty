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
#import <FXBlurView/FXBlurView.h>
#import "UIAlertView+APAlert.h"
#import "APConstants.h"

@import MessageUI;
@import AddressBook;
@import QuartzCore;

@interface APCreateEventViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, VenueChoiceDelegate, UIScrollViewDelegate, FriendInviteDelegate, UITextViewDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet APLabel            *titleLabel;
@property (weak, nonatomic) IBOutlet APLabel            *eventOwnerLabel;
@property (weak, nonatomic) IBOutlet APTextField        *eventNameField;
@property (weak, nonatomic) IBOutlet APLabel            *chooseEventLocationLabel;
@property (weak, nonatomic) IBOutlet APLabel            *chooseEventDateLabel;
@property (weak, nonatomic) IBOutlet APLabel            *chooseEventFriendsLabel;
@property (weak, nonatomic) IBOutlet UIButton           *chooseEventTitleButton;
@property (weak, nonatomic) IBOutlet UIButton           *choosePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton           *chooseEventLocationButton;
@property (weak, nonatomic) IBOutlet UIButton           *chooseEventDateButton;
@property (weak, nonatomic) IBOutlet UIButton           *chooseEventFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton           *chooseEventPasswordButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *privatePasswordLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *publicPasswordLabel;
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
@property (strong, nonatomic) FXBlurView              *blurView;
@property (strong, nonatomic) APButton                *dismissDateButton;
@property (strong, nonatomic) APButton                *endEventCreationButton;
@property (strong, nonatomic) APTextField             *passwordTextField;
@property (strong, nonatomic) APTextField             *confirmPasswordTextField;
@property (strong, nonatomic) UIView                  *passwordFieldContainerView;
@property (assign, nonatomic) BOOL                    isReceivingPassword;

- (IBAction)chooseEventTitleTapped:(id)sender;
- (IBAction)choosePhotoButtonTapped:(id)sender;
- (IBAction)chooseEventLocationButtonTapped:(id)sender;
- (IBAction)chooseEventDateButtonTapped:(id)sender;
- (IBAction)chooseEventFriendsButtonTapped:(id)sender;
- (IBAction)chooseEventPasswordButtonTapped:(id)sender;
- (IBAction)passwordSwitchChanged:(id)sender;
- (IBAction)oneMoreThingButtonTapped:(id)sender;

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
  
  if (!_currentEvent) {
    _currentEvent = [[APEvent alloc] init];
    _currentEvent.createdByUsername = [[PFUser currentUser] username];
  }
  
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
  self.view.backgroundColor = [UIColor afterpartyOffWhiteColor];
  NSString *partyOwner = [NSString stringWithFormat:@"%@'S", [[PFUser currentUser] username]];

  [self.titleLabel styleForType:LabelTypeStandard];
  [self.eventOwnerLabel styleForType:LabelTypeTableViewCellTitle withText:[partyOwner uppercaseString]];
  self.eventOwnerLabel.textColor = [UIColor whiteColor];
  [self.chooseEventLocationLabel styleForType:LabelTypeCreateLabel];
  [self.chooseEventDateLabel styleForType:LabelTypeCreateLabel];
  [self.chooseEventFriendsLabel styleForType:LabelTypeCreateLabel];
  [self.createEventButton style];
  
  self.publicPasswordLabel.font = [UIFont fontWithName:kRegularFont size:13.f];
  self.publicPasswordLabel.textColor = [UIColor afterpartyBlackColor];
  
  [self.publicPasswordLabel setText:@"This event is public." afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
    NSRange greenRange = [self.publicPasswordLabel.text rangeOfString:@"public"];
    if (greenRange.location != NSNotFound) {
      [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor afterpartyBrightGreenColor].CGColor range:greenRange];
    }
    return mutableAttributedString;
  }];
  
  self.privatePasswordLabel.font = [UIFont fontWithName:kRegularFont size:13.f];
  self.privatePasswordLabel.textColor = [UIColor afterpartyBlackColor];
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
  
  self.endEventCreationButton = [[APButton alloc] initWithFrame:CGRectMake(285, 5, 30, 30)];
  [self.endEventCreationButton setImage:[UIImage imageNamed:@"button_plusblack"] forState:UIControlStateNormal];
  [self.endEventCreationButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
  self.endEventCreationButton.transform = CGAffineTransformMakeRotation(45.0*M_PI/180.0);
  [self.endEventCreationButton addTarget:self action:@selector(endButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:self.endEventCreationButton];
  
  self.blurView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
  self.blurView.underlyingView = self.view;
  self.blurView.tintColor = [UIColor clearColor];
  self.blurView.updateInterval = 1;
  self.blurView.blurRadius = 50.f;
  self.blurView.alpha = 0.f;
  [self.view addSubview:self.blurView];

}

- (void)endButtonTapped {
  [self.delegate controllerDidFinish:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self pulsePhotoButton:NO];
}

- (void)pulsePhotoButton:(BOOL)isAppearing {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.delegate = self;
    animation.duration = isAppearing ? 0.5 : 1.5;
    animation.toValue = isAppearing ? @(1.0f) : @(0.05f);
    animation.fromValue = isAppearing ? @(0.05f) : @(1.0f);
    [animation setValue:isAppearing ? @"animateOpacityIn" : @"animateOpacityOut" forKey:@"id"];
    [self.choosePhotoButton.layer addAnimation:animation forKey:@"animateOpacity"];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

#pragma mark - CAAnimation Delegate Methods

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.choosePhotoButton.layer removeAllAnimations];
    CABasicAnimation *animation = (CABasicAnimation*)anim;
    [self pulsePhotoButton:[[animation valueForKey:@"id"] isEqualToString:@"animateOpacityOut"]];
}

-(void)createEventDescriptionUI {
  self.eventDescriptionView = [[APTextView alloc] initWithFrame:CGRectMake(10, self.coverPhotoScrollView.frame.size.height + 90, 300, 140)];
  [self.eventDescriptionView setDelegate:self];
  [self.eventDescriptionView styleWithFontSize:15.f];
  [self.eventDescriptionView.layer setBorderColor:[[UIColor clearColor] CGColor]];
  [self.eventDescriptionView.layer setBorderWidth:0.f];
  [self.eventDescriptionView setAlpha:0.0f];
  [self.eventDescriptionView setBackgroundColor:[UIColor afterpartyOffWhiteColor]];
  self.eventDescriptionView.text = @"Start typing here.";
  [self.eventDescriptionView setReturnKeyType:UIReturnKeyDone];
  [self.view addSubview:self.eventDescriptionView];
  
  self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(-1, self.coverPhotoScrollView.frame.size.height + 80, 322, 0.5f)];
  [self.separatorView setBackgroundColor:[UIColor lightGrayColor]];
  [self.separatorView setAlpha:0.0f];
  [self.view addSubview:self.separatorView];
  
  self.eventDescriptionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, self.coverPhotoScrollView.frame.size.height + 42, 300, 40)];
  [self.eventDescriptionLabel setNumberOfLines:2];
  [self.eventDescriptionLabel setFont:[UIFont fontWithName:kRegularFont size:14.f]];
  [self.eventDescriptionLabel setTextAlignment:NSTextAlignmentCenter];
  [self updateDescriptionCharacterText];
  [self.eventDescriptionLabel setAlpha:0.0f];
  [self.view addSubview:self.eventDescriptionLabel];
  
  self.confirmEventButton = [[APButton alloc] init];
  [self.confirmEventButton style];
  self.confirmEventButton.titleLabel.text = @"DONE AND DONE. CREATE EVENT!";
  [self.confirmEventButton setTitle:@"DONE AND DONE. CREATE EVENT!" forState:UIControlStateNormal];
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
    [textView setFrame:CGRectMake(10, self.coverPhotoScrollView.frame.size.height + 90, 300, 140)];
  }];
}

#pragma mark - UIDatePicker Methods

- (void)createDatePickerContainer {
  self.isReceivingPassword = NO;
  
  [self.blurView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
    [view removeFromSuperview];
  }];
  
  self.dismissDateButton = [[APButton alloc] initWithFrame:CGRectMake(135, self.view.bounds.size.height - 60, 50, 30)];
  [self.dismissDateButton style];
  [self.dismissDateButton setTitle:@"save" forState:UIControlStateNormal];
  [self.dismissDateButton addTarget:self action:@selector(dismissDatePickerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  self.dismissDateButton.alpha = 0.0f;
  [self.view addSubview:self.dismissDateButton];
  
  self.datePickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 440)];
  
  APLabel *startDateLabel = [[APLabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
  [startDateLabel styleForType:LabelTypeStandard withText:@"START TIME"];
  [self.datePickerContainerView addSubview:startDateLabel];
  
  UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 15, 320, 162)];
  [picker setDate:[NSDate date]];
  [picker setMinuteInterval:15];
  [picker setMinimumDate:[NSDate date]];
  self.startDatePicker = picker;
  [self.datePickerContainerView addSubview:picker];
  
  APLabel *endDateLabel = [[APLabel alloc] initWithFrame:CGRectMake(0, 225, 320, 30)];
  [endDateLabel styleForType:LabelTypeStandard withText:@"END TIME"];
  [self.datePickerContainerView addSubview:endDateLabel];
  
  UIDatePicker *endPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 240, 320, 162)];
  [endPicker setMinimumDate:[NSDate dateWithTimeIntervalSinceNow:60*60*4]];
  [endPicker setMinuteInterval:15];
  [endPicker setDate:[NSDate dateWithTimeIntervalSinceNow:60*60*4]];
  self.endDatePicker = endPicker;
  [self.datePickerContainerView addSubview:endPicker];
  
  [self.view addSubview:self.datePickerContainerView];
  
  [self.view bringSubviewToFront:self.dismissDateButton];
  
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.datePickerContainerView setCenter:self.view.center];
                     self.dismissDateButton.alpha = 1.0f;
                   } completion:^(BOOL finished) {
                     self.currentEvent.startDate = self.startDatePicker.date;
                   }];
}

- (void)dismissDatePickerButtonTapped {
  if (self.isReceivingPassword) {
    if (![self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text]) {
      return;
    }
    self.currentEvent.password = self.passwordTextField.text;
    self.privatePasswordLabel.text = [NSString stringWithFormat:@"Password - %@", self.currentEvent.password];
    [self.chooseEventPasswordButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
    [self.passwordTextField resignFirstResponder];
  } else {
    self.currentEvent.startDate = self.startDatePicker.date;
    self.currentEvent.endDate = self.endDatePicker.date;
    self.chooseEventDateLabel.text = [NSString stringWithFormat:@"%@ to %@", [APUtil formatDateForEventCreationScreen:self.currentEvent.startDate] , [APUtil formatDateForEventCreationScreen:self.currentEvent.endDate]];
    [self.chooseEventDateButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
  }

  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.datePickerContainerView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + self.view.bounds.size.height)];
                     [self.passwordFieldContainerView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) + self.view.bounds.size.height)];
                   } completion:^(BOOL finished) {
                     [UIView animateWithDuration:0.5 animations:^{
                       self.blurView.alpha = 0.f;
                       self.dismissDateButton.alpha = 0.0f;
                     }];
                   }];}

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
    if (textField == self.passwordTextField || textField == self.confirmPasswordTextField) {
      if (![self passwordFieldsAreValid]) {
        return YES;
      }
    }
    if (textField == self.eventNameField && textField.text.length > 0) {
        [self.chooseEventTitleButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
    }
  [textField resignFirstResponder];
  [self.currentEvent setEventName:self.eventNameField.text];
  return NO;
}

#pragma mark - UIImagePickerDelegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.choosePhotoButton.layer removeAllAnimations];
    self.choosePhotoButton.alpha = 0.0f;
  [self.coverPhotoImageView removeFromSuperview];
  self.coverPhotoImageView = nil;
  self.coverPhotoImageView = [[UIImageView alloc] initWithImage:image];
  [self.choosePhotoButton setImage:nil forState:UIControlStateNormal];
  [self setZoomScales];
  [self.coverPhotoScrollView addSubview:self.coverPhotoImageView];
  [self.picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VenueChoiceDelegate Methods

- (void)controller:(APFindVenueTableViewController *)controller didChooseVenue:(FSVenue *)venue {
  [self.currentEvent setEventVenue:venue];
  [self.currentEvent setLocation:venue.location.coordinate];
  NSString *address = @"";
  if (venue.location.address) {
    address = venue.location.address;
  }
  [self.currentEvent setEventAddress:address];
  [self.chooseEventLocationLabel setText:venue.name];
  [self.chooseEventLocationButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
  [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FriendInviteDelegate

-(void)didConfirmInvitees:(NSArray *)invitees forController:(APInviteFriendsViewController *)controller{
  self.currentInvitees = invitees;
  [self.chooseEventFriendsLabel setText:([self.currentInvitees count] != 1)?[NSString stringWithFormat:@"%lu friends are invited.", (unsigned long)[self.currentInvitees count]]:[NSString stringWithFormat:@"%lu friend is invited.", (unsigned long)[self.currentInvitees count]]];
  [self.chooseEventFriendsButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
  [controller dismissViewControllerAnimated:YES completion:nil];
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
  [self.delegate controllerDidFinish:self];
}

-(void)sendInvitationsForEventID:(NSString*)eventID {
  [self.confirmEventButton setEnabled:NO];
  [self.confirmEventButton setAlpha:0.0f];
  if(![MFMessageComposeViewController canSendText]) {
    [SVProgressHUD showErrorWithStatus:@"can't send invitations"];
    [self.delegate controllerDidFinish:self];
    return;
  }

  if (self.currentInvitees.count == 0) {
      [self.delegate controllerDidFinish:self];
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
  self.confirmEventButton.enabled = NO;
  [self.currentEvent setEventDescription:self.eventDescriptionView.text];
  self.currentEvent.deleteDate  = [self.currentEvent.endDate dateByAddingTimeInterval:24*60*60];
  PFUser *currentUser = [PFUser currentUser];
  self.currentEvent.eventUserBlurb = currentUser[kPFUserBlurbKey] ? currentUser[kPFUserBlurbKey] : @"This user has no blurb";
  self.currentEvent.eventUserPhotoURL = currentUser[kPFUserProfilePhotoURLKey] ? currentUser[kPFUserProfilePhotoURLKey] : @"";
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
      self.confirmEventButton.enabled = YES;
    }];
    [SVProgressHUD showSuccessWithStatus:@"event saved!"];
  } failure:^(NSError *error) {
    [SVProgressHUD showErrorWithStatus:@"error saving, try again"];
    self.confirmEventButton.enabled = YES;
  }];
}

-(void)fadeOutFirstLabels {
  [UIView animateWithDuration:0.3
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
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
                   } completion:nil];
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

- (IBAction)chooseEventTitleTapped:(id)sender {
    [self.eventNameField becomeFirstResponder];
}

- (IBAction)choosePhotoButtonTapped:(id)sender {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Go Back" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
  [actionSheet showInView:self.view];
}

- (IBAction)chooseEventLocationButtonTapped:(id)sender {
  APFindVenueTableViewController *vc = [[APFindVenueTableViewController alloc] init];
  vc.delegate = self;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)chooseEventDateButtonTapped:(id)sender {
  [UIView animateWithDuration:0.5 animations:^{
    self.blurView.alpha = 1.0f;
  } completion:^(BOOL finished) {
    [self createDatePickerContainer];
  }];
}

- (IBAction)chooseEventFriendsButtonTapped:(id)sender {
  APInviteFriendsViewController *vc = [[APInviteFriendsViewController alloc] initWithSelectedContacts:self.currentInvitees];
  vc.delegate = self;
  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)chooseEventPasswordButtonTapped:(id)sender {
  [UIView animateWithDuration:0.5 animations:^{
    self.blurView.alpha = 1.0f;
  } completion:^(BOOL finished) {
    [self showPasswordField];
  }];
}

- (IBAction)passwordSwitchChanged:(id)sender {
  [UIView animateWithDuration:0.3 animations:^{
    BOOL on = self.privateEventSwitch.on;
    [self.publicPasswordLabel setAlpha:on ? 1.0 : 0.0];
    [self.chooseEventPasswordButton setAlpha:on ? 0.0 : 1.0];
    [self.privatePasswordLabel setAlpha:on ? 0.0 : 1.0];
  }];
}

- (IBAction)oneMoreThingButtonTapped:(id)sender {
  //check everything to see if its complete
  if ([[self.eventNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
    self.eventNameField.backgroundColor = [UIColor afterpartyCoralRedColor];
    [self changeEventButtonColor];
    return;
  }
  if (!self.coverPhotoImageView.image) {
    [self changeEventButtonColor];
    return;
  }
  if (!self.currentEvent.eventVenue) {
    [self changeEventButtonColor];
    return;
  }
  if (!self.currentEvent.startDate || !self.currentEvent.endDate) {
    [self changeEventButtonColor];
    return;
  }
  
  self.currentEvent.eventImage = [self getScrollViewVisibleImage];
  self.currentEvent.eventName = self.eventNameField.text;
  self.currentEvent.password = self.privateEventSwitch.isOn ? @"" : self.passwordTextField.text;
  [self fadeOutFirstLabels];
}

- (UIImage *)getScrollViewVisibleImage {
    UIGraphicsBeginImageContextWithOptions(self.coverPhotoScrollView.bounds.size,
                                           YES,
                                           [UIScreen mainScreen].scale);
    
    CGPoint offset = self.coverPhotoScrollView.contentOffset;
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -offset.x, -offset.y);
    
    [self.coverPhotoScrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *visibleScrollViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return visibleScrollViewImage;
}

#pragma mark - AddressBook Methods

-(void)getContactPermission {
  if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
      ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
    [SVProgressHUD showErrorWithStatus:@"cannot invite anyone"];
  } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
  } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
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

#pragma mark - UIActionSheet Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 2) {
    return;
  }
  self.picker = [[UIImagePickerController alloc] init];
  switch (buttonIndex) {
    case 0:
      self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
      break;
    case 1:
      self.picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    default:
      break;
  }
  self.picker.delegate = self;
  [self presentViewController:self.picker animated:YES completion:nil];
}

#pragma mark - Password Methods

- (void)showPasswordField {
  self.isReceivingPassword = YES;
  [self.blurView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
    [view removeFromSuperview];
  }];
  
  self.dismissDateButton = [[APButton alloc] initWithFrame:CGRectMake(280, 10, 30, 30)];
  [self.dismissDateButton setImage:[UIImage imageNamed:@"button_plusblack"] forState:UIControlStateNormal];
  [self.dismissDateButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
  [self.dismissDateButton addTarget:self action:@selector(dismissDatePickerButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  self.dismissDateButton.transform = CGAffineTransformMakeRotation(45.0*M_PI/180.0);
  [self.view addSubview:self.dismissDateButton];
  
  self.passwordFieldContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 200)];
  self.passwordFieldContainerView.backgroundColor = [UIColor clearColor];
  [self.view addSubview:self.passwordFieldContainerView];
  
  self.passwordTextField = [[APTextField alloc] initWithFrame:CGRectMake(40, 50, self.view.bounds.size.width - 80, 30)];
  [self.passwordTextField styleForPasswordEntry];
  self.passwordTextField.placeholder = @"enter password here";
  self.passwordTextField.delegate = self;
  if (_currentEvent.password) {
    self.passwordTextField.text = _currentEvent.password;
  }
  [self.passwordFieldContainerView addSubview:self.passwordTextField];
  
  self.confirmPasswordTextField = [[APTextField alloc] initWithFrame:CGRectMake(40, 100, self.view.bounds.size.width - 80, 30)];
  [self.confirmPasswordTextField styleForPasswordEntry];
  self.confirmPasswordTextField.placeholder = @"confirm password here";
  self.confirmPasswordTextField.delegate = self;
  if (_currentEvent.password) {
    self.confirmPasswordTextField.text = _currentEvent.password;
  }
  [self.passwordFieldContainerView addSubview:self.confirmPasswordTextField];
  
  [UIView animateWithDuration:0.5
                        delay:0.0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:^{
                     [self.passwordFieldContainerView setCenter:self.view.center];
                   } completion:^(BOOL finished) {
                     
                   }];
}

- (BOOL)passwordFieldsAreValid {
  NSString *field1 = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *field2 = [self.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (![field1 isEqualToString:field2]) {
    [SVProgressHUD showErrorWithStatus:@"passwords do not match"];
    return NO;
  }
  if (field1.length < 4) {
    [SVProgressHUD showErrorWithStatus:@"password must have at least four letters"];
    return NO;
  }
  return YES;
}
@end
