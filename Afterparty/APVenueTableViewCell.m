//
//  APVenueTableViewCell.m
//  Afterparty
//
//  Created by David Okun on 3/26/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APVenueTableViewCell.h"
#import "UIColor+APColor.h"

@implementation APVenueTableViewCell

- (void)awakeFromNib
{
    // Initialization code
  [self.venueName styleForType:LabelTypeStandard];
  [self.venueAddress styleForType:LabelTypeStandard];
  [self.venueDistance styleForType:LabelTypeStandard];
  
  self.backgroundColor = [UIColor afterpartyTealBlueColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
