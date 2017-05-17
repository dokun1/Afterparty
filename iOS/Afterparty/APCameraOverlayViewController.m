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
#import "APAVSessionController.h"

@interface APCameraOverlayViewController () <PreviewDelegate,AVSessionControllerDelegate>

@property (assign, nonatomic) CGFloat                   screenHeight;
@property (assign, nonatomic) CGFloat                   buttonHeight;

@property (strong, nonatomic) UIButton                  *cameraFlipButton;
@property (strong, nonatomic) UIButton                  *flashButton;
@property (strong, nonatomic) UIButton                  *cancelButton;
@property (weak, nonatomic) IBOutlet APButton           *cameraButton;
@property (weak, nonatomic) IBOutlet UIView             *imagePreview;
@property (weak, nonatomic) IBOutlet APCamPreviewView   *viewFinderView;

@property (nonatomic, strong, readwrite) APAVSessionController *sessionController;

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
    [self.cameraFlipButton setFrame:CGRectMake(CGRectGetMidX(screenRect) - 20, self.buttonHeight, 40, 40)];
    [self.cameraFlipButton addTarget:self action:@selector(cameraFlipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.cameraFlipButton belowSubview:self.cameraButton];
    
    self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashButton setBackgroundColor:[UIColor clearColor]];
    [self.flashButton setImage:[UIImage imageNamed:@"button_flashauto.png"] forState:UIControlStateNormal];
    [self.flashButton setFrame:CGRectMake(CGRectGetMidX(screenRect) - 20, self.buttonHeight, 40, 40)];
    [self.flashButton addTarget:self action:@selector(cameraFlashButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.flashButton belowSubview:self.cameraButton];
  
  self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.cancelButton setBackgroundColor:[UIColor clearColor]];
  [self.cancelButton setImage:[UIImage imageNamed:@"button_redCancel"] forState:UIControlStateNormal];
  [self.cancelButton setFrame:CGRectMake(CGRectGetMidX(screenRect) - 20, self.buttonHeight, 40, 40)];
  [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  [self.view insertSubview:self.cancelButton belowSubview:self.cameraButton];
  
  [self.cameraFlipButton afterparty_translateToPoint:CGPointMake(60, self.buttonHeight + 20) expanding:YES delay:0.1 withCompletion:nil];
  [self.flashButton afterparty_translateToPoint:CGPointMake(CGRectGetMaxX(screenRect) - 60, self.buttonHeight + 20) expanding:YES delay:0.2 withCompletion:nil];
  [self.cancelButton afterparty_translateToPoint:CGPointMake(30, 30) expanding:YES delay:0.3 withCompletion:nil];
    
    self.sessionController = [[APAVSessionController alloc] initWithPreviewView:self.viewFinderView];
    self.sessionController.delegate = self;
    [self.sessionController startSession];
}

# pragma mark - Actions
-(void)cameraFlashButtonTapped {
    [self.sessionController switchFlash];
}

-(void)cameraFlipButtonTapped {
    [self.sessionController switchCamera];
}

- (void)cancelButtonTapped {
  [self.delegate cameraControllerDidCancel:self];
}

-(IBAction)cameraButtonTapped:(id)sender {
    [self.sessionController takePicture];
}

# pragma mark - Helper methods
- (void)prepareImageForPreview:(NSData*)imageData forOrientation:(AVCaptureVideoOrientation)orientation {
  UIImage *image = [UIImage imageWithData:imageData];

  UIImage *rotatedImage;
  BOOL isFrontCamera = self.sessionController.isUsingFrontFacingCamera;
  
  switch ([[UIDevice currentDevice] orientation]) {
    case UIDeviceOrientationUnknown:
    case UIDeviceOrientationFaceUp:
    case UIDeviceOrientationFaceDown:
    case UIDeviceOrientationPortrait:
      rotatedImage = image;
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      rotatedImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeft];
      break;
    case UIDeviceOrientationLandscapeLeft:
      rotatedImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:isFrontCamera?UIImageOrientationDown:UIImageOrientationUp];
      break;
    case UIDeviceOrientationLandscapeRight:
      rotatedImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:isFrontCamera?UIImageOrientationUp:UIImageOrientationDown];
      break;
    default:
      break;
  }
  
  APImagePreviewViewController *vc = [[APImagePreviewViewController alloc] initWithImage:rotatedImage];
  vc.delegate = self;
  [self presentViewController:vc animated:NO completion:nil];

}

#pragma mark - PreviewDelegate Methods

- (void)controller:(APImagePreviewViewController *)controller approvedImage:(UIImage *)image {
    [controller dismissViewControllerAnimated:NO completion:nil];
    [self.delegate capturedImage:image];
}

- (void)controllerDidNotApproveImage:(APImagePreviewViewController *)controller {
    [controller dismissViewControllerAnimated:NO completion:nil];
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

#pragma mark - APAVSessionControllerDelegate Methods
- (void)sessionDidReceivedImageData:(NSData *)imageData forOrientation:(AVCaptureVideoOrientation)videoOrientation {
    [self prepareImageForPreview:self.sessionController.capturedImageData forOrientation:self.sessionController.videoOrientation];
}

- (void)cameraDidSwitchedFlashStateToState:(FlashState)flashState {
    switch (flashState) {
        case kFlashAuto:
            [self.flashButton setImage:[UIImage imageNamed:@"button_flashauto.png"] forState:UIControlStateNormal];
            break;
        case kFlashOn:
            [self.flashButton setImage:[UIImage imageNamed:@"button_flashon.png"] forState:UIControlStateNormal];
            break;
        case kFlashOff:
            [self.flashButton setImage:[UIImage imageNamed:@"button_flashoff.png"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }

}

- (void)dealloc {
    [self.sessionController stopSession];
    self.viewFinderView = nil;
}

@end
