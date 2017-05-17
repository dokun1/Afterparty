//
//  APCamPreviewView.m
//  Afterparty
//
//  Created by David Okun on 8/3/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation APCamPreviewView

+ (Class)layerClass {
  return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
  return [(AVCaptureVideoPreviewLayer*)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session {
  [(AVCaptureVideoPreviewLayer*)[self layer] setSession:session];
}

@end
