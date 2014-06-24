//
//  APTextField.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APTextField.h"

@implementation APTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)styleForLogin {
  self.font = [UIFont fontWithName:kRegularFont size:16.0f];
  self.backgroundColor = [UIColor whiteColor];
  self.borderStyle = UITextBorderStyleNone;
}

@end
