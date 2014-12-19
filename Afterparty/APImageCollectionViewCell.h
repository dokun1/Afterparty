//
//  APImageCollectionViewCell.h
//  Afterparty
//
//  Created by David Okun on 12/18/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APPhotoInfo.h"

@interface APImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) APPhotoInfo *photoInfo;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end
