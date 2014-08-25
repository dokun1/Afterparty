//
//  AfterpartyCameraOverlayViewController.m
//  Afterparty
//
//  Created by David Okun on 3/16/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APCameraOverlayViewController.h"
#import "APImagePreviewViewController.h"
#import "UIImage+APImage.h"
#import "APButton.h"
#import "APCamPreviewView.h"
#import "UIView+APViewAnimations.h"

@import AVFoundation;

typedef NS_ENUM(NSInteger, FlashState) {
    kFlashAuto,
    kFlashOn,
    kFlashOff
};

@interface APCameraOverlayViewController () <PreviewDelegate>

@property (assign, nonatomic) CGFloat                   screenHeight;
@property (assign, nonatomic) CGFloat                   buttonHeight;

@property (strong, nonatomic) UIButton                  *cameraFlipButton;
@property (strong, nonatomic) UIButton                  *flashButton;
@property (strong, nonatomic) UIButton                  *cancelButton;
@property (assign, nonatomic) FlashState                flashState;

@property (weak, nonatomic) IBOutlet APButton           *cameraButton;
@property (weak, nonatomic) IBOutlet UIView             *imagePreview;
@property (weak, nonatomic) IBOutlet APCamPreviewView   *viewFinderView;


@property (strong, nonatomic) AVCaptureSession          *session;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureDeviceInput      *videoDeviceInput;
@property (strong, nonatomic) dispatch_queue_t          sessionQueue;

@property (assign, nonatomic) BOOL                      frontCamera;
@property (assign, nonatomic) BOOL                      haveImage;


- (void)cameraFlipButtonTapped;
- (void)cameraFlashButtonTapped;
- (void)cancelButtonTapped;
- (IBAction)cameraButtonTapped:(id)sender;


@end

@implementation APCameraOverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.screenHeight = screenRect.size.height;
    self.buttonHeight = self.screenHeight - 93;
    
    [self.navigationController setNavigationBarHidden:YES];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.cameraFlipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cameraFlipButton setBackgroundColor:[UIColor clearColor]];
    [self.cameraFlipButton setImage:[UIImage imageNamed:@"button_frontfacingcamera.png"] forState:UIControlStateNormal];
    [self.cameraFlipButton setFrame:CGRectMake(125, self.buttonHeight, 40, 40)];
    [self.cameraFlipButton addTarget:self action:@selector(cameraFlipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.cameraFlipButton belowSubview:self.cameraButton];
    
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashButton setBackgroundColor:[UIColor clearColor]];
    [self.flashButton setImage:[UIImage imageNamed:@"button_flashauto.png"] forState:UIControlStateNormal];
    [self.flashButton setFrame:CGRectMake(155, self.buttonHeight, 40, 40)];
    [self.flashButton addTarget:self action:@selector(cameraFlashButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.flashButton belowSubview:self.cameraButton];
  
  self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.cancelButton setBackgroundColor:[UIColor clearColor]];
  [self.cancelButton setImage:[UIImage imageNamed:@"button_redCancel"] forState:UIControlStateNormal];
  [self.cancelButton setFrame:CGRectMake(130, self.buttonHeight, 40, 40)];
  [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  [self.view insertSubview:self.cancelButton belowSubview:self.cameraButton];
  
  [self initializeCameraBetter];
  
  [self.cameraFlipButton afterparty_translateToPoint:CGPointMake(60, self.buttonHeight + 20) expanding:YES delay:0.1 withCompletion:nil];
  [self.flashButton afterparty_translateToPoint:CGPointMake(260, self.buttonHeight + 20) expanding:YES delay:0.2 withCompletion:nil];
  [self.cancelButton afterparty_translateToPoint:CGPointMake(30, 30) expanding:YES delay:0.3 withCompletion:nil];

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.flashState = kFlashAuto;
}

- (void)initializeCameraBetter {
  self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
  self.session = [[AVCaptureSession alloc] init];
  
  [[self viewFinderView] setSession:self.session];
  
  [self checkDeviceAuthorizationStatus];
  dispatch_async(self.sessionQueue, ^{
    NSError *error = nil;

    AVCaptureDevice *videoDevice = [APCameraOverlayViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:(self.frontCamera)? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
    self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (error) {
      NSLog(@"%@", error);
    }
    
    if ([self.session canAddInput:self.videoDeviceInput]) {
      [self.session addInput:self.videoDeviceInput];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      [[(AVCaptureVideoPreviewLayer *)[[self viewFinderView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
    });
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([self.session canAddOutput:self.stillImageOutput]) {
      [self.stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
      [self.session addOutput:self.stillImageOutput];
    }

    self.session.sessionPreset = IS_IPHONE_5 ? AVCaptureSessionPresetHigh : AVCaptureSessionPresetPhoto; //this fixes stretching for legacy iphones
      
    [self.session startRunning];
  });
}

- (void)checkDeviceAuthorizationStatus {
	[AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
		if (!granted) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"Oops"
                                    message:@"Change your privacy settings - Afterparty can't access your camera."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
			});
		}
	}];
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

-(void)cameraFlashButtonTapped {
    AVCaptureDevice *currentCamera;
    for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
        if (self.frontCamera && [device position] == AVCaptureDevicePositionFront) {
            currentCamera = device;
            break;
        }else if (!self.frontCamera && [device position] == AVCaptureDevicePositionBack) {
            currentCamera = device;
            break;
        }else{
            currentCamera = nil;
        }
    }
    if (currentCamera) {
        NSError *error = nil;
        [currentCamera lockForConfiguration:&error];
        if (!error) {
            if (self.frontCamera) {
                NSLog(@"front camera flash change");
                switch (self.flashState) {
                    case kFlashAuto:
                        NSLog(@"auto changing to off");
                        [self.flashButton setImage:[UIImage imageNamed:@"button_flashoff.png"] forState:UIControlStateNormal];
                        self.flashState = kFlashOff;
                        [currentCamera setFlashMode:AVCaptureFlashModeOff];
                        break;
                    case kFlashOn:
                        NSLog(@"on changing to off");
                        [self.flashButton setImage:[UIImage imageNamed:@"button_flashoff.png"] forState:UIControlStateNormal];
                        self.flashState = kFlashOff;
                        [currentCamera setFlashMode:AVCaptureFlashModeOff];
                        break;
                    case kFlashOff:
                        NSLog(@"off staying at off");
                    default:
                        break;
                }
            }else{
                NSLog(@"back camera flash change");
                switch (self.flashState) {
                    case kFlashAuto:
                        NSLog(@"auto changing to on");
                        [currentCamera setFlashMode:AVCaptureFlashModeOn];
                        [self.flashButton setImage:[UIImage imageNamed:@"button_flashon.png"] forState:UIControlStateNormal];
                        self.flashState = kFlashOn;
                        break;
                    case kFlashOn:
                        NSLog(@"on changing to off");
                        [self.flashButton setImage:[UIImage imageNamed:@"button_flashoff.png"] forState:UIControlStateNormal];
                        self.flashState = kFlashOff;
                        [currentCamera setFlashMode:AVCaptureFlashModeOff];
                        break;
                    case kFlashOff:
                        NSLog(@"off changing to auto");
                        [currentCamera setFlashMode:AVCaptureFlashModeAuto];
                        [self.flashButton setImage:[UIImage imageNamed:@"button_flashauto.png"] forState:UIControlStateNormal];
                        self.flashState = kFlashAuto;
                        break;
                    default:
                        NSLog(@"unrecognized flash state");
                        break;
                }
            }
        }
        [currentCamera unlockForConfiguration];
    }
}

-(void)cameraFlipButtonTapped {
    self.frontCamera = !self.frontCamera;
    [self initializeCameraBetter];
}

- (void)cancelButtonTapped {
  [self.delegate cameraControllerDidCancel:self];
}

-(IBAction)cameraButtonTapped:(id)sender {
  [self capImage];
}

- (void)capImage {
  dispatch_async([self sessionQueue], ^{
    AVCaptureVideoOrientation orientation = [[(AVCaptureVideoPreviewLayer*)[[self viewFinderView] layer] connection] videoOrientation];
    [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:orientation];
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
      if (imageDataSampleBuffer) {
        [self prepareImageForPreview:[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer] forOrientation:orientation];
      }
    }];
  });
}

- (void)prepareImageForPreview:(NSData*)imageData forOrientation:(AVCaptureVideoOrientation)orientation {
  UIImage *image = [UIImage imageWithData:imageData];

  UIImage *rotatedImage;
  
  switch ([[UIDevice currentDevice] orientation]) {
    case UIDeviceOrientationUnknown:
    case UIDeviceOrientationFaceUp:
    case UIDeviceOrientationFaceDown:
    case UIDeviceOrientationPortrait:
      rotatedImage = image;
      NSLog(@"device is in portrait");
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      rotatedImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeft];
      NSLog(@"device is in upside down");
      break;
    case UIDeviceOrientationLandscapeLeft:
      rotatedImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUp];
      NSLog(@"device is in landscape left");
      break;
    case UIDeviceOrientationLandscapeRight:
      rotatedImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationDown];
      NSLog(@"device is in landscape right");
      break;
    default:
      break;
  }
  
  APImagePreviewViewController *vc = [[APImagePreviewViewController alloc] initWithImage:rotatedImage];
  vc.delegate = self;
  [self presentViewController:vc animated:NO completion:nil];

}

#pragma mark - PreviewDelegate Methods

-(void)imageApproved:(UIImage *)image {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.delegate capturedImage:image];
}

-(void)imageDenied {
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(CGFloat)degreesToRadians:(CGFloat)degrees{
    return M_PI * (degrees / 180.0);
}

-(CGSize)swapWidthAndHeightForSize:(CGSize)size {
    CGFloat swap = size.width;
    
    size.width  = size.height;
    size.height = swap;
    
    return size;
}

- (void)dealloc {
  [self.session stopRunning];
  self.session = nil;
  self.viewFinderView = nil;
}

@end
