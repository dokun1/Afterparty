//
//  APLabel.h
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

typedef NS_ENUM(int, LabelType) {
  LabelTypeTitle,
  LabelTypeTableViewCellTitle,
  LabelTypeTableViewCellAttribute,
  LabelTypeButtonDefault,
  LabelTypeStandard,
  LabelTypeHeading,
  LabelTypeLoginHeading,
  LabelTypeSearchDetailTitle,
  LabelTypeSearchDetailAttribute,
  LabelTypeSearchDetailDescription,
  LabelTypeCreateLabel,
  LabelTypeFriendInvite,
  LabelTypeFriendHeader
};

@interface APLabel : UILabel

- (void)styleForType:(LabelType)type;
- (void)styleForType:(LabelType)type withText:(NSString*)text;

@end
