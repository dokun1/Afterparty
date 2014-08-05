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

@interface APSearchEventDetailViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet APLabel *eventCreatedByName;
@property (weak, nonatomic) IBOutlet APLabel *eventCreatedByBlurb;
@property (weak, nonatomic) IBOutlet APLabel *eventDescription;
@property (weak, nonatomic) IBOutlet APLabel *eventStartDateLabel;
@property (weak, nonatomic) IBOutlet APLabel *eventFirstAddressString;
@property (weak, nonatomic) IBOutlet APButton *eventJoinButton;

@property (strong, nonatomic) APEvent *currentEvent;

- (IBAction)eventJoinTapped:(id)sender;
@end

@implementation APSearchEventDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
}

- (IBAction)eventJoinTapped:(id)sender {
    if (![[self.currentEvent.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Private Event" message:@"Please enter the event's password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        av.alertViewStyle = UIAlertViewStylePlainTextInput;
        av.tag = 1000;
        [av textFieldAtIndex:0].delegate = self;
        [av show];
        return;
    }else{
        [self confirmJoinEvent];
    }
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


@end
