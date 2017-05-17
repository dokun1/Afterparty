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

@interface APSearchEventDetailViewController () <UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet APButton *eventJoinButton;
@property (weak, nonatomic) IBOutlet APLabel *eventAuthorNameOnTopImage;
@property (weak, nonatomic) IBOutlet APLabel *eventTitleOnTopImage;
@property (weak, nonatomic) IBOutlet UITableView *eventDetailsTableView;
@property (strong, nonatomic) APEvent *currentEvent;

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

- (void)viewDidLoad
{
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
    
//    self.eventTitleOnTopImage.font = [UIFont fontWithName:kBoldFont size:30.f];
//    self.eventAuthorNameOnTopImage.font = [UIFont fontWithName:kRegularFont size:20.f];
    [self.eventTitleOnTopImage styleForType:LabelTypeTableViewCellTitle];
    [self.eventAuthorNameOnTopImage styleForType:LabelTypeTableViewCellAttribute];
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
