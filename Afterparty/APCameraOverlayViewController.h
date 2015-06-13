//
//  AfterpartyCameraOverlayViewController.h
//  Afterparty
//
//  Created by David Okun on 3/16/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APEvent.h"

@class APCameraOverlayViewController;

@protocol CaptureDelegate <NSObject>

- (void)capturedImage:(UIImage*)image;
- (void)cameraControllerDidCancel:(APCameraOverlayViewController*)controller;

@end

@interface APCameraOverlayViewController : UIViewController

@property (weak, nonatomic) id <CaptureDelegate> delegate;
@property (strong, nonatomic) NSDictionary *eventDict;

@end
