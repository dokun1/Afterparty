//
//  AfterpartyCameraOverlayViewController.h
//  Afterparty
//
//  Created by David Okun on 3/16/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CaptureDelegate <NSObject>

-(void)capturedImage:(UIImage*)image;

@end

@interface APCameraOverlayViewController : UIViewController

@property (weak, nonatomic) id <CaptureDelegate> delegate;

@end
