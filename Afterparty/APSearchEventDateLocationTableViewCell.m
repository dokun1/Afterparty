//
//  APSearchEventDateLocationTableViewCell.m
//  Afterparty
//
//  Created by Andrei Popa on 13/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APSearchEventDateLocationTableViewCell.h"
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
