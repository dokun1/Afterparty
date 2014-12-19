//
//  APImageCollectionViewCell.m
//  Afterparty
//
//  Created by David Okun on 12/18/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APImageCollectionViewCell.h"
#import <UIKit+AFNetworking.h>

@interface APImageCollectionViewCell () <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@end

@implementation APImageCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 5.0;
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)setPhotoInfo:(APPhotoInfo *)photoInfo {
    [self.imageView setImageWithURL:photoInfo.photoURL];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end
