//
//  AfterpartyPhotoCell.m
//  Afterparty
//
//  Created by David Okun on 1/5/14.
//  Copyright (c) DMOS 2014. All rights reserved.
//

#import "APPhotoCell.h"
#import <UIKit+AFNetworking.h>

@interface APPhotoCell ()

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic) BOOL longPressed;

@end

@implementation APPhotoCell

@synthesize imageView = _imageView;

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        //init logic here
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
        self.longPressRecognizer.minimumPressDuration = 0.7;
        [self addGestureRecognizer:self.longPressRecognizer];
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
        self.imageView.image = _image;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil; //fixes the issue of the old image flashing in the wrong place
}

- (void)setPhotoInfo:(APPhotoInfo *)photoInfo {
  if (_photoInfo != photoInfo) {
    _photoInfo = photoInfo;
  }
  
  CGRect frame = self.imageView.frame;
  frame.size = [self sizePhotoForColumn:_photoInfo.size];
  self.imageView.frame = frame;
  self.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.layer.borderWidth = 1.0f;
  __weak APPhotoCell *weakcell = self;
  self.imageView.contentMode = UIViewContentModeScaleToFill;
  [self.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:photoInfo.thumbURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    [weakcell.downloadIndicator stopAnimating];
    weakcell.downloadIndicator.hidden = YES;
    CGRect frame = weakcell.imageView.frame;
    frame.size = [weakcell sizePhotoForColumn:weakcell.photoInfo.size];
    weakcell.imageView.frame = frame;
    weakcell.imageView.image = image;
  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
  }];
}

- (CGSize)sizePhotoForColumn:(CGSize)photoSize {
  CGFloat width = self.superview.frame.size.width / (self.superview.frame.size.width > 375.f ? 3 : 2);
  
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

- (void)longPressRecognized:(UILongPressGestureRecognizer *)recognizer {
    if (self.longPressed == YES) {
        return;
    }
    self.longPressed = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoLongPressedNotification" object:nil userInfo:@{@"photoID":self.photoInfo.refID}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetLongPressState) name:[NSString stringWithFormat:@"reset%@", self.photoInfo.refID] object:nil];
}

- (void)resetLongPressState {
    self.longPressed = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"reset%@", self.photoInfo.refID] object:nil];
}

- (void)setSelected:(BOOL)selected {
  if (!self.selectedView) {
    self.selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1000)];
    self.selectedView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.selectedView];
    UIImageView *checkImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_checkgreen"]];
      checkImage.frame = CGRectMake(10, 10, 25, 25);
    [self.selectedView addSubview:checkImage];
  }
  self.selectedView.alpha = selected ? 0.6f : 0.0f;
}


@end
