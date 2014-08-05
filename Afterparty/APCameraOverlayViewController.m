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
@property (assign, nonatomic) FlashState                flashState;

@property (weak, nonatomic) IBOutlet APButton           *cameraButton;
@property (weak, nonatomic) IBOutlet APButton           *cancelButton;
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
- (IBAction)cameraButtonTapped:(id)sender;
- (IBAction)cancelButtonTapped:(id)sender;

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
  
    [self.cancelButton style];
  
  [self initializeCameraBetter];

  
    [UIView animateWithDuration:0.5
                          delay:0.4
         usingSpringWithDamping:0.25
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.cameraFlipButton setCenter:CGPointMake(60, self.buttonHeight + 20)];
                     } completion:nil];
    [UIView animateWithDuration:0.5
                          delay:0.5
         usingSpringWithDamping:0.25
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.flashButton setCenter:CGPointMake(260, self.buttonHeight + 20)];
                     } completion:nil];
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

-(IBAction)cameraButtonTapped:(id)sender {
  [self capImage];
}

- (IBAction)cancelButtonTapped:(id)sender {
  [self.delegate cameraControllerDidCancel:self];
}

- (void)capImage {
  dispatch_async([self sessionQueue], ^{
    [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer*)[[self viewFinderView] layer] connection] videoOrientation]];
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
      if (imageDataSampleBuffer) {
        [self prepareImageForPreview:[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer]];
      }
    }];
  });
}

- (void)prepareImageForPreview:(NSData*)imageData {
  UIImage *image = [UIImage imageWithData:imageData];

  UIImage *rotatedImage;
  switch ([[UIDevice currentDevice] orientation]) {
      case UIDeviceOrientationUnknown:
      case UIDeviceOrientationPortrait:
      case UIDeviceOrientationFaceUp:
      case UIDeviceOrientationFaceDown:
          rotatedImage = image;
          break;
      case UIDeviceOrientationPortraitUpsideDown:
          //rotate 180 degrees
          rotatedImage = [image imageRotatedByDegrees:180];
          break;
      case UIDeviceOrientationLandscapeLeft:
          rotatedImage = [image imageRotatedByDegrees:(self.frontCamera)?90:-90];
          break;
      case UIDeviceOrientationLandscapeRight:
          rotatedImage = [image imageRotatedByDegrees:(self.frontCamera)?-90:90];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
  [self.session stopRunning];
}

@end
