//
//  UIImage+APImage.h
//  Afterparty
//
//  Created by David Okun on 1/24/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "APEvent.h"
@import ImageIO;

@interface UIImage (APImage)

- (UIImage *)resizedImageWithSize:(CGSize)size;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)imageSquareCrop:(UIImage*)original;
- (UIImage *)rotate:(UIImageOrientation)orientation;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (BOOL)checkImageOKForSubmissionToEvent:(NSDictionary *)eventDict metadataDictionary:(NSDictionary *)metadataDictionary;

@end
