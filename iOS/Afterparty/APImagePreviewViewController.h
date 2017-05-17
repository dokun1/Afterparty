//
//  APImagePreviewViewController.h
//  Afterparty
//
//  Created by David Okun on 4/8/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APImagePreviewViewController;

@protocol PreviewDelegate <NSObject>

-(void)controller:(APImagePreviewViewController *)controller approvedImage:(UIImage*)image;
-(void)controllerDidNotApproveImage:(APImagePreviewViewController *)controller;

@end

@interface APImagePreviewViewController : UIViewController

-(id)initWithImage:(UIImage*)image;

@property (weak, nonatomic) id <PreviewDelegate> delegate;

@end
