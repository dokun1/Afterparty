//
//  UIView+APViewAnimations.m
//  Afterparty
//
//  Created by David Okun on 6/23/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "UIView+APViewAnimations.h"
#import <pop/POP.h>

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
  [self performSelector:@selector(afterparty_disappearAlpha) withObject:nil afterDelay:animation.duration + 0.05];
  
}
-(void)afterparty_disappearAlpha {
  self.alpha = 0.0f;
}

- (void)afterparty_makeViewAppearWithCompletion:(APAnimationCompleteCallBackBlock)completionHandler {
  self.alpha = 1.0f;
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

- (void)afterparty_translateToPoint:(CGPoint)point expanding:(BOOL)expanding delay:(NSTimeInterval)delay withCompletion:(APAnimationCompleteCallBackBlock)completion {
  [self.layer pop_removeAllAnimations];
  
  POPSpringAnimation *moveAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPosition];
  [moveAnimation setCompletionBlock:^(POPAnimation *animation, BOOL complete) {
    if (completion) {
      completion();
    }
  }];
  moveAnimation.toValue = [NSValue valueWithCGPoint:point];
  moveAnimation.springBounciness = expanding ? 17.f : 7.f;
  moveAnimation.beginTime = CACurrentMediaTime() + delay;
  [self.layer pop_addAnimation:moveAnimation forKey:@"layerPositionAnimation"];
  
  POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
  scaleAnimation.toValue = expanding ? [NSValue valueWithCGSize:CGSizeMake(1.1, 1.1)] : [NSValue valueWithCGSize:CGSizeMake(0.95, 0.95)];
  scaleAnimation.springBounciness = 25.f;
  scaleAnimation.springSpeed = 9.f;
  scaleAnimation.beginTime = CACurrentMediaTime() + delay;
  [self.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}

@end
