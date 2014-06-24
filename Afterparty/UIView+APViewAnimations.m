//
//  UIView+APViewAnimations.m
//  Afterparty
//
//  Created by David Okun on 6/23/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "UIView+APViewAnimations.h"

@implementation UIView (APViewAnimations)

- (void)afterparty_makeViewDisappearWithCompletion:(APAnimationCompleteCallBackBlock)completionHandler {
  CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                    animationWithKeyPath:@"transform"];
  
  CATransform3D scale1 = CATransform3DMakeScale(1.0, 1.0, 1);
  CATransform3D scale2 = CATransform3DMakeScale(0.9, 0.9, 1);
  CATransform3D scale3 = CATransform3DMakeScale(1.2, 1.2, 1);
  CATransform3D scale4 = CATransform3DMakeScale(0.05, 0.5, 1);
  
  NSArray *frameValues = [NSArray arrayWithObjects:
                          [NSValue valueWithCATransform3D:scale1],
                          [NSValue valueWithCATransform3D:scale2],
                          [NSValue valueWithCATransform3D:scale3],
                          [NSValue valueWithCATransform3D:scale4],
                          nil];
  [animation setValues:frameValues];
  
  NSArray *frameTimes = [NSArray arrayWithObjects:
                         [NSNumber numberWithFloat:0.0],
                         [NSNumber numberWithFloat:0.5],
                         [NSNumber numberWithFloat:0.9],
                         [NSNumber numberWithFloat:1.0],
                         nil];
  [animation setKeyTimes:frameTimes];
  
  animation.fillMode = kCAFillModeForwards;
  animation.removedOnCompletion = NO;
  animation.duration = 0.3;
  
  [self.layer addAnimation:animation forKey:@"popup"];
}

- (void)afterparty_makeViewAppearWithCompletion:(APAnimationCompleteCallBackBlock)completionHandler {
  CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                    animationWithKeyPath:@"transform"];
  
  CATransform3D scale1 = CATransform3DMakeScale(0.05, 0.5, 1);
  CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
  CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
  CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
  
  NSArray *frameValues = [NSArray arrayWithObjects:
                          [NSValue valueWithCATransform3D:scale1],
                          [NSValue valueWithCATransform3D:scale2],
                          [NSValue valueWithCATransform3D:scale3],
                          [NSValue valueWithCATransform3D:scale4],
                          nil];
  [animation setValues:frameValues];
  
  NSArray *frameTimes = [NSArray arrayWithObjects:
                         [NSNumber numberWithFloat:0.0],
                         [NSNumber numberWithFloat:0.5],
                         [NSNumber numberWithFloat:0.9],
                         [NSNumber numberWithFloat:1.0],
                         nil];
  [animation setKeyTimes:frameTimes];
  
  animation.fillMode = kCAFillModeForwards;
  animation.removedOnCompletion = NO;
  animation.duration = 0.3;
  
  self.hidden = NO;
  [self.layer addAnimation:animation forKey:@"popup"];
  
}

@end
