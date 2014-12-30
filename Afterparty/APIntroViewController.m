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

@property (strong, nonatomic) APLabel *descriptionOne;
@property (strong, nonatomic) APLabel *descriptionTwo;
@property (strong, nonatomic) APLabel *descriptionThree;
@property (strong, nonatomic) APLabel *descriptionFour;

@property (strong, nonatomic) UIImageView *imageViewOne;
@property (strong, nonatomic) UIImageView *imageViewTwo;
@property (strong, nonatomic) UIImageView *imageViewThree;

@property (strong, nonatomic) APButton *closeButton;

@property (strong, nonatomic) UIImageView *swipeIcon;

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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.swipeIcon.center = self.view.center;
        self.swipeIcon.alpha = 1.0f;
    } completion:nil];
}

- (void)placeViews {
    
    self.titleLabel = [[APLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    [self.titleLabel styleForType:LabelTypeLoginHeading withText:@"welcome to afterparty"];
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(self.view.center.x, 67);
    [self.scrollView addSubview:self.titleLabel];
    
    self.descriptionOne = [[APLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 200)];
    [self.descriptionOne styleForType:LabelTypeStandard withText:@"find an event near you, or make one yourself..."];
    self.descriptionOne.backgroundColor = [UIColor clearColor];
    self.descriptionOne.textColor = [UIColor afterpartyOffWhiteColor];
    self.descriptionOne.numberOfLines = 3;
    self.descriptionOne.center = self.view.center;
    self.descriptionOne.frame = CGRectOffset(self.descriptionOne.frame, timeForPage(2), -(self.view.frame.size.height/2 - 60));
    [self.scrollView addSubview:self.descriptionOne];
    
    self.imageViewOne = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutPhoto1"]];
    self.imageViewOne.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewOne.frame = CGRectMake(timeForPage(2), 120, self.view.frame.size.width, self.view.frame.size.height - 100);
    [self.scrollView addSubview:self.imageViewOne];
    
    self.swipeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"swipeIcon"]];
    self.swipeIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.swipeIcon.frame = CGRectMake(timeForPage(2) + 30, (self.view.frame.size.height / 2) - 100, 200, 200);
    self.swipeIcon.alpha = 0.0f;
    [self.scrollView addSubview:self.swipeIcon];
    
    self.descriptionTwo = [[APLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 200)];
    [self.descriptionTwo styleForType:LabelTypeStandard withText:@"start taking photos while you're there..."];
    self.descriptionTwo.backgroundColor = [UIColor clearColor];
    self.descriptionTwo.textColor = [UIColor afterpartyOffWhiteColor];
    self.descriptionTwo.numberOfLines = 3;
    self.descriptionTwo.center = self.view.center;
    self.descriptionTwo.frame = CGRectOffset(self.descriptionTwo.frame, timeForPage(3), -(self.view.frame.size.height/2 - 60));
    [self.scrollView addSubview:self.descriptionTwo];
    
    self.imageViewTwo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutPhoto3"]];
    self.imageViewTwo.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewTwo.frame = CGRectMake(timeForPage(3), 120, self.view.frame.size.width, self.view.frame.size.height - 100);
    [self.scrollView addSubview:self.imageViewTwo];
    
    self.descriptionThree = [[APLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 200)];
    [self.descriptionThree styleForType:LabelTypeStandard withText:@"and watch the photos add up!"];
    self.descriptionThree.backgroundColor = [UIColor clearColor];
    self.descriptionThree.textColor = [UIColor afterpartyOffWhiteColor];
    self.descriptionThree.numberOfLines = 3;
    self.descriptionThree.center = self.view.center;
    self.descriptionThree.frame = CGRectOffset(self.descriptionThree.frame, timeForPage(4), -(self.view.frame.size.height/2 - 60));
    [self.scrollView addSubview:self.descriptionThree];
    
    self.imageViewThree = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutPhoto2"]];
    self.imageViewThree.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewThree.frame = CGRectMake(timeForPage(4), 120, self.view.frame.size.width, self.view.frame.size.height - 100);
    [self.scrollView addSubview:self.imageViewThree];
    
    self.descriptionFour = [[APLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 40, 200)];
    [self.descriptionFour styleForType:LabelTypeStandard withText:@"an event disappears 24 hours after it ends, and so do all the photos, so get started now!"];
    self.descriptionFour.backgroundColor = [UIColor clearColor];
    self.descriptionFour.textColor = [UIColor afterpartyOffWhiteColor];
    self.descriptionFour.numberOfLines = 3;
    self.descriptionFour.center = self.view.center;
    self.descriptionFour.frame = CGRectOffset(self.descriptionFour.frame, timeForPage(5), -(self.view.frame.size.height/2 - 60));
    [self.scrollView addSubview:self.descriptionFour];
    
    self.closeButton = [[APButton alloc] initWithFrame:CGRectMake(timeForPage(5) + 10, self.view.frame.size.height - 60, self.view.frame.size.width - 20, 50)];
    [self.closeButton style];
    [self.closeButton setTitle:@"GET STARTED NOW!!" forState:UIControlStateNormal];
    self.closeButton.backgroundColor = [UIColor afterpartyCoralRedColor];
    [self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.closeButton];
}

- (void)configureAnimation {
    //when we make more use of the animations in IFTTT, well need this here for keyframe animations
}

- (void)closeButtonTapped {
    if ([self.introDelegate respondsToSelector:@selector(controllerDidFinish:)]) {
        [self.introDelegate controllerDidFinish:self];
    }
}

#pragma mark - IFTTTAnimatedScrollViewControllerDelegate

- (void)animatedScrollViewControllerDidScrollToEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController {
    NSLog(@"Scrolled to end of scrollview!");
}

- (void)animatedScrollViewControllerDidEndDraggingAtEnd:(IFTTTAnimatedScrollViewController *)animatedScrollViewController {
    NSLog(@"Ended dragging at end of scrollview!");
}

@end
