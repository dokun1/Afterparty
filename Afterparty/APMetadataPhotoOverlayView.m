//
//  APMetadataPhotoOverlayView.m
//  Afterparty
//
//  Created by David Okun on 8/25/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APMetadataPhotoOverlayView.h"

@implementation APMetadataPhotoOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.usernameLabel = [[APLabel alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width - 20, 20)];
        [self.usernameLabel styleForType:LabelTypeStandard];
        self.usernameLabel.textColor = [UIColor whiteColor];
        self.usernameLabel.layer.shadowOffset = CGSizeMake(3, 3);
        self.usernameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.usernameLabel.clipsToBounds = YES;
        self.usernameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.usernameLabel];
        
        self.timestampLabel = [[APLabel alloc] initWithFrame:CGRectMake(10, 30, self.frame.size.width - 20, 20)];
        [self.timestampLabel styleForType:LabelTypeStandard];
        self.timestampLabel.textColor = [UIColor whiteColor];
        self.timestampLabel.layer.shadowOffset = CGSizeMake(3, 3);
        self.timestampLabel.clipsToBounds = YES;
        self.timestampLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.timestampLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.timestampLabel];
    }
    return self;
}

@end
