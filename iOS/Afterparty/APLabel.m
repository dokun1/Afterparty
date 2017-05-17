//
//  APLabel.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APLabel.h"
#import "UIColor+APColor.h"
#import "APConstants.h"

@implementation APLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)styleForType:(LabelType)type {
  switch (type) {
    case LabelTypeTitle:
      [self setFont:[UIFont fontWithName:kBoldFont size:40.f]];
      self.textAlignment = NSTextAlignmentCenter;
      self.textColor = [UIColor afterpartyTealBlueColor];
      break;
    case LabelTypeHeading:
      [self setFont:[UIFont fontWithName:kRegularFont size:30.0f]];
      self.textAlignment = NSTextAlignmentCenter;
      break;
    case LabelTypeLoginHeading:
      [self setFont:[UIFont fontWithName:kBoldFont size:26.f]];
      self.textAlignment = NSTextAlignmentCenter;
      self.textColor = [UIColor afterpartyOffWhiteColor];
      break;
    case LabelTypeButtonDefault:
      [self setFont:[UIFont fontWithName:kRegularFont size:20.0f]];
      break;
    case LabelTypeStandard:
      self.textAlignment = NSTextAlignmentCenter;
      [self setFont:[UIFont fontWithName:kRegularFont size:18.0f]];
      break;
    case LabelTypeTableViewCellAttribute:
      [self setFont:[UIFont fontWithName:kRegularFont size:17.f]];
      self.textColor = [UIColor afterpartyOffWhiteColor];
      break;
    case LabelTypeTableViewCellTitle:
      [self setFont:[UIFont fontWithName:kBoldFont size:22.f]];
      self.textColor = [UIColor afterpartyOffWhiteColor];
      break;
    case LabelTypeSearchDetailTitle:
      [self setFont:[UIFont fontWithName:kBoldFont size:24.f]];
      self.textColor = [UIColor afterpartyBlackColor];
      break;
    case LabelTypeSearchDetailAttribute:
      [self setFont:[UIFont fontWithName:kRegularFont size:15.0f]];
      [self setTextColor:[UIColor afterpartyBlackColor]];
      break;
    case LabelTypeSearchDetailDescription:
      [self setFont:[UIFont fontWithName:kRegularFont size:11.f]];
      [self setTextColor:[UIColor afterpartyBlackColor]];
      break;
    case LabelTypeCreateLabel:
      [self setFont:[UIFont fontWithName:kRegularFont size:13.f]];
      [self setTextColor:[UIColor afterpartyBlackColor]];
      break;
    case LabelTypeFriendInvite:
      [self setFont:[UIFont fontWithName:kRegularFont size:16.f]];
      [self setTextColor:[UIColor afterpartyBlackColor]];
      break;
    case LabelTypeFriendHeader:
      [self setFont:[UIFont fontWithName:kBoldFont size:18.f]];
      [self setTextColor:[UIColor afterpartyBlackColor]];
    default:
      break;

  }
}

- (void)styleForType:(LabelType)type withText:(NSString *)text {
  self.text = text;
  [self styleForType:type];
}

@end
