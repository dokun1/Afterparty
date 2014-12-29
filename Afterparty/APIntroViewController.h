//
//  APIntroViewController.h
//  Afterparty
//
//  Created by David Okun on 12/19/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IFTTTJazzHands.h>

@class APIntroViewController;

@protocol IntroControllerDelegate <NSObject>

- (void)controllerDidFinish:(APIntroViewController *)controller;

@end

@interface APIntroViewController : IFTTTAnimatedScrollViewController <IFTTTAnimatedScrollViewControllerDelegate>

@property (nonatomic, weak) id <IntroControllerDelegate> introDelegate;

@end
