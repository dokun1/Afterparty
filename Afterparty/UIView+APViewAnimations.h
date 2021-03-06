//
//  UIView+APViewAnimations.h
//  Afterparty
//
//  Created by David Okun on 6/23/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^APAnimationCompleteCallBackBlock)();

@interface UIView (APViewAnimations)

- (void)afterparty_makeViewDisappearWithCompletion:(APAnimationCompleteCallBackBlock)completionHandler;
- (void)afterparty_makeViewAppearWithCompletion:(APAnimationCompleteCallBackBlock)completionHandler;
- (void)afterparty_translateToPoint:(CGPoint)point expanding:(BOOL)expanding delay:(NSTimeInterval)delay withCompletion:(APAnimationCompleteCallBackBlock)completion;

@end
