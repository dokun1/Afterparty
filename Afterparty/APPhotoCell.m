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

- (void)setPhotoInfo:(APPhotoInfo *)photoInfo {
  if (_photoInfo != photoInfo) {
    _photoInfo = photoInfo;
  }
  
  CGRect frame = self.imageView.frame;
  frame.size = [self sizePhotoForColumn:_photoInfo.size];
  self.imageView.frame = frame;
  self.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.layer.borderWidth = 0.5f;
  [self.imageView setImageWithURL:photoInfo.thumbURL];
  __weak APPhotoCell *weakcell = self;
  [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:photoInfo.thumbURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    [weakcell.downloadIndicator stopAnimating];
    weakcell.downloadIndicator.hidden = YES;
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    NSLog(@"error download");
  }];
}

-(CGSize)sizePhotoForColumn:(CGSize)photoSize {
  CGFloat width = 160;
  
  CGSize newSize = CGSizeMake(width, 0);
  if (photoSize.width > width) {
    CGFloat divisor = photoSize.width / width;
    newSize.height = photoSize.height/ divisor;
  }else{
    CGFloat factor = width / photoSize.width;
    newSize.height = photoSize.height * factor;
  }
  
  return newSize;
}


@end
