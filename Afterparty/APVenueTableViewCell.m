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

@property (weak, nonatomic) IBOutlet UIView *innerContentView;

@end

@implementation APVenueTableViewCell

- (void)awakeFromNib
{
    // Initialization code
  [self.venueName styleForType:LabelTypeStandard];
  [self.venueAddress styleForType:LabelTypeStandard];
  [self.venueDistance styleForType:LabelTypeStandard];
  self.venueName.textColor = [UIColor whiteColor];
  self.venueAddress.textColor = [UIColor whiteColor];
  self.venueDistance.textColor = [UIColor whiteColor];
  self.venueName.textAlignment = NSTextAlignmentLeft;
  self.venueAddress.textAlignment = NSTextAlignmentLeft;
  self.venueDistance.textAlignment = NSTextAlignmentRight;
  self.innerContentView.backgroundColor = [UIColor afterpartyTealBlueColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
