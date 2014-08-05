//
//  APCamPreviewView.h
//  Afterparty
//
//  Created by David Okun on 8/3/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface APCamPreviewView : UIView

@property (strong, nonatomic) AVCaptureSession *session;

@end
