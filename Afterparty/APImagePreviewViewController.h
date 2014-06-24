//
//  APImagePreviewViewController.h
//  Afterparty
//
//  Created by David Okun on 4/8/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreviewDelegate <NSObject>

-(void)imageApproved:(UIImage*)image;
-(void)imageDenied;

@end

@interface APImagePreviewViewController : UIViewController

-(id)initWithImage:(UIImage*)image;

@property (weak, nonatomic) id <PreviewDelegate> delegate;

@end
