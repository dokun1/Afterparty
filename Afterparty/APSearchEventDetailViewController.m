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

- (void)viewDidLoad
{
  [super viewDidLoad];
    
  [self setTitle:self.currentEvent.eventName];
  [self.eventCreatedByName styleForType:LabelTypeSearchDetailAttribute withText:self.currentEvent.createdByUsername];
  [self.eventCreatedByBlurb styleForType:LabelTypeSearchDetailAttribute withText:@"sample blurb"];
  [self.eventDescription styleForType:LabelTypeSearchDetailDescription withText:self.currentEvent.eventDescription];
  [self.eventStartDateLabel styleForType:LabelTypeSearchDetailAttribute withText:[APUtil formatDateForEventDetailScreen:self.currentEvent.startDate]];
  [self.eventFirstAddressString styleForType:LabelTypeSearchDetailAttribute withText:self.currentEvent.eventAddress];
  
  [self.eventJoinButton style];
    
  UIImage *image = [UIImage imageWithData:self.currentEvent.eventImageData];
  [self.eventImageView setImage:image];
}

- (IBAction)eventJoinTapped:(id)sender {
    if (self.currentEvent.password) {
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
            [UIAlertView showSimpleAlertWithTitle:@"Error" andMessage:@"Incorrect password. Please try again."];
        }
    }
}

-(void)confirmJoinEvent{
    [APUtil saveEventToMyEvents:self.currentEvent];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
