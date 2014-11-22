//
//  APSearchEventTableViewCell.m
//  Afterparty
//
//  Created by David Okun on 4/4/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APSearchEventTableViewCell.h"
#import "UIColor+APColor.h"
#import "APConstants.h"

@implementation APSearchEventTableViewCell

- (void)awakeFromNib
{
    // Initialization code
  [_eventNameLabel styleForType:LabelTypeTableViewCellTitle];
  [_countdownLabel styleForType:LabelTypeTableViewCellAttribute];
  [_userLabel styleForType:LabelTypeTableViewCellAttribute];
  _countdownLabel.textColor = [UIColor afterpartyOffWhiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCoverPhotoID:(NSString *)coverPhotoID {
    if (_coverPhotoID != coverPhotoID) {
        _coverPhotoID = coverPhotoID;
    }
    //init lazy loading for cover photo id and setting of the image
}

+ (CGFloat)suggestedCellHeight {
    return 170.f * ([UIScreen mainScreen].bounds.size.width/320);
}

@end
