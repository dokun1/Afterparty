//
//  APSearchEventDateLocationTableViewCell.m
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSearchEventDateLocationTableViewCell.h"
#import "APConstants.h"
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
    self.eventAmPMLabel.font = [UIFont fontWithName:kBoldFont size:18.f];
    self.eventDateHourLabel.font = [UIFont fontWithName:kBoldFont size:18.f];
    self.eventDateMonthLabel.font = [UIFont fontWithName:kBoldFont size:15.f];
    self.eventAddressLabel.font = [UIFont fontWithName:kBoldFont size:13.f];
    self.eventDateDayLabel.font = [UIFont fontWithName:kBoldFont size:18.f];
}

# pragma mark - External Methods

- (CGFloat)cellHeight {
    return 80;
}

+ (NSString *)cellIdentifier {
    return @"APSearchEventDateLocationTableViewCell";
}

+ (NSString *)nibFile {
    return @"APSearchEventDateLocationTableViewCell";
}

@end
