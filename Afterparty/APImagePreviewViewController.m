//
//  APImagePreviewViewController.m
//  Afterparty
//
//  Created by David Okun on 4/8/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APImagePreviewViewController.h"
#import "APButton.h"

@interface APImagePreviewViewController ()

@property (weak, nonatomic) IBOutlet APButton *retakeButton;
@property (weak, nonatomic) IBOutlet APButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

- (IBAction)retakeTapped:(id)sender;
- (IBAction)acceptTapped:(id)sender;

@end

@implementation APImagePreviewViewController

-(id)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.image = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  [self.retakeButton style];
  [self.acceptButton style];

    [self.imageView setImage:self.image];
    [self.imageView setContentMode:UIViewContentModeScaleToFill];
    [self.imageView setCenter:self.view.center];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)retakeTapped:(id)sender {
    [self.delegate imageDenied];
    
}

- (IBAction)acceptTapped:(id)sender {
    [self.delegate imageApproved:self.image];
}
@end
