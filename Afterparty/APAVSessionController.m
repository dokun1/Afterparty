//
//  APAVSessionController.m
//  Afterparty
//
//  Created by Andrei Popa on 03/09/2014.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APAVSessionController.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+APImage.h"

@class CIDetector;

#pragma mark -- Internal Helper Stuff
// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface APAVSessionController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;
// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;
@property (nonatomic) FlashState flashState;
@property (nonatomic, assign, readwrite) BOOL isUsingFrontFacingCamera;
@property (nonatomic) UIView *previewView;
@property (nonatomic) UIView *flashView;
// external properties
@property (nonatomic, strong, readwrite) NSData *capturedImageData;
@property (nonatomic, assign, readwrite) AVCaptureVideoOrientation videoOrientation;

@end

@implementation APAVSessionController

- (instancetype)initWithPreviewView:(UIView *)previewView {
    self = [super init];
    if (self) {
        _previewView = previewView;
        _isUsingFrontFacingCamera = NO;
        _flashState = kFlashUnknown;
        [self setupSession];
    }
    return self;
}

# pragma mark - Helper Methods
- (BOOL)isSessionRunningAndDeviceAuthorized {
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized {
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)setupSession {
	// Create the AVCaptureSession
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	[self setSession:session];
	// Setup the preview view
	[(AVCaptureVideoPreviewLayer *)self.previewView.layer setSession:session];
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
	// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
	// Why not do all of this on the main queue?
	// -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
	
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    // not sure if the next line is "legal" but it seems to fix the main bug: the preview from camera is not loading
    dispatch_set_target_queue(sessionQueue,dispatch_get_main_queue());
	[self setSessionQueue:sessionQueue];
	
	dispatch_async(sessionQueue, ^{
		[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
		
		NSError *error = nil;
		
		AVCaptureDevice *videoDevice = [[self class] deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		
		if ([session canAddInput:videoDeviceInput]) {
			[session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
        }
		
		AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
		AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
		
		
		if ([session canAddInput:audioDeviceInput]) {
			[session addInput:audioDeviceInput];
		}
		
		AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
		if ([session canAddOutput:movieFileOutput]) {
			[session addOutput:movieFileOutput];
			AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
			if ([connection isVideoStabilizationSupported])
                [connection setPreferredVideoStabilizationMode:AVCaptureVideoStabilizationModeAuto];
			[self setMovieFileOutput:movieFileOutput];
		}
		
		AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		if ([session canAddOutput:stillImageOutput]) {
			[stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
			[session addOutput:stillImageOutput];
			[self setStillImageOutput:stillImageOutput];
		}
        [self switchFlash]; // this will set the camera flash to auto
	});
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == CapturingStillImageContext) {
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		if (isCapturingStillImage) {
			[self runStillImageCaptureAnimation];
		}
	} else if (context == SessionRunningAndDeviceAuthorizedContext) {
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning) {
				// TODO: update UI if necessary
			} else {
                // TODO: update UI if necessary
			}
		});
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices) {
		if ([device position] == position) {
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

- (void)runStillImageCaptureAnimation {
	dispatch_async(dispatch_get_main_queue(), ^{
        self.flashView = [[UIView alloc] initWithFrame:self.previewView.frame];
        self.flashView.backgroundColor = [UIColor whiteColor];
        self.flashView.alpha = 1.0;
        [self.previewView.superview.window addSubview:self.flashView];
		[UIView animateWithDuration:0.75
                         animations:^{
                             self.flashView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [self.flashView removeFromSuperview];
                         }];
	});
}

- (void)checkDeviceAuthorizationStatus {
	NSString *mediaType = AVMediaTypeVideo;
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted) {
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		} else {
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"Camera Error"
											message:@"Afterparty doesn't have permission to use the Camera, please change your privacy settings."
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

# pragma mark - External Methods
- (void)startSession {
	dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
		[self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
		
		__weak APAVSessionController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			APAVSessionController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[[strongSelf session] startRunning];
			});
		}]];
		[[self session] startRunning];
	});
}

- (void)stopSession {
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
		[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
	});
}

- (void)switchCamera {
    APAVSessionController *__weak weakSelf = self;
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        if (weakSelf.isUsingFrontFacingCamera) {
            preferredPosition = AVCaptureDevicePositionBack;
        } else {
            preferredPosition = AVCaptureDevicePositionFront;
        }
        weakSelf.isUsingFrontFacingCamera = !weakSelf.isUsingFrontFacingCamera;
		AVCaptureDevice *videoDevice = [[self class] deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
		[[self session] beginConfiguration];
		[[self session] removeInput:[self videoDeviceInput]];
		if ([[self session] canAddInput:videoDeviceInput]) {
			[[self session] addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		} else {
			[[self session] addInput:[self videoDeviceInput]];
		}
		[[self session] commitConfiguration];
		dispatch_async(dispatch_get_main_queue(), ^{
            // TODO: update UI telling that the camera is switched
		});
	});
}

- (void)takePicture {
    APAVSessionController *__weak weakSelf = self;
	dispatch_async([self sessionQueue], ^{
		// Update the orientation on the still image output video connection before capturing.
		[[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
		// Capture a still image.
		[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
			if (imageDataSampleBuffer){
				weakSelf.capturedImageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
				UIImage *image = [[UIImage alloc] initWithData:weakSelf.capturedImageData];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(sessionDidReceivedImageData:forOrientation:)]) {
                    [weakSelf.delegate sessionDidReceivedImageData:weakSelf.capturedImageData
                                                    forOrientation:(AVCaptureVideoOrientation)[image imageOrientation]];
                }
			}
		}];
	});
}

- (void)switchFlash {
    AVCaptureDevice *currentCamera;
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        if (self.isUsingFrontFacingCamera && [device position] == AVCaptureDevicePositionFront) {
            currentCamera = device;
            break;
        } else if (!self.isUsingFrontFacingCamera && [device position] == AVCaptureDevicePositionBack) {
            currentCamera = device;
            break;
        } else {
            currentCamera = nil;
        }
    }
    if (currentCamera) {
        NSError *error = nil;
        [currentCamera lockForConfiguration:&error];
        if (!error) {
            if (self.isUsingFrontFacingCamera) {
                switch (self.flashState) {
                    case kFlashAuto:
                        self.flashState = kFlashOff;
                        [currentCamera setFlashMode:AVCaptureFlashModeOff];
                        break;
                    case kFlashOn:
                        self.flashState = kFlashOff;
                        [currentCamera setFlashMode:AVCaptureFlashModeOff];
                        break;
                    case kFlashOff:
                    default:
                        [currentCamera setFlashMode:AVCaptureFlashModeAuto];
                        self.flashState = kFlashAuto;
                        break;
                }
            } else {
                switch (self.flashState) {
                    case kFlashAuto:
                        [currentCamera setFlashMode:AVCaptureFlashModeOn];
                        self.flashState = kFlashOn;
                        break;
                    case kFlashOn:
                        self.flashState = kFlashOff;
                        [currentCamera setFlashMode:AVCaptureFlashModeOff];
                        break;
                    case kFlashOff:
                        [currentCamera setFlashMode:AVCaptureFlashModeAuto];
                        self.flashState = kFlashAuto;
                        break;
                    default:
                        [currentCamera setFlashMode:AVCaptureFlashModeAuto];
                        self.flashState = kFlashAuto;
                        break;
                }
            }
        }
        [currentCamera unlockForConfiguration];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraDidSwitchedFlashStateToState:)]) {
        [self.delegate cameraDidSwitchedFlashStateToState:self.flashState];
    }
}


@end
