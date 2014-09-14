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
#import "APSearchEventTableViewCells.h"

@interface APSearchEventDetailViewController () <UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet APLabel *eventCreatedByName;
@property (weak, nonatomic) IBOutlet APLabel *eventCreatedByBlurb;
@property (weak, nonatomic) IBOutlet APLabel *eventDescription;
@property (weak, nonatomic) IBOutlet APLabel *eventStartDateLabel;
@property (weak, nonatomic) IBOutlet APLabel *eventFirstAddressString;
@property (weak, nonatomic) IBOutlet APButton *eventJoinButton;
@property (weak, nonatomic) IBOutlet UILabel *eventAuthorNameOnTopImage;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleOnTopImage;
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
  [self.eventCreatedByName styleForType:LabelTypeSearchDetailAttribute withText:self.currentEvent.createdByUsername];
  [self.eventCreatedByBlurb styleForType:LabelTypeSearchDetailAttribute withText:self.currentEvent.eventUserBlurb];
  [self.eventDescription styleForType:LabelTypeSearchDetailDescription withText:self.currentEvent.eventDescription];
  [self.eventStartDateLabel styleForType:LabelTypeSearchDetailAttribute withText:[APUtil formatDateForEventDetailScreen:self.currentEvent.startDate]];
  [self.eventFirstAddressString styleForType:LabelTypeSearchDetailAttribute withText:self.currentEvent.eventAddress];
  
  [self.eventJoinButton style];
    
  UIImage *image = [UIImage imageWithData:self.currentEvent.eventImageData];
  [self.eventImageView setImage:image];
  [self.userAvatar setImageWithURL:[NSURL URLWithString:self.currentEvent.eventUserPhotoURL]];
    
    if ([self hasAlreadyAuthenticatedEvent]) {
        [self.eventJoinButton setTitle:@"GO!!" forState:UIControlStateNormal];
    }
    self.eventAuthorNameOnTopImage.text = [[self.currentEvent.createdByUsername uppercaseString] stringByAppendingString:@"'S"];
    self.eventTitleOnTopImage.text = [self.currentEvent.eventName uppercaseString];
    self.eventDetailsTableView.dataSource = self;
    self.eventDetailsTableView.delegate = self;
//    self.eventDetailsTableView.bounces = NO;
    self.eventDetailsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.eventDetailsTableView registerNib:[UINib nibWithNibName:[APSearchEventUserDetailsTableViewCell nibFile]
                                                           bundle:[NSBundle mainBundle]]
                                           forCellReuseIdentifier:[APSearchEventUserDetailsTableViewCell cellIdentifier]];
    [self.eventDetailsTableView registerNib:[UINib nibWithNibName:[APSearchEventDescriptionTableViewCell nibFile]
                                                           bundle:[NSBundle mainBundle]]
                     forCellReuseIdentifier:[APSearchEventDescriptionTableViewCell cellIdentifier]];
    [self.eventDetailsTableView registerNib:[UINib nibWithNibName:[APSearchEventDateLocationTableViewCell nibFile]
                                                           bundle:[NSBundle mainBundle]]
                                           forCellReuseIdentifier:[APSearchEventDateLocationTableViewCell cellIdentifier]];
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
    NSMutableArray *eventsArray = [APUtil getMyEventsArray];
    __block BOOL eventExists;
    [eventsArray enumerateObjectsUsingBlock:^(NSDictionary *eventDict, NSUInteger idx, BOOL *stop) {
        NSString *eventID = eventDict.allKeys.firstObject;
        if ([eventID isEqualToString:self.currentEvent.objectID]) {
            eventExists = YES;
            *stop = YES;
        }
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
  [APUtil saveEventToMyEvents:self.currentEvent];
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
    NSString *identifier = nil;
    APSearchEventBaseTableViewCell *cell = nil;
    switch (indexPath.row) {
        case 0:
            identifier = [APSearchEventUserDetailsTableViewCell cellIdentifier];
            cell = (APSearchEventUserDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[APSearchEventUserDetailsTableViewCell cellIdentifier]
                                                                                            forIndexPath:indexPath];
            break;
        case 1:
            identifier = [APSearchEventDescriptionTableViewCell cellIdentifier];
            cell = (APSearchEventUserDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[APSearchEventDescriptionTableViewCell cellIdentifier]
                                                                                            forIndexPath:indexPath];
            break;
        case 2:
            identifier = [APSearchEventDateLocationTableViewCell cellIdentifier];
            cell = (APSearchEventDateLocationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[APSearchEventDateLocationTableViewCell cellIdentifier]
                                                                                            forIndexPath:indexPath];
            break;
        default:
            identifier = [APSearchEventBaseTableViewCell cellIdentifier];
            cell = (APSearchEventBaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[APSearchEventBaseTableViewCell cellIdentifier]
                                                                                     forIndexPath:indexPath];
            break;
    }
    cell.event = self.currentEvent;
    [cell updateUI];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    switch (indexPath.row) {
        case 0:{
            APSearchEventUserDetailsTableViewCell *cell = [APSearchEventUserDetailsTableViewCell new];
            cell.event = self.currentEvent;
            cellHeight = [cell cellHeight];
            break;
        }
        case 1: {
            APSearchEventDescriptionTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:[APSearchEventDescriptionTableViewCell nibFile]
                                                                                        owner:self
                                                                                      options:nil]lastObject];
            cell.event = self.currentEvent;
            cellHeight = [cell cellHeight];
            break;
        }
        case 2:{
            APSearchEventDateLocationTableViewCell *cell = [APSearchEventDateLocationTableViewCell new];
            cell.event = self.currentEvent;
            cellHeight = [cell cellHeight];
            break;
        }
        default:{
            APSearchEventBaseTableViewCell *cell = [APSearchEventBaseTableViewCell new];
            cell.event = self.currentEvent;
            cellHeight = [cell cellHeight];
            break;
        }
    }
    return cellHeight;
}


@end
