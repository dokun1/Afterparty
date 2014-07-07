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

@implementation APTextField

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
