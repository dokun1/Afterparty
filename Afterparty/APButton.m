//
//  APButton.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APButton.h"
#import "UIColor+APColor.h"

@implementation APButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)style {
  self.backgroundColor = [UIColor afterpartyTealBlueColor];
  [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [self setTitleColor:[UIColor colorWithHexString:@"2ad8db" withAlpha:1.0f] forState:UIControlStateHighlighted];
  
  [self.titleLabel setFont:[UIFont fontWithName:kRegularFont size:13.f]];
}

@end
