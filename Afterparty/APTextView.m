//
//  APTextView.m
//  Afterparty
//
//  Created by David Okun on 6/5/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APTextView.h"
#import "UIColor+APColor.h"

@implementation APTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)styleWithFontSize:(CGFloat)fontSize {
  self.backgroundColor = [UIColor whiteColor];
  self.editable = YES;
  self.font = [UIFont fontWithName:kRegularFont size:fontSize];
  self.textColor = [UIColor blackColor];
}

@end
