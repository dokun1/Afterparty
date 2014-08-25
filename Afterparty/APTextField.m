//
//  APTextField.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APTextField.h"
#import "UIColor+APColor.h"
#import "APConstants.h"

CGFloat const APFextFielsLeftPadding = 10.0;

@implementation APTextField


- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.leftView) {
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                 self.bounds.origin.y,
                                                                 APFextFielsLeftPadding,
                                                                 self.bounds.size.height)];
        self.leftViewMode = UITextFieldViewModeAlways;
    }
}

- (void)styleForLogin {
  self.font = [UIFont fontWithName:kRegularFont size:16.0f];
  self.backgroundColor = [UIColor whiteColor];
  self.borderStyle = UITextBorderStyleNone;
}

- (void)styleForPasswordEntry {
  [self styleForLogin];
  self.textColor = [UIColor whiteColor];
  self.backgroundColor = [UIColor afterpartyTealBlueColor];
  self.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

@end
