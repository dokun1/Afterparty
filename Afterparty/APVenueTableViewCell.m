//
//  APVenueTableViewCell.m
//  Afterparty
//
//  Created by David Okun on 3/26/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APVenueTableViewCell.h"
#import "UIColor+APColor.h"

@interface APVenueTableViewCell ()

@end

@implementation APVenueTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self.venueName styleForType:LabelTypeStandard];
    [self.venueAddress styleForType:LabelTypeStandard];
    self.venueName.textColor = [UIColor afterpartyBlackColor];
    self.venueAddress.textColor = [UIColor afterpartyDarkGrayColor];
    self.venueName.textAlignment = NSTextAlignmentLeft;
    self.venueAddress.textAlignment = NSTextAlignmentLeft;
    
    self.venueIcon.layer.cornerRadius = 5.0f;
    self.venueIcon.layer.borderWidth = 0.5f;
    self.venueIcon.layer.borderColor = [UIColor afterpartyTealBlueColor].CGColor;
    self.venueIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.venueIcon.backgroundColor = [UIColor afterpartyTealBlueColor];
}

@end
