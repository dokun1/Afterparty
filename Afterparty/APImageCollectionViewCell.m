//
//  APImageCollectionViewCell.m
//  Afterparty
//
//  Created by David Okun on 12/18/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APImageCollectionViewCell.h"
#import <UIKit+AFNetworking.h>
#import <SVProgressHUD.h>
#import "APUtil.h"
#import "APConnectionManager.h"
#import "APMetadataPhotoOverlayView.h"

@import AssetsLibrary;

NSString * const  APImageCollectionCellIdentifier = @"APPhotoGalleryCellPreview";

static const CGFloat ZOOM_FACTOR     = 1.5f;
static const CGFloat MAX_ZOOM_FACTOR = 4.0f;

@interface APImageCollectionViewCell () <UIScrollViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL navigationVisible;
@property (nonatomic, assign) BOOL longPressed;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) APMetadataPhotoOverlayView *metadataView;

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center;
- (void)addGestures;
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer;
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer;
- (void)toggleNavigationVisibleWithAnimation;

@end

@implementation APImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _navigationVisible = NO;
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.center = self.contentView.center;
        [self.contentView addSubview:_indicator];
        [_indicator startAnimating];
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.clipsToBounds = YES;
        _scrollView.delegate = self;
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        
        [_scrollView addSubview:_imageView];
        [self.contentView addSubview:_scrollView];
        [self addGestures];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.imageView.frame = self.bounds;
    self.scrollView.contentSize = self.imageView.frame.size;
    
    CGFloat minimumScale = self.scrollView.frame.size.width / self.imageView.frame.size.width;
    
    self.scrollView.maximumZoomScale = MAX_ZOOM_FACTOR;
    self.scrollView.minimumZoomScale = minimumScale;
    self.scrollView.zoomScale = minimumScale;
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - Setters

- (void)setPhotoInfo:(APPhotoInfo *)photoInfo {
    _photoInfo = photoInfo;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView setImageWithURL:photoInfo.photoURL];
    self.metadataView = [[APMetadataPhotoOverlayView alloc] initWithFrame:CGRectMake(10, self.contentView.frame.size.height - 80, self.contentView.frame.size.width - 20, 50)];
    self.metadataView.usernameLabel.text = photoInfo.username;
    self.metadataView.timestampLabel.text = [APUtil formatDateForEventCreationScreen:photoInfo.timestamp];
    [self.contentView addSubview:self.metadataView];
}

#pragma mark - UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Private

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width = self.scrollView.frame.size.width / scale;
    
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)addGestures {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];

    singleTap.delegate = self;
    
    [singleTap setNumberOfTapsRequired:1];
    [doubleTap setNumberOfTapsRequired:2];
    [longPress setMinimumPressDuration:0.7];
    
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [self.imageView addGestureRecognizer:longPress];
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.navigationControllerContainer) {
        [self toggleNavigationVisibleWithAnimation];
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    CGFloat newScale = self.scrollView.zoomScale * ZOOM_FACTOR;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.longPressed) {
        self.longPressed = YES;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:@"Save", nil];
        actionSheet.tag = 200;
        [actionSheet showInView:self.navigationControllerContainer.view];
    }
}

- (void)toggleNavigationVisibleWithAnimation {
    self.navigationVisible = !self.navigationVisible;
    [self.navigationControllerContainer setNavigationBarHidden:self.navigationVisible animated:YES];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    [self.metadataView removeFromSuperview];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            NSLog(@"not yet...");
        }
    }
    if (actionSheet.tag == 200) {
        self.longPressed = NO;
        switch (buttonIndex) {
            case 0:{
                NSArray *reportedPhotos = [APUtil getReportedPhotoIDs];
                APPhotoInfo *reportedPhotoInfo = self.photoInfo;
                NSString *reportedPhotoID = reportedPhotoInfo.refID;
                if (![reportedPhotos containsObject:reportedPhotoID]) {
                    [APUtil saveReportedPhotoID:reportedPhotoID];
                    [SVProgressHUD showWithStatus:@"reporting..."];
                    [[APConnectionManager sharedManager] reportImageForImageRefID:reportedPhotoID success:^(BOOL succeeded) {
                        if (succeeded) {
                            [[[UIAlertView alloc] initWithTitle:nil message:@"The photo you reported has been deleted from our servers. We apologize for the inconvenience." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        } else {
                            [SVProgressHUD showSuccessWithStatus:@"photo reported"];
                        }
                    } failure:^(NSError *error) {
                        [SVProgressHUD showErrorWithStatus:@"please try again"];
                    }];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"already reported"];
                }
                break;
            }
            case 1:
                [self saveImageToCameraRoll];
                break;
            default:
                break;
        }
    }
}


-(void)saveImageToCameraRoll {
    [PFAnalytics trackEvent:@"photoSaved"];
    self.longPressed = NO;
    
    UIImage *selectedImage = self.imageView.image;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSString *albumName = @"Afterparty";
    __block ALAssetsGroup* folder;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSNumber *hasFolder = [[NSUserDefaults standardUserDefaults] objectForKey:@"hasFolder"];
        if (![hasFolder boolValue]) {
            [library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                NSLog(@"Added folder:%@", albumName);
                folder = group;
            } failureBlock:^(NSError *error) {
                NSLog(@"Error adding folder");
            }];
            hasFolder = [NSNumber numberWithBool:YES];
            [[NSUserDefaults standardUserDefaults] setValue:hasFolder forKey:@"hasFolder"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            NSLog(@"found folder %@", [group valueForProperty:ALAssetsGroupPropertyName]);
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
                folder = group;
                *stop = YES;
            }
        } failureBlock:^(NSError *error) {
            [library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                NSLog(@"Added folder:%@", albumName);
                folder = group;
            } failureBlock:^(NSError *error) {
                NSLog(@"Error adding folder");
            }];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *imageData = UIImagePNGRepresentation(selectedImage);
            [library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error.code == 0) {
                    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [folder addAsset:asset];
                    } failureBlock:^(NSError *error) {
                        NSLog(@"Error adding image");
                    }];
                }else{
                    NSLog(@"Error adding image: %@", error.localizedDescription);
                }
            }];
        });
    });
}

@end
