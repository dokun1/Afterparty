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
#import "UIAlertView+APAlert.h"
#import "APConstants.h"
#import "APCreateEventTimeViewController.h"
#import "APCreateEventPasswordViewController.h"
#import "APVenue.h"
#import <DeeplinkSDK/DeeplinkSDK.h>

@import MessageUI;
@import AddressBook;
@import QuartzCore;

static NSString *kSetTimeSegue = @"setEventTimeSegue";
static NSString *kSetPasswordSegue = @"setPasswordSegue";

@interface APCreateEventViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, VenueChoiceDelegate, UIScrollViewDelegate, FriendInviteDelegate, UITextViewDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, APEventTimeDelegate, PasswordDelegate>

@property (strong, nonatomic) APLabel            *titleLabel;
@property (strong, nonatomic) APLabel            *eventOwnerLabel;
@property (strong, nonatomic) APTextField        *eventNameField;
@property (strong, nonatomic) APLabel            *chooseEventLocationLabel;
@property (strong, nonatomic) APLabel            *chooseEventDateLabel;
@property (strong, nonatomic) APLabel            *chooseEventFriendsLabel;
@property (strong, nonatomic) UIButton           *chooseEventTitleButton;
@property (strong, nonatomic) UIButton           *choosePhotoButton;
@property (strong, nonatomic) UIButton           *chooseEventLocationButton;
@property (strong, nonatomic) UIButton           *chooseEventDateButton;
@property (strong, nonatomic) UIButton           *chooseEventFriendsButton;
@property (strong, nonatomic) UIButton           *chooseEventPasswordButton;
@property (strong, nonatomic) UIButton           *choosePhotoFakeButton;
@property (strong, nonatomic) TTTAttributedLabel *privatePasswordLabel;
@property (strong, nonatomic) TTTAttributedLabel *publicPasswordLabel;
@property (strong, nonatomic) UISwitch           *privateEventSwitch;
@property (strong, nonatomic) APButton           *createEventButton;

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
@property (strong, nonatomic) APButton                *dismissDateButton;
@property (strong, nonatomic) UIView                  *passwordFieldContainerView;
@property (assign, nonatomic) BOOL                    isReceivingPassword;
@property (assign, nonatomic) CGFloat                 widthFactor;

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
    self.widthFactor = self.view.frame.size.width / 320;
    
    [self pulsePhotoButton:NO];
  
  [self getContactPermission];
  
  [self initializeCustomUI];
}

- (UIButton *)generateAddElementButtonForPoint:(CGPoint)point {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(point.x, point.y, 30, 30);
    [button setImage:[UIImage imageNamed:@"button_plusblack"] forState:UIControlStateNormal];
    return button;
}

- (void)initializeCustomUI {
    self.view.backgroundColor = [UIColor afterpartyOffWhiteColor];
    NSString *partyOwner = [NSString stringWithFormat:@"%@'S", [[PFUser currentUser] username]];

    [self.titleLabel styleForType:LabelTypeStandard];
    
    self.coverPhotoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320 * self.widthFactor, 170 * self.widthFactor)];
    
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
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePhotoButtonTapped:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.coverPhotoScrollView addGestureRecognizer:tapRecognizer];
    [self.view sendSubviewToBack:self.coverPhotoScrollView];
    
    CGFloat y = 10;
    
    CGFloat elementX = 10.f;
    CGFloat elementWidth = self.view.frame.size.width - elementX * 2;
    CGFloat elementHeight = 30.f;
    
    self.eventOwnerLabel = [[APLabel alloc] initWithFrame:CGRectMake(elementX, y, elementWidth, elementHeight)];
  [self.eventOwnerLabel styleForType:LabelTypeTableViewCellTitle withText:[partyOwner uppercaseString]];
  self.eventOwnerLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.eventOwnerLabel];
    
    y += self.eventOwnerLabel.frame.size.height + elementX;
    
    self.chooseEventTitleButton = [self generateAddElementButtonForPoint:CGPointMake(elementX, y)];
    [self.chooseEventTitleButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateNormal];
    [self.chooseEventTitleButton addTarget:self action:@selector(chooseEventTitleTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.chooseEventTitleButton];
    
    self.eventNameField = [[APTextField alloc] initWithFrame:CGRectMake(40, y, elementWidth - 40, elementHeight)];
    [self.eventNameField setFont:[UIFont fontWithName:kBoldFont size:20.f]];
    [self.eventNameField setTextColor:[UIColor afterpartyOffWhiteColor]];
    [self.eventNameField setText:@""];
    [self.eventNameField setPlaceholder:@"NAME YOUR EVENT"];
    [self.eventNameField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
    [self.eventNameField setDelegate:self];
    [self.eventNameField setReturnKeyType:UIReturnKeyDone];
    [self.view addSubview:self.eventNameField];
    
    y += self.eventNameField.frame.size.height + elementX;
    
    self.choosePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.choosePhotoButton setImage:[UIImage imageNamed:@"photo-512copy"] forState:UIControlStateNormal];
    self.choosePhotoButton.frame = CGRectMake(CGRectGetMidX(self.view.frame) - 40, y, 80, 80);
    [self.choosePhotoButton addTarget:self action:@selector(choosePhotoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.choosePhotoButton];
    
    self.choosePhotoFakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.choosePhotoFakeButton.frame = self.choosePhotoButton.frame;
    [self.choosePhotoFakeButton addTarget:self action:@selector(choosePhotoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.choosePhotoFakeButton];
    [self.view bringSubviewToFront:self.choosePhotoFakeButton];
    
    y = self.coverPhotoScrollView.frame.size.height;
    
    y += 20;
    if (self.view.frame.size.height == 480.f) {
        y -= 10;
    }
    
    CGFloat theta = y;
    
    CGFloat doneButtonHeight = self.view.frame.size.height - 124;
    
    CGFloat phi = doneButtonHeight - 50;
    if (self.view.frame.size.height == 480.f) {
        phi += 10;
    }
    
    self.createEventButton = [[APButton alloc] initWithFrame:CGRectMake(elementX, doneButtonHeight, elementWidth, 50)];
    [self.createEventButton style];
    [self.createEventButton setTitle:@"AND ONE LAST THING. ONWARD!" forState:UIControlStateNormal];
    [self.createEventButton addTarget:self action:@selector(oneMoreThingButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createEventButton];
    
    CGFloat spacing = (phi - theta - 100) / 3;
    
    CGFloat yIncrement = spacing + 30;
    
    self.chooseEventLocationButton = [self generateAddElementButtonForPoint:CGPointMake(elementX, y)];
    [self.chooseEventLocationButton addTarget:self action:@selector(chooseEventLocationButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.chooseEventLocationButton];
    
    self.chooseEventLocationLabel = [[APLabel alloc] initWithFrame:CGRectMake(50, y, elementWidth - 50, elementHeight)];
    self.chooseEventLocationLabel.text = @"Where is it going to be?";
    [self.view addSubview:self.chooseEventLocationLabel];
    
    y += yIncrement;
    
    self.chooseEventDateButton = [self generateAddElementButtonForPoint:CGPointMake(elementX, y)];
    [self.chooseEventDateButton addTarget:self action:@selector(chooseEventDateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.chooseEventDateButton];
    
    self.chooseEventDateLabel = [[APLabel alloc] initWithFrame:CGRectMake(50, y, elementWidth - 50, elementHeight)];
    self.chooseEventDateLabel.text = @"What date and at what time?";
    [self.view addSubview:self.chooseEventDateLabel];
    
    y += yIncrement;
    
    self.chooseEventFriendsButton = [self generateAddElementButtonForPoint:CGPointMake(elementX, y)];
    [self.chooseEventFriendsButton addTarget:self action:@selector(chooseEventFriendsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.chooseEventFriendsButton];
    
    self.chooseEventFriendsLabel = [[APLabel alloc] initWithFrame:CGRectMake(50, y, elementWidth - 50, elementHeight)];
    self.chooseEventFriendsLabel.text = @"Now, invite your friends!";
    [self.view addSubview:self.chooseEventFriendsLabel];
    
    y += yIncrement;
    
    self.chooseEventPasswordButton = [self generateAddElementButtonForPoint:CGPointMake(elementX, y)];
    [self.chooseEventPasswordButton addTarget:self action:@selector(chooseEventPasswordButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.chooseEventPasswordButton];
    self.chooseEventPasswordButton.alpha = 0.0f;
    
    self.publicPasswordLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(elementX, y, elementWidth, 30)];
    self.publicPasswordLabel.font = [UIFont fontWithName:kRegularFont size:13.f];
    self.publicPasswordLabel.textColor = [UIColor afterpartyBlackColor];
    [self.publicPasswordLabel setText:@"This event is public." afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange greenRange = [@"This event is public." rangeOfString:@"public"];
        if (greenRange.location != NSNotFound) {
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor afterpartyBrightGreenColor].CGColor range:greenRange];
        }
        return mutableAttributedString;
    }];
    [self.view addSubview:self.publicPasswordLabel];
    
    self.privatePasswordLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(50, y, elementWidth - 50, elementHeight)];
    self.privatePasswordLabel.font = [UIFont fontWithName:kRegularFont size:13.f];
    self.privatePasswordLabel.textColor = [UIColor afterpartyBlackColor];
    [self.privatePasswordLabel setText:@"Add password, it's private." afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange redRange = [@"Add password, it's private." rangeOfString:@"private"];
        if (redRange.location != NSNotFound) {
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor afterpartyCoralRedColor] range:redRange];
        }
        return mutableAttributedString;
    }];
    [self.view addSubview:self.privatePasswordLabel];
    self.privatePasswordLabel.alpha = 0.0f;
    
  [self.chooseEventLocationLabel styleForType:LabelTypeCreateLabel];
  [self.chooseEventDateLabel styleForType:LabelTypeCreateLabel];
  [self.chooseEventFriendsLabel styleForType:LabelTypeCreateLabel];
  [self.createEventButton style];
  
    self.privateEventSwitch = [[UISwitch alloc] init];
    [self.privateEventSwitch setCenter:CGPointMake(self.view.frame.size.width - 36, y + 15)];
    [self.privateEventSwitch setTintColor:[UIColor afterpartyCoralRedColor]];
    [self.privateEventSwitch setOnTintColor:[UIColor afterpartyBrightGreenColor]];
    [self.privateEventSwitch addTarget:self action:@selector(passwordSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.privateEventSwitch];
    self.privateEventSwitch.on = YES;
  
  [self.chooseEventDateButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
  [self.chooseEventFriendsButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
  [self.chooseEventPasswordButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
  [self.chooseEventLocationButton setImage:[UIImage imageNamed:@"button_pluswhite"] forState:UIControlStateHighlighted];
    
    [self.view bringSubviewToFront:self.eventNameField];
}

- (void)endButtonTapped {
    [self.delegate controllerDidFinish:self withEventID:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.choosePhotoButton.enabled = YES;
}

- (void)pulsePhotoButton:(BOOL)isAppearing {
    [UIView animateWithDuration:isAppearing?0.5:1.5 animations:^{
        self.choosePhotoButton.alpha = isAppearing?1.0f:0.05f;
    } completion:^(BOOL finished) {
        [self pulsePhotoButton:!isAppearing];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

-(void)createEventDescriptionUI {
  self.eventDescriptionView = [[APTextView alloc] initWithFrame:CGRectMake(10, self.coverPhotoScrollView.frame.size.height + 50, self.view.frame.size.width - 20, 140)];
  [self.eventDescriptionView setDelegate:self];
  [self.eventDescriptionView styleWithFontSize:15.f];
  [self.eventDescriptionView.layer setBorderColor:[[UIColor clearColor] CGColor]];
  [self.eventDescriptionView.layer setBorderWidth:0.f];
  [self.eventDescriptionView setAlpha:0.0f];
  [self.eventDescriptionView setBackgroundColor:[UIColor afterpartyOffWhiteColor]];
  self.eventDescriptionView.text = @"Start typing here.";
  [self.eventDescriptionView setReturnKeyType:UIReturnKeyDone];
  [self.view addSubview:self.eventDescriptionView];
  
  self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(-1, self.coverPhotoScrollView.frame.size.height + 40, self.view.frame.size.width + 2, 0.5f)];
  [self.separatorView setBackgroundColor:[UIColor lightGrayColor]];
  [self.separatorView setAlpha:0.0f];
  [self.view addSubview:self.separatorView];
  
  self.eventDescriptionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, self.coverPhotoScrollView.frame.size.height + 2, self.view.frame.size.width - 20, 40)];
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
    
    self.eventNameField.enabled = NO;
}

-(void)updateDescriptionCharacterText {
  NSString *descriptionText = self.eventDescriptionView.text;
  NSString *charsRemaining = [NSString stringWithFormat:@"%lu", 100-(unsigned long)[descriptionText length]];
  if ([descriptionText isEqualToString:@"Start typing here."]) {
    charsRemaining = @"100";
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
    [textView setFrame:CGRectMake(10, 70, self.view.frame.size.width - 20, 140)];
  }];
};

-(void)textViewDidEndEditing:(UITextView *)textView {
  if ([textView.text length] >= 1) {
    NSString *text = [textView.text substringToIndex:([textView.text length]-1)];
    [textView setText:text];
  }
  [UIView animateWithDuration:0.2 animations:^{
    [textView setFrame:CGRectMake(10, self.coverPhotoScrollView.frame.size.height + 50, self.view.frame.size.width - 20, 140)];
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
    if (textField == self.eventNameField && textField.text.length > 0) {
        [self.chooseEventTitleButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
    }
    [textField resignFirstResponder];
    [self.currentEvent setEventName:self.eventNameField.text];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.eventNameField) {
        NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        
        if (lowercaseCharRange.location != NSNotFound) {
            textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                     withString:[string uppercaseString]];
            return NO;
        }
        
        return YES;
    } else {
        return YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    NSUInteger oldLength = [textView.text length];
    NSUInteger replacementLength = [text length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    return newLength <= 100;
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

- (void)controller:(APFindVenueTableViewController *)controller didChooseVenue:(APVenue *)venue {
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

-(void)didConfirmInvitees:(NSArray *)invitees forController:(APInviteFriendsViewController *)controller{
    self.currentInvitees = invitees;
    [self.chooseEventFriendsLabel setText:([self.currentInvitees count] != 1)?[NSString stringWithFormat:@"%lu friends are invited.", (unsigned long)[self.currentInvitees count]]:[NSString stringWithFormat:@"%lu friend is invited.", (unsigned long)[self.currentInvitees count]]];
    [self.chooseEventFriendsButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
    [self.navigationController popToViewController:self animated:YES];
}

- (void)didUpdateInvitees:(NSArray *)invitees forController:(APInviteFriendsViewController *)controller {
    self.currentInvitees = invitees;
    [self.chooseEventFriendsLabel setText:([self.currentInvitees count] != 1)?[NSString stringWithFormat:@"%lu friends are invited.", (unsigned long)[self.currentInvitees count]]:[NSString stringWithFormat:@"%lu friend is invited.", (unsigned long)[self.currentInvitees count]]];
    [self.chooseEventFriendsButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
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
    
  [self.delegate controllerDidFinish:self withEventID:self.currentEvent.objectID];
}

-(void)sendInvitationsForEventID:(NSString*)eventID {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [PFAnalytics trackEvent:@"eventCreation"];
    });
  [self.confirmEventButton setEnabled:NO];
  [self.confirmEventButton setAlpha:0.0f];
  if(![MFMessageComposeViewController canSendText]) {
    [SVProgressHUD showErrorWithStatus:@"can't send invitations"];
    [self.delegate controllerDidFinish:self withEventID:eventID];
    return;
  }

  if (self.currentInvitees.count == 0) {
      [self.delegate controllerDidFinish:self withEventID:eventID];
      return;
  }
  NSMutableArray *numbers = [NSMutableArray array];
  [self.currentInvitees enumerateObjectsUsingBlock:^(NSDictionary *contactDict, NSUInteger idx, BOOL *stop) {
    [numbers addObject:contactDict[@"phone"]];
  }];
    
  NSString *message = [NSString stringWithFormat:@"Psst...there's a party going on here: http://www.deeplink.me/afterparty.io/event.html?eventID=%@", eventID];
    if (![[self.currentEvent.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSString *addOn = [NSString stringWithFormat:@" and the password is %@", self.currentEvent.password];
        message = [NSString stringWithFormat:@"%@%@", message, addOn];
    }

  
  MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
  messageController.messageComposeDelegate = self;
  [messageController setRecipients:numbers];
  [messageController setBody:message];
  
  [self presentViewController:messageController animated:YES completion:nil];
}

-(void)changeEventButtonColor {
    [self.createEventButton setTitle:@"HANG ON, YOU'RE MISSING STUFF!!" forState:UIControlStateNormal];
    [self.createEventButton setBackgroundColor:[UIColor afterpartyCoralRedColor]];
}

-(void)confirmEventButtonTapped:(id)sender {
    if ([self.eventDescriptionView.text isEqualToString:@"Start typing here."]) {
        [SVProgressHUD showErrorWithStatus:@"needs a better description"];
        return;
    }
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
        self.currentEvent.objectID = object.objectId;
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

- (void)chooseEventTitleTapped:(id)sender {
    [self.eventNameField becomeFirstResponder];
}

- (void)choosePhotoFakeButtonTapped:(id)sender {
    [self choosePhotoButtonTapped:sender];
}

- (void)choosePhotoButtonTapped:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Go Back" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", nil];
    [actionSheet showInView:self.view];
}

- (void)chooseEventLocationButtonTapped:(id)sender {
    APFindVenueTableViewController *vc = [[APFindVenueTableViewController alloc] init];
    vc.delegate = self;
    vc.shouldShowDismissButton = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)chooseEventDateButtonTapped:(id)sender {
    [self performSegueWithIdentifier:kSetTimeSegue sender:nil];
}

- (void)chooseEventFriendsButtonTapped:(id)sender {
    APInviteFriendsViewController *vc = [[APInviteFriendsViewController alloc] initWithSelectedContacts:self.currentInvitees];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)chooseEventPasswordButtonTapped:(id)sender {
    [self performSegueWithIdentifier:kSetPasswordSegue sender:nil];
}

- (void)passwordSwitchChanged:(id)sender {
  [UIView animateWithDuration:0.3 animations:^{
    BOOL on = self.privateEventSwitch.on;
    [self.publicPasswordLabel setAlpha:on ? 1.0 : 0.0];
    [self.chooseEventPasswordButton setAlpha:on ? 0.0 : 1.0];
    [self.privatePasswordLabel setAlpha:on ? 0.0 : 1.0];
  }];
}

- (void)oneMoreThingButtonTapped:(id)sender {
    //check everything to see if its complete
    BOOL isComplete = YES;
    if ([[self.eventNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self.chooseEventTitleButton setImage:[UIImage imageNamed:@"button_redCancel"] forState:UIControlStateNormal];
        isComplete = NO;
    }
    if (!self.coverPhotoImageView.image) {
        self.coverPhotoImageView.backgroundColor = [UIColor afterpartyCoralRedColor];
        isComplete = NO;
    }
    if (!self.currentEvent.eventVenue) {
        [self.chooseEventLocationButton setImage:[UIImage imageNamed:@"button_redCancel"] forState:UIControlStateNormal];
        isComplete = NO;
    }
    if (!self.currentEvent.startDate || !self.currentEvent.endDate) {
        [self.chooseEventDateButton setImage:[UIImage imageNamed:@"button_redCancel"] forState:UIControlStateNormal];
        isComplete = NO;
    }
    if ([self.chooseEventFriendsButton.imageView.image isEqual:[UIImage imageNamed:@"button_plusblack"]]) {
        [self.chooseEventFriendsButton setImage:[UIImage imageNamed:@"button_redCancel"] forState:UIControlStateNormal];
        isComplete = NO;
    }
    if (!self.privateEventSwitch.isOn && ([self.currentEvent.password isEqualToString:@""] || !self.currentEvent.password)) {
        [self.chooseEventPasswordButton setImage:[UIImage imageNamed:@"button_redCancel"] forState:UIControlStateNormal];
        isComplete = NO;
    }
    
    if (!isComplete) {
        [self changeEventButtonColor];
    } else {
        self.currentEvent.eventImage = [self getScrollViewVisibleImage];
        self.currentEvent.eventName = self.eventNameField.text;
        if (self.privateEventSwitch.isOn) {
            self.currentEvent.password = @"";
        }
        [self fadeOutFirstLabels];
    }
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSetTimeSegue]) {
        APCreateEventTimeViewController *vc = (APCreateEventTimeViewController *)segue.destinationViewController;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:kSetPasswordSegue]) {
        APCreateEventPasswordViewController *vc = (APCreateEventPasswordViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark - APEventTimeDelegate Methods

- (void)updateForStartTime:(NSDate *)startTime andEndTime:(NSDate *)endTime {
    [self.currentEvent setStartDate:startTime];
    [self.currentEvent setEndDate:endTime];
    [self.chooseEventDateButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
    self.chooseEventDateLabel.text = [NSString stringWithFormat:@"%@ - %@", [APUtil formatDateForEventCreationScreen:self.currentEvent.startDate], [APUtil formatDateForEventCreationScreen:self.currentEvent.endDate]];
}

#pragma mark - PasswordDelegate Methods

- (void)controller:(APCreateEventPasswordViewController *)controller didUpdatePassword:(NSString *)password {
    self.currentEvent.password = password;
    NSString *passwordString = [NSString stringWithFormat:@"Your password is %@.", password];
    __block NSRange lastWordRange = NSMakeRange([passwordString length], 0);
    NSStringEnumerationOptions opts = NSStringEnumerationByWords | NSStringEnumerationReverse | NSStringEnumerationSubstringNotRequired;
    [passwordString enumerateSubstringsInRange:NSMakeRange(0, [passwordString length]) options:opts usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        lastWordRange = substringRange;
        *stop = YES;
    }];
    [self.chooseEventPasswordButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
    [self.privatePasswordLabel setText:passwordString afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor afterpartyCoralRedColor] range:lastWordRange];
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)[UIFont fontWithName:kBoldFont size:13.f] range:lastWordRange];
        return mutableAttributedString;
    }];
}

- (void)controller:(APCreateEventPasswordViewController *)controller didSavePassword:(NSString *)password {
    self.currentEvent.password = password;
    NSString *passwordString = [NSString stringWithFormat:@"Your password is %@.", password];
    __block NSRange lastWordRange = NSMakeRange([passwordString length], 0);
    NSStringEnumerationOptions opts = NSStringEnumerationByWords | NSStringEnumerationReverse | NSStringEnumerationSubstringNotRequired;
    [passwordString enumerateSubstringsInRange:NSMakeRange(0, [passwordString length]) options:opts usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        lastWordRange = substringRange;
        *stop = YES;
    }];
    [self.chooseEventPasswordButton setImage:[UIImage imageNamed:@"icon_checkgreen"] forState:UIControlStateNormal];
    [self.privatePasswordLabel setText:passwordString afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor afterpartyCoralRedColor] range:lastWordRange];
        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(id)[UIFont fontWithName:kBoldFont size:13.f] range:lastWordRange];
        return mutableAttributedString;
    }];
    [self.navigationController popToViewController:self animated:YES];
}

@end
