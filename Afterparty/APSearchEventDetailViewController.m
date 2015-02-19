//
//  APSearchEventDetailViewControllerNew.m
//  Afterparty
//
//  Created by David Okun on 4/4/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APSearchEventDetailViewController.h"
#import "APLabel.h"
#import "APButton.h"
#import "APUtil.h"
#import "UIAlertView+APAlert.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "APMyEventViewController.h"
#import "APConstants.h"
#import "APSearchEventTableViewCellFactory.h"
#import "APCreateEventViewController.h"

@import MessageUI;

@interface APSearchEventDetailViewController () <UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, CreateEventDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet APButton *eventJoinButton;
@property (weak, nonatomic) IBOutlet APLabel *eventAuthorNameOnTopImage;
@property (weak, nonatomic) IBOutlet APLabel *eventTitleOnTopImage;
@property (weak, nonatomic) IBOutlet UITableView *eventDetailsTableView;
@property (strong, nonatomic) APEvent *currentEvent;

@property (strong, nonatomic) APButton *editEventButton;

- (IBAction)eventJoinTapped:(id)sender;

@end

@implementation APSearchEventDetailViewController

-(id)initWithEvent:(APEvent*)event {
    if (self = [super init]) {
        self.currentEvent = event;
    }
    return self;
}

- (void)setCurrentEvent:(APEvent *)event {
    if (_currentEvent != event) {
      _currentEvent = event;
    }
}

- (void)viewDidLoad {
  [super viewDidLoad];
    
  [self setTitle:self.currentEvent.eventName];
  
  [self.eventJoinButton style];
    
  UIImage *image = [UIImage imageWithData:self.currentEvent.eventImageData];
  [self.eventImageView setImage:image];
    
    if ([self hasAlreadyAuthenticatedEvent]) {
        [self.eventJoinButton setTitle:@"GO!!" forState:UIControlStateNormal];
    }
    self.eventAuthorNameOnTopImage.text = [[self.currentEvent.createdByUsername uppercaseString] stringByAppendingString:@"'S"];
    self.eventTitleOnTopImage.text = [self.currentEvent.eventName uppercaseString];
    
    self.eventDetailsTableView.dataSource = self;
    self.eventDetailsTableView.delegate = self;
    self.eventDetailsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.eventDetailsTableView.bounces = NO;
    [self.eventDetailsTableView registerNib:[UINib nibWithNibName:[APSearchEventUserDetailsTableViewCell nibFile]
                                                           bundle:[NSBundle mainBundle]]
                                           forCellReuseIdentifier:[APSearchEventUserDetailsTableViewCell cellIdentifier]];
    [self.eventDetailsTableView registerNib:[UINib nibWithNibName:[APSearchEventDescriptionTableViewCell nibFile]
                                                           bundle:[NSBundle mainBundle]]
                     forCellReuseIdentifier:[APSearchEventDescriptionTableViewCell cellIdentifier]];
    [self.eventDetailsTableView registerNib:[UINib nibWithNibName:[APSearchEventDateLocationTableViewCell nibFile]
                                                           bundle:[NSBundle mainBundle]]
                                           forCellReuseIdentifier:[APSearchEventDateLocationTableViewCell cellIdentifier]];
    
    [self.eventTitleOnTopImage styleForType:LabelTypeTableViewCellTitle];
    [self.eventAuthorNameOnTopImage styleForType:LabelTypeTableViewCellAttribute];
    
    if ([self.currentEvent.createdByUsername isEqualToString:[PFUser currentUser].username]) {
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(editButtonTapped)];
        [self.navigationItem setRightBarButtonItem:editButton];
//        self.editEventButton = [[APButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
//        [self.editEventButton setTitle:@"EDIT EVENT" forState:UIControlStateNormal];
//        [self.editEventButton addTarget:self action:@selector(editEventTapped) forControlEvents:UIControlEventTouchUpInside];
//        [self.editEventButton style];
//        [self.view addSubview:self.editEventButton];
//        self.eventJoinButton.hidden = YES;
    }
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
}

- (void)awakeFromNib {
    self.eventTitleOnTopImage.text = @"title";
    self.eventAuthorNameOnTopImage.text = @"author";
}

- (IBAction)eventJoinTapped:(id)sender {
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

#pragma mark - UITableViewDataSource delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [APSearchEventTableViewCellFactory initializedCellForTableView:tableView
                                                              atIndexPath:indexPath
                                                                 andEvent:self.currentEvent];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [APSearchEventTableViewCellFactory appropriateHeightForIndexPath:indexPath andEvent:self.currentEvent];
}

@end
