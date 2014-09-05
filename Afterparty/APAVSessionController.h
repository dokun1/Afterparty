//
//  APAVSessionController.h
//  Afterparty
//
//  Created by Andrei Popa on 03/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
// enum use for flash state
typedef NS_ENUM(NSInteger, FlashState) {
    kFlashUnknown,
    kFlashAuto,
    kFlashOn,
    kFlashOff
};
@protocol AVSessionControllerDelegate <NSObject>
- (void)sessionDidReceivedImageData:(NSData*)imageData forOrientation:(AVCaptureVideoOrientation)videoOrientation;
- (void)cameraDidSwitchedFlashStateToState:(FlashState)flashState;
@end

@interface APAVSessionController : NSObject

@property (nonatomic, strong, readonly) NSData *capturedImageData;
@property (nonatomic, assign, readonly) AVCaptureVideoOrientation videoOrientation;
@property (nonatomic, assign, readonly) FlashState flashState;
@property (nonatomic, weak, readwrite) id<AVSessionControllerDelegate> delegate;

- (instancetype)initWithPreviewView:(UIView*)previewView;
- (void)startSession;
- (void)stopSession;
- (void)takePicture;
- (void)switchCamera;
- (void)switchFlash;
@end
