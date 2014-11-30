//
//  UIImage+APImage.m
//  Afterparty
//
//  Created by David Okun on 1/24/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "UIImage+APImage.h"

CGFloat degreesToRadians(CGFloat degrees) {
    return degrees * M_PI / 180;
};

CGFloat radiansToDegrees(CGFloat radians) {
    return radians * 180/M_PI;
};

@implementation UIImage (APImage)

- (UIImage*) resizedImageWithSize:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
	
	[self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
	
	// An autoreleased image
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return newImage;
}

- (UIImage *)imageRotatedByRadians:(CGFloat)radians {
    return [self imageRotatedByDegrees:radiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees {
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    CGContextRotateCTM(bitmap, degreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)imageSquareCrop:(UIImage *)original {
    UIImage *croppedImage = nil;
    
    float originalWidth  = original.size.width;
    float originalHeight = original.size.height;
    
    float edge = fminf(originalWidth, originalHeight);
    
    float posX = (originalWidth   - edge) / 2.0f;
    float posY = (originalHeight  - edge) / 2.0f;
    
    CGRect cropSquare = CGRectZero;
    
    // If orientation indicates a change to portrait.
    if(original.imageOrientation == UIImageOrientationLeft || original.imageOrientation == UIImageOrientationRight) {
        cropSquare = CGRectMake(posY, posX, edge, edge);
    } else {
        cropSquare = CGRectMake(posX, posY, edge, edge);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([original CGImage], cropSquare);
    croppedImage = [UIImage imageWithCGImage:imageRef scale:original.scale orientation:original.imageOrientation];
    CGImageRelease(imageRef);
    
    return [UIImage imageWithImage:croppedImage scaledToSize:CGSizeMake(50, 50)];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
