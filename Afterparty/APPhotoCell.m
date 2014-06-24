//
//  AfterpartyPhotoCell.m
//  Afterparty
//
//  Created by David Okun on 1/5/14.
//  Copyright (c) DMOS 2014. All rights reserved.
//

#import "APPhotoCell.h"

@implementation APPhotoCell

@synthesize imageView = _imageView;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //init logic here
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    const CGRect bounds = self.bounds;
    self.imageView.frame = bounds;
}

-(void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
    }
    self.imageView.image = _image;
}


@end
