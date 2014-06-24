//
//  UIImage+APImage.h
//  Afterparty
//
//  Created by David Okun on 1/24/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (APImage)

- (UIImage*)resizedImageWithSize:(CGSize)size;
- (UIImage*)imageRotatedByRadians:(CGFloat)radians;
- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;


@end
