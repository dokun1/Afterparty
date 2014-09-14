//
//  APSearchEventDateLocationTableViewCell.m
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSearchEventDateLocationTableViewCell.h"
@interface APSearchEventDateLocationTableViewCell()
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventDateDayLabel;
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventDateMonthLabel;
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventDateHourLabel;
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventAmPMLabel;
@property (nonatomic, strong, readwrite)IBOutlet UILabel *eventAddressLabel;
@end

@implementation APSearchEventDateLocationTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    CGColorRef borderColor = [UIColor blackColor].CGColor;
    CGFloat borderWidth = 1.0;
    self.eventDateDayLabel.layer.borderColor = borderColor;
    self.eventDateDayLabel.layer.borderWidth = borderWidth;
    self.eventDateMonthLabel.layer.borderColor = borderColor;
    self.eventDateMonthLabel.layer.borderWidth = borderWidth;
    self.eventDateHourLabel.layer.borderColor = borderColor;
    self.eventDateHourLabel.layer.borderWidth = borderWidth;
    self.eventAmPMLabel.layer.borderColor = borderColor;
    self.eventAmPMLabel.layer.borderWidth = borderWidth;
    [self updateUI];
}

# pragma mark - External Methods

- (CGFloat)cellHeight {
    return 100;
}

- (void)updateUI {
    if (self.event.startDate == nil) {
        return;
    }
    NSDateFormatter *formater = [NSDateFormatter new];
    formater.dateFormat = @"MMM";
    formater.locale = [NSLocale currentLocale];
    formater.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    
    self.eventDateMonthLabel.text = [[formater stringFromDate:self.event.startDate]uppercaseString];
    formater.dateFormat = @"dd";
    self.eventDateDayLabel.text = [formater stringFromDate:self.event.startDate];
    formater.dateFormat = @"hh:mm";
    self.eventDateHourLabel.text = [formater stringFromDate:self.event.startDate];
    formater.dateFormat = @"a";
    self.eventAmPMLabel.text = [formater stringFromDate:self.event.startDate];
    self.eventAddressLabel.text = self.event.eventAddress;
}

+ (NSString *)cellIdentifier {
    return @"APSearchEventDateLocationTableViewCell";
}

+ (NSString *)nibFile {
    return @"APSearchEventDateLocationTableViewCell";
}

@end
