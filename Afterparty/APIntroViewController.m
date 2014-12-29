//
//  APIntroViewController.m
//  Afterparty
//
//  Created by David Okun on 12/19/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APIntroViewController.h"
#import "APLabel.h"
#import "APButton.h"
#import "UIColor+APColor.h"

#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))

static NSInteger const kNumberOfPages = 5;

@interface APIntroViewController ()

@property (strong, nonatomic) APLabel *titleLabel;
@property (strong, nonatomic) UIImageView *logo;
@property (strong, nonatomic) APLabel *firstDescriptionLabel;
@property (strong, nonatomic) APLabel *secondPlayLabel;
@property (strong, nonatomic) UIImageView *secondImageView;
@property (strong, nonatomic) APButton *closeButton;
@property (strong, nonatomic) UIImageView *iPhoneFrameCamera;
@property (strong, nonatomic) UIImageView *iPhoneFrameEvent;

@property (strong, nonatomic) UIImageView *iPhoneOneFrame;
@property (strong, nonatomic) UIImageView *iPhoneTwoFrame;
@property (strong, nonatomic) UIImageView *iPhoneThreeFrame;

@property (strong, nonatomic) UIImageView *stockPhotoOne;
@property (strong, nonatomic) UIImageView *stockPhotoTwo;
@property (strong, nonatomic) UIImageView *stockPhotoThree;

@property (strong, nonatomic) UIImageView *mapImageView;

@end

@implementation APIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.contentSize = CGSizeMake(kNumberOfPages * CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor afterpartyLoginBackgroundColor];
    
    [self placeViews];
    [self configureAnimation];
    // Do any additional setup after loading the view.
}

- (void)placeViews {
    
    self.titleLabel = [[APLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    [self.titleLabel styleForType:LabelTypeLoginHeading withText:@"welcome to afterparty"];
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(self.view.center.x, 67);
    [self.scrollView addSubview:self.titleLabel];
    
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"facebookLogo"]];
    self.logo.center = self.view.center;
    self.logo.frame = CGRectOffset(self.logo.frame, self.view.frame.size.width, -100);
    self.logo.alpha = 0.0f;
    [self.scrollView addSubview:self.logo];
    
    self.firstDescriptionLabel = [[APLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 200)];
    [self.firstDescriptionLabel styleForType:LabelTypeStandard withText:@"step 1: find or create an event"];
    self.firstDescriptionLabel.backgroundColor = [UIColor clearColor];
    self.firstDescriptionLabel.textColor = [UIColor afterpartyOffWhiteColor];
    self.firstDescriptionLabel.numberOfLines = 3;
    self.firstDescriptionLabel.center = self.view.center;
    self.firstDescriptionLabel.frame = CGRectOffset(self.firstDescriptionLabel.frame, timeForPage(2), self.view.frame.size.height/2 - 40);
    [self.scrollView addSubview:self.firstDescriptionLabel];
    
    self.mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stockMap"]];
    self.mapImageView.center = self.view.center;
    self.mapImageView.frame = CGRectOffset(self.mapImageView.frame, timeForPage(2), 0);
    self.mapImageView.alpha = 0.0f;
    [self.scrollView addSubview:self.mapImageView];
    
    self.iPhoneOneFrame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iPhoneFrameEmpty"]];
    self.iPhoneOneFrame.frame = CGRectMake(10, self.view.frame.size.height + 10, self.view.frame.size.width / 2, (self.view.frame.size.height / 5) * 3);
    [self.scrollView addSubview:self.iPhoneOneFrame];
    
    self.iPhoneTwoFrame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iPhoneFrameEmptyHorizontal"]];
    self.iPhoneTwoFrame.frame = CGRectMake(-10 - ((self.view.frame.size.height / 5) * 3), 200, (self.view.frame.size.height / 5) * 3, self.view.frame.size.width / 2);
    [self.scrollView addSubview:self.iPhoneTwoFrame];
    
    self.stockPhotoOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introPhoto3"]];
    self.stockPhotoOne.frame = CGRectMake(22, self.view.frame.size.height + 40, self.iPhoneOneFrame.frame.size.width - 25, self.iPhoneOneFrame.frame.size.height - 100);
    [self.scrollView addSubview:self.stockPhotoOne];
    
    self.iPhoneFrameEvent = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introPhoneFrameSemiComplete"]];
    self.iPhoneFrameEvent.frame = CGRectMake(0, 0, self.view.frame.size.width - 40, self.view.frame.size.height - 140);
    self.iPhoneFrameEvent.contentMode = UIViewContentModeScaleAspectFit;
    self.iPhoneFrameEvent.center = CGPointMake(self.view.center.x, self.view.frame.size.height + 500);
    [self.scrollView addSubview:self.iPhoneFrameEvent];
}

- (void)configureAnimation {
    //title label animations
    IFTTTAngleAnimation *firstLabelRotateAnimation = [IFTTTAngleAnimation animationWithView:self.titleLabel];
    [self.animator addAnimation:firstLabelRotateAnimation];
    [firstLabelRotateAnimation addKeyFrames:@[
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andAngle:0.0f],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAngle:(CGFloat)(2 * M_PI)]
    ]];
    
    IFTTTFrameAnimation *firstLabelFrameAnimation = [IFTTTFrameAnimation animationWithView:self.titleLabel];
    [self.animator addAnimation:firstLabelFrameAnimation];
    [firstLabelFrameAnimation addKeyFrames:@[
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:self.titleLabel.frame],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:CGRectOffset(self.titleLabel.frame, self.view.frame.size.width, 0)],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:CGRectOffset(self.titleLabel.frame, self.view.frame.size.width * 2, 0)]
    ]];
    
    //map view animations
    IFTTTAlphaAnimation *mapAlphaAnimation = [IFTTTAlphaAnimation animationWithView:self.mapImageView];
    [self.animator addAnimation:mapAlphaAnimation];
    [mapAlphaAnimation addKeyFrames:@[
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andAlpha:0.0f],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andAlpha:1.0f],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andAlpha:0.0f]
                                      ]];
    
    IFTTTFrameAnimation *mapFrameAnimation = [IFTTTFrameAnimation animationWithView:self.mapImageView];
    [self.animator addAnimation:mapFrameAnimation];
    [mapFrameAnimation addKeyFrames:@[
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:self.mapImageView.frame],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:CGRectOffset(self.mapImageView.frame, timeForPage(1), 0)],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:CGRectOffset(self.mapImageView.frame, timeForPage(2), 0)]
                                      ]];
    
    //phoneFrameOne animations
    IFTTTFrameAnimation *phoneFrameOneAnimation = [IFTTTFrameAnimation animationWithView:self.iPhoneOneFrame];
    [self.animator addAnimation:phoneFrameOneAnimation];
    [phoneFrameOneAnimation addKeyFrames:@[
       [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:CGRectOffset(self.iPhoneOneFrame.frame, 0, 0)],
       [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:CGRectOffset(self.iPhoneOneFrame.frame, self.view.frame.size.width, 0)],
       [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:CGRectOffset(self.iPhoneOneFrame.frame, self.view.frame.size.width * 2, -300)],
       [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andFrame:CGRectOffset(self.iPhoneOneFrame.frame, self.view.frame.size.width * 3, 0)]
                                           ]];
    
    //stockPhotoOneAnimations
    IFTTTFrameAnimation *stockPhotoOneAnimation = [IFTTTFrameAnimation animationWithView:self.stockPhotoOne];
    [self.animator addAnimation:stockPhotoOneAnimation];
    [stockPhotoOneAnimation addKeyFrames:@[
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:CGRectOffset(self.stockPhotoOne.frame, 0, 0)],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:CGRectOffset(self.stockPhotoOne.frame, self.view.frame.size.width, 0)],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:CGRectOffset(self.stockPhotoOne.frame, self.view.frame.size.width * 2, -285)],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andFrame:CGRectOffset(self.stockPhotoOne.frame, self.view.frame.size.width * 3 + 28, -539)]
                                                   ]];
    
    IFTTTScaleAnimation *stockPhotoOneScaleAnimation = [IFTTTScaleAnimation animationWithView:self.stockPhotoOne];
    [self.animator addAnimation:stockPhotoOneScaleAnimation];
    [stockPhotoOneScaleAnimation addKeyFrames:@[
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andScale:1.0f],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andScale:1.0f],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andScale:1.0f],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andScale:0.715f],
                                                ]];
    
    //phoneFrameTwo animations
    IFTTTFrameAnimation *phoneFrameTwoAnimation = [IFTTTFrameAnimation animationWithView:self.iPhoneTwoFrame];
    [self.animator addAnimation:phoneFrameTwoAnimation];
    [phoneFrameTwoAnimation addKeyFrames:@[
       [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:CGRectOffset(self.iPhoneTwoFrame.frame, 0, 0)],
       [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:CGRectOffset(self.iPhoneTwoFrame.frame, self.view.frame.size.width, 0)],
       [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:CGRectOffset(self.iPhoneTwoFrame.frame, self.view.frame.size.width * 2 + self.iPhoneTwoFrame.frame.size.width - 50, 0)],
       [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andFrame:CGRectOffset(self.iPhoneTwoFrame.frame, self.view.frame.size.width * 3 - self.iPhoneTwoFrame.frame.size.width - 70, 0)]
                                           ]];
    
    
    //phoneFrameEvent animations
    IFTTTFrameAnimation *phoneFrameEventAnimation = [IFTTTFrameAnimation animationWithView:self.iPhoneFrameEvent];
    [self.animator addAnimation:phoneFrameEventAnimation];
    [phoneFrameEventAnimation addKeyFrames:@[
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(1) andFrame:CGRectOffset(self.iPhoneFrameEvent.frame, 0, 0)],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:CGRectOffset(self.iPhoneFrameEvent.frame, self.view.frame.size.width, 0)],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:CGRectOffset(self.iPhoneFrameEvent.frame, self.view.frame.size.width * 2, 0)],
        [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(4) andFrame:CGRectOffset(self.iPhoneFrameEvent.frame, self.view.frame.size.width * 3, -750)],
                                             ]];
    
}

#pragma mark - IFTTTAnimatedScrollViewControllerDelegate

- (void)animatedScrollViewControllerDidScrollToEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController {
    NSLog(@"Scrolled to end of scrollview!");
}

- (void)animatedScrollViewControllerDidEndDraggingAtEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController {
    NSLog(@"Ended dragging at end of scrollview!");
}

@end
