//
//  APPhotoCell
//  Afterparty
//
//  Created by David Okun on 1/1/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPhotoInfo.h"

@interface APPhotoCell : UICollectionViewCell  {
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *downloadIndicator;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic, strong) APPhotoInfo *photoInfo;

- (void)setPhotoInfo:(APPhotoInfo *)photoInfo;

@end
