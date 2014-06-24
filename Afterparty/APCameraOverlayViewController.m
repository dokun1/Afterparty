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
@property (weak, nonatomic) IBOutlet UIView             *viewFinderView;


@property (strong, nonatomic) AVCaptureSession          *session;

@property (assign, nonatomic) BOOL                      frontCamera;
@property (assign, nonatomic) BOOL                      haveImage;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

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
    [self initalizeCamera];
}

-(void)initalizeCamera {
    if (self.session) {
        self.session = nil;
    }
    
    self.session = [[AVCaptureSession alloc] init];
	self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
	captureVideoPreviewLayer.frame = self.imagePreview.bounds;
	[self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
    
    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            if ([device position] == AVCaptureDevicePositionBack) {
                backCamera = device;
            }
            else {
                frontCamera = device;
            }
        }
    }

    NSError *error = nil;
    AVCaptureDeviceInput *input;
    if (!self.frontCamera) {
        input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    }else{
        input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (self.flashState == kFlashAuto || self.flashState == kFlashOn) {
            NSLog(@"auto/on changing to off");
            [self.flashButton setImage:[UIImage imageNamed:@"button_flashoff.png"] forState:UIControlStateNormal];
            self.flashState = kFlashOff;
        }
    }
    if (!input) {
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [self.session addInput:input];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    [self.session addOutput:self.stillImageOutput];
    
	[self.session startRunning];
    
    [self.view bringSubviewToFront:self.cameraFlipButton];
    [self.view bringSubviewToFront:self.flashButton];
    [self.view bringSubviewToFront:self.cameraButton];
    [self.view bringSubviewToFront:self.cancelButton];
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
    [self initalizeCamera];
}

-(IBAction)cameraButtonTapped:(id)sender {
    [self capImage];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) capImage { //method to capture image from AVCaptureSession video feed
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    NSLog(@"about to request a capture from: %@", self.stillImageOutput);

    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
//            // Resize image
            UIGraphicsBeginImageContext(CGSizeMake(320, self.view.frame.size.height));
            [image drawInRect: CGRectMake(0, 0, 320, self.view.frame.size.height)];
            UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            CGRect cropRect = self.view.bounds;
            CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
            
            UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
            UIImage *rotatedImage;
            switch ([[UIDevice currentDevice] orientation]) {
                case UIDeviceOrientationUnknown:
                case UIDeviceOrientationPortrait:
                case UIDeviceOrientationFaceUp:
                case UIDeviceOrientationFaceDown:
                    rotatedImage = croppedImage;
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    //rotate 180 degrees
                    rotatedImage = [croppedImage imageRotatedByDegrees:180];
                    break;
                case UIDeviceOrientationLandscapeLeft:
                    rotatedImage = [croppedImage imageRotatedByDegrees:(self.frontCamera)?90:-90];
                    break;
                case UIDeviceOrientationLandscapeRight:
                    rotatedImage = [croppedImage imageRotatedByDegrees:(self.frontCamera)?-90:90];
                    break;
                default:
                    break;
            }
            
            APImagePreviewViewController *vc = [[APImagePreviewViewController alloc] initWithImage:rotatedImage];
            vc.delegate = self;
            [self presentViewController:vc animated:NO completion:nil];
            CGImageRelease(imageRef);
        }
    }];
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

@end
