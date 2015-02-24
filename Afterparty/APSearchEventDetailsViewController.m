//
//  APSearchEventDetailsViewController.m
//  Afterparty
//
//  Created by David Okun on 2/19/15.
//  Copyright (c) 2015 Afterparty. All rights reserved.
//

#import "APSearchEventDetailsViewController.h"
#import "APLabel.h"
#import "APButton.h"
#import "APTextView.h"
#import "APUtil.h"
#import "UIAlertView+APAlert.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "APMyEventViewController.h"
#import "APConstants.h"
#import "APSearchEventTableViewCellFactory.h"
#import "APCreateEventViewController.h"
#import "APEventDateAddressView.h"
#import <UIKit+AFNetworking.h>

@import MessageUI;

@interface APSearchEventDetailsViewController () <UIAlertViewDelegate, UITextFieldDelegate, CreateEventDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, assign) CGFloat widthFactor;
@property (nonatomic, strong) UIImageView *eventImageView;
@property (nonatomic, strong) APLabel *eventAuthorLabel;
@property (nonatomic, strong) APLabel *eventNameLabel;
@property (nonatomic, strong) UIImageView *userAvatarImageView;
@property (nonatomic, strong) APLabel *usernameLabel;
@property (nonatomic, strong) APLabel *usernameBlurbLabel;
@property (nonatomic, strong) APTextView *eventDescriptionView;
@property (nonatomic, strong) APEventDateAddressView *dateAddressView;
@property (nonatomic, strong) APButton *goToEventButton;

@property (nonatomic, strong) UIScrollView *contentScrollView;

@end

@implementation APSearchEventDetailsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //init logic
    }
    return self;
}

- (void)setCurrentEvent:(APEvent *)currentEvent {
    if (_currentEvent != currentEvent) {
        _currentEvent = currentEvent;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.currentEvent.eventName;
    self.widthFactor = self.view.frame.size.width / 320;
    [self drawCustomUI];
    
    if ([self.currentEvent.createdByUsername isEqualToString:[PFUser currentUser].username]) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(editButtonTapped)];
        [self.navigationItem setRightBarButtonItem:editButton];
    }
}

- (void)drawCustomUI {
    CGFloat height = 0;
    
    self.eventImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, height, 320 * self.widthFactor, 170 * self.widthFactor)];
    self.eventImageView.backgroundColor = [UIColor afterpartyTealBlueColor];
    [self.view addSubview:self.eventImageView];
    
    UIImage *image = [UIImage imageWithData:self.currentEvent.eventImageData];
    [self.eventImageView setImage:image];
    
    height += self.eventImageView.frame.size.height + 10;
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, height - 10, self.view.frame.size.width, self.view.frame.size.height - (240 + self.navigationController.navigationBar.frame.size.height))];
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentScrollView];
    
    self.eventAuthorLabel = [[APLabel alloc] initWithFrame:CGRectMake(20, 7, self.view.frame.size.width - 40, 25)];
    [self.eventAuthorLabel styleForType:LabelTypeTableViewCellAttribute withText:[[NSString stringWithFormat:@"%@'s", self.currentEvent.createdByUsername] uppercaseString]];
    [self.eventImageView addSubview:self.eventAuthorLabel];
    
    self.eventNameLabel = [[APLabel alloc] initWithFrame:CGRectMake(20, 27, self.view.frame.size.width - 40, 35)];
    [self.eventNameLabel styleForType:LabelTypeTableViewCellTitle withText:self.currentEvent.eventName];
    [self.eventImageView addSubview:self.eventNameLabel];
    
    CGFloat scrollViewContentHeight = 10;
    
    self.userAvatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, scrollViewContentHeight, 80, 80)];
    [self.userAvatarImageView setImage:[UIImage imageNamed:@"user_male3-512"]];
    [self.userAvatarImageView setImageWithURL:[NSURL URLWithString:self.currentEvent.eventUserPhotoURL]];
    [self.contentScrollView addSubview:self.userAvatarImageView];
    
    self.usernameLabel = [[APLabel alloc] initWithFrame:CGRectMake(100, scrollViewContentHeight + 15, self.view.frame.size.width - 120, 28)];
    [self.usernameLabel styleForType:LabelTypeNearbyUsername withText:self.currentEvent.createdByUsername];
    [self.contentScrollView addSubview:self.usernameLabel];
    
    self.usernameBlurbLabel = [[APLabel alloc] initWithFrame:CGRectMake(100, scrollViewContentHeight + 51, self.view.frame.size.width - 120, 14)];
    [self.usernameBlurbLabel styleForType:LabelTypeNearbyBlurb withText:self.currentEvent.eventUserBlurb];
    [self.contentScrollView addSubview:self.usernameBlurbLabel];
    
    height += 100;
    scrollViewContentHeight += 100;
    
    self.eventDescriptionView = [[APTextView alloc] init];
    self.eventDescriptionView.text = self.currentEvent.eventDescription;
    [self.eventDescriptionView styleWithFontSize:12.f];
    
    CGFloat cellHeight = 0;
    if (self.eventDescriptionView.text.length) {
        CGRect textNecessaryRect = [self.eventDescriptionView.text boundingRectWithSize: CGSizeMake(self.eventDescriptionView.bounds.size.width, NSUIntegerMax) options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:kRegularFont size:14.0]} context: nil];
        cellHeight = textNecessaryRect.size.height + 10.0;
    }
    self.eventDescriptionView.frame = CGRectMake(10, scrollViewContentHeight, self.view.frame.size.width - 20, cellHeight);
    
    [self.contentScrollView addSubview:self.eventDescriptionView];
    
    height += self.eventDescriptionView.frame.size.height;
    scrollViewContentHeight += self.eventDescriptionView.frame.size.height;
    
    self.dateAddressView = [[APEventDateAddressView alloc] initWithDate:self.currentEvent.startDate andAddress:self.currentEvent.eventAddress];
    self.dateAddressView.frame = CGRectMake(0, scrollViewContentHeight, self.view.frame.size.width, 80);
    [self.contentScrollView addSubview:self.dateAddressView];
    
    height += self.dateAddressView.frame.size.height + 10;
    scrollViewContentHeight += self.dateAddressView.frame.size.height + 10;
    
    self.contentScrollView.contentSize = CGSizeMake(self.view.frame.size.width, scrollViewContentHeight);
    
    self.goToEventButton = [[APButton alloc] initWithFrame:CGRectMake(-1, self.view.frame.size.height - 70 - self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width + 2, 50)];
    [self.goToEventButton setTitle:@"GO!!" forState:UIControlStateNormal];
    [self.goToEventButton style];
    [self.goToEventButton addTarget:self action:@selector(eventJoinTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.goToEventButton];
}

#pragma mark - EditEventActions

- (void)editButtonTapped {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Event", @"Share Event", nil];
    [actionSheet showInView:self.view.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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

- (void)shareEventSelected {
    NSString *message = [NSString stringWithFormat:@"Psst...there's a party going on here: http://www.deeplink.me/afterparty.io/event.html?eventID=%@", self.currentEvent.objectID];
    if (![[self.currentEvent.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        NSString *addOn = [NSString stringWithFormat:@" and the password is %@", self.currentEvent.password];
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
    [self performSegueWithIdentifier:kEditEventSegue sender:self.currentEvent];
}

- (void)eventJoinTapped {
    if (![[self.currentEvent.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        if (![self hasAlreadyAuthenticatedEvent]) {
            UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Private Event" message:@"Please enter the event's password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            av.alertViewStyle = UIAlertViewStylePlainTextInput;
            av.tag = 1000;
            [av textFieldAtIndex:0].delegate = self;
            [av show];
            return;
        }
    }
    [self confirmJoinEvent];
}

- (BOOL)hasAlreadyAuthenticatedEvent {
    //an event gets added to their array when they get to the page, meaning theyve already entered the password once.
    __block BOOL eventExists;
    [APUtil getMyEventsArrayWithSuccess:^(NSMutableArray *eventsArray) {
        [eventsArray enumerateObjectsUsingBlock:^(NSDictionary *eventDict, NSUInteger idx, BOOL *stop) {
            NSString *eventID = eventDict.allKeys.firstObject;
            if ([eventID isEqualToString:self.currentEvent.objectID]) {
                eventExists = YES;
                *stop = YES;
            }
        }];
    }];
    return eventExists;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000 && buttonIndex != 0) {
        NSString *password = [alertView textFieldAtIndex:0].text;
        if ([password isEqualToString:self.currentEvent.password]) {
            [self confirmJoinEvent];
        }else{
            [SVProgressHUD showErrorWithStatus:@"incorrect password"];
        }
    }
}

-(void)confirmJoinEvent{
    [PFAnalytics trackEvent:@"eventJoined" dimensions:@{@"userID":[PFUser currentUser].objectId}];
    [APUtil saveEventToMyEvents:self.currentEvent];
    NSMutableArray *attendees = [self.currentEvent.attendees mutableCopy];
    if (!attendees) {
        attendees = [NSMutableArray array];
    }
    if (![attendees containsObject:[PFUser currentUser]]) {
        [attendees addObject:[PFUser currentUser]];
        self.currentEvent.attendees = attendees;
        [[APConnectionManager sharedManager] updateEventForNewAttendee:self.currentEvent success:^() {
            
        } failure:^(NSError *error) {
            
        }];
    }
    NSDictionary *eventInfo = @{@"deleteDate": [_currentEvent deleteDate],
                                @"endDate" : [_currentEvent endDate],
                                @"startDate" : [_currentEvent startDate],
                                @"eventName": [_currentEvent eventName],
                                @"eventLatitude": @([_currentEvent location].latitude),
                                @"eventLongitude": @([_currentEvent location].longitude),
                                @"createdByUsername": [_currentEvent createdByUsername],
                                @"eventImageData": [_currentEvent eventImageData]};
    NSDictionary *eventDict = @{[_currentEvent objectID]: eventInfo};
    [self performSegueWithIdentifier:@"EventDetailsGoToEventSegue" sender:eventDict];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:kNearbyEventGoToSegue]) {
        APMyEventViewController *vc = (APMyEventViewController*)segue.destinationViewController;
        vc.eventDict = sender;
        vc.hidesBottomBarWhenPushed = YES;
    } else if ([segue.identifier isEqualToString:kEditEventSegue]) {
        APCreateEventViewController *editVC = (APCreateEventViewController *)segue.destinationViewController;
        editVC.delegate = self;
        [editVC setEventForEditing:(APEvent *)sender];
    }
}
@end
