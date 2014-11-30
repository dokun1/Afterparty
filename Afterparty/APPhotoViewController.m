//
//  AfterpartyPhotoViewController.m
//  Afterparty
//
//  Created by David Okun on 3/2/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APPhotoViewController.h"
#import "APConnectionManager.h"
#import "APPhotoInfo.h"
#import "APButton.h"
#import "APUtil.h"
#import "UIColor+APColor.h"
#import <UIImageView+AFNetworking.h>
#import "APMetadataPhotoOverlayView.h"
#import <MPParallaxCollection/MPParallaxLayout.h>
#import <MPParallaxCollection/MPParallaxCollectionViewCell.h>

@import AssetsLibrary;

@interface APPhotoViewController () <UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate,MPParallaxCellDelegate>

@property (strong, nonatomic) NSArray *metadata;
@property (assign, nonatomic) CGFloat screenWidth;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITapGestureRecognizer *backRecognizer;
@property (assign, nonatomic) NSInteger selectedIndex;
//@property (assign, nonatomic) BOOL longPressed;
@property (strong, nonatomic) APMetadataPhotoOverlayView *metadataView;


@end

@implementation APPhotoViewController

-(instancetype)initWithMetadata:(NSArray*)metadata andSelectedIndex:(NSInteger)selectedIndex{
    if (self = [super init]) {
        self.metadata = metadata;
        self.screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.selectedIndex = selectedIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor afterpartyBlackColor];
    
    MPParallaxLayout *layout=[[MPParallaxLayout alloc] init];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator=NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor afterpartyBlackColor];
    [self.collectionView registerClass:[MPParallaxCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    self.backRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [self.view addGestureRecognizer:self.backRecognizer];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.metadata.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MPParallaxCollectionViewCell* cell =  (MPParallaxCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[MPParallaxCollectionViewCell alloc] init];
    }
    
    APPhotoInfo *photoInfo = self.metadata[indexPath.item];
    [cell.imageView setImageWithURL:photoInfo.photoURL];
    
    cell.delegate = self;
    
    return cell;
}


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)tapGestureRecognized:(UITapGestureRecognizer*)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
}

//-(void)longPressRecognized:(id)sender {
//    if (self.longPressed == YES) {
//        return;
//    }
//    self.longPressed = YES;
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", nil];
//    actionSheet.tag = 200;
//    [actionSheet showInView:self.view];
//}
//
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (actionSheet.tag == 100) {
//        if (buttonIndex == 0) {
//            NSLog(@"not yet...");
//        }
//    }
//    if (actionSheet.tag == 200) {
//        self.longPressed = NO;
//        switch (buttonIndex) {
//            case 0:
//                [self saveImageToCameraRoll];
//                break;
//            case 1:
//                NSLog(@"soon!");
//                break;
//            default:
//                break;
//        }
//    }
//}
//
//-(void)saveImageToCameraRoll {
//    self.longPressed = NO;
//    
//    id obj = self.imageViewArray[self.selectedIndex];
//    if (![obj isKindOfClass:[UIScrollView class]])
//        return;
//    
//    UIScrollView *scrollView = obj;
//    __block UIImageView *imageView;
//    
//    [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[UIImageView class]]) {
//            imageView = obj;
//            *stop = YES;
//        }
//    }];
//
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    NSString *albumName = @"Afterparty";
//    __block ALAssetsGroup* folder;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSNumber *hasFolder = [[NSUserDefaults standardUserDefaults] objectForKey:@"hasFolder"];
//        if (![hasFolder boolValue]) {
//            [library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
//                NSLog(@"Added folder:%@", albumName);
//                folder = group;
//            } failureBlock:^(NSError *error) {
//                NSLog(@"Error adding folder");
//            }];
//            hasFolder = [NSNumber numberWithBool:YES];
//            [[NSUserDefaults standardUserDefaults] setValue:hasFolder forKey:@"hasFolder"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//        [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//            NSLog(@"found folder %@", [group valueForProperty:ALAssetsGroupPropertyName]);
//            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:albumName]) {
//                folder = group;
//                *stop = YES;
//            }
//        } failureBlock:^(NSError *error) {
//            [library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
//                NSLog(@"Added folder:%@", albumName);
//                folder = group;
//            } failureBlock:^(NSError *error) {
//                NSLog(@"Error adding folder");
//            }];
//        }];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSData *imageData = UIImagePNGRepresentation(imageView.image);
//            [library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
//                if (error.code == 0) {
//                    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
//                        [folder addAsset:asset];
//                    } failureBlock:^(NSError *error) {
//                        NSLog(@"Error adding image");
//                    }];
//                }else{
//                    NSLog(@"Error adding image: %@", error.localizedDescription);
//                }
//            }];
//        });
//    });
//}

//-(void)getImageForIndex:(NSInteger)index {
//    UIScrollView *scrollView = self.imageViewArray[index];
//    __block UIImageView *imageView;
//    
//    [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[UIImageView class]]) {
//            imageView = obj;
//            *stop = YES;
//        }
//    }];
//    
//    if (imageView.image == nil) {
//        dispatch_queue_priority_t priority = (index == self.selectedIndex) ? DISPATCH_QUEUE_PRIORITY_HIGH : DISPATCH_QUEUE_PRIORITY_BACKGROUND;
//        
//        dispatch_async(dispatch_get_global_queue(priority, 0), ^{
//            APPhotoInfo *currentPhotoInfo = self.metadata[index];
//            UIActivityIndicatorView *thisIndicatorView = self.downloadIndicators[index];
//            [self.view bringSubviewToFront:thisIndicatorView];
//            [[APConnectionManager sharedManager] downloadImageForRefID:[currentPhotoInfo refID] success:^(NSData *data) {
//                if (data != nil) {
//                    UIImage *image = [[UIImage alloc] initWithData:data];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        UIActivityIndicatorView *indicator = self.downloadIndicators[index];
//                        [indicator stopAnimating];
//                        [indicator setHidden:YES];
//                        id objScrollView = self.imageViewArray[index];
//                        if ([objScrollView isKindOfClass:[UIScrollView class]]) {
//                          UIScrollView *newScrollView = self.imageViewArray[index];
//                          __block UIImageView *newImageView;
//                          [newScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                            if ([obj isKindOfClass:[UIImageView class]]) {
//                              newImageView = obj;
//                              *stop = YES;
//                            }
//                          }];
//                          newImageView.image = image;
//                        }
//
//                    });
//                }
//            } failure:^(NSError *error) {
//                NSLog(@"Error at photo index %lu = %@", (long)index, [error localizedDescription]);
//            }];
//        });
//    }
//}

#pragma mark - UIScrollViewDelegate Methods

//-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        CGFloat xOffset = self.scrollView.contentOffset.x;
//        CGFloat newStart = 0;
//        BOOL done = NO;
//        NSInteger newIndex = 1;
//        NSInteger oldIndex = 1;
//        while (done == NO) {
//            if (newStart + self.screenWidth < xOffset) {
//                newStart += self.screenWidth;
//                newIndex++;
//            }else{
//                done = YES;
//            }
//        }
//        NSInteger purgeIndex;
//        if (velocity.x < 0) {
//            newIndex--;
//            self.selectedIndex = newIndex;
//            oldIndex = self.selectedIndex + 1;
//            newIndex--;
//            purgeIndex = self.selectedIndex + 5;
//        }else{
//            self.selectedIndex = newIndex;
//            oldIndex = self.selectedIndex - 1;
//            newIndex++;
//            purgeIndex = self.selectedIndex - 5;
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self setMetadataViewForIndex:self.selectedIndex];
//        });
//        if (newIndex >= [self.metadata count] || newIndex < 0)
//            return;
//        id obj = self.imageViewArray[newIndex];
//        if ([obj isKindOfClass:[UIScrollView class]])
//            return;
//      [self addImageAtNewIndex:newIndex oldIndex:oldIndex purgeIndex:purgeIndex];
//
//    });
//}
//
//- (void)addImageAtNewIndex:(NSInteger)newIndex oldIndex:(NSInteger)oldIndex purgeIndex:(NSInteger)purgeIndex {
//  UIScrollView *scrollView = [self scrollViewForIndex:newIndex];
//  UIImageView *imageView = [self imageViewForIndex:newIndex];
//  [scrollView addSubview:imageView];
//    
//  imageView.center = scrollView.center;
//  [self.imageViewArray replaceObjectAtIndex:newIndex withObject:scrollView];
//  UIActivityIndicatorView *indicator = self.downloadIndicators[newIndex];
//  dispatch_async(dispatch_get_main_queue(), ^{
//    [self.scrollView insertSubview:scrollView belowSubview:indicator];
//    scrollView.frame = self.view.frame;
//    scrollView.center = [self centerForImageViewAtIndex:newIndex];
//    [self getImageForIndex:newIndex];
//    [indicator setHidden:YES];
//    [indicator stopAnimating];
//    if (purgeIndex >= 0 && purgeIndex < [self.imageViewArray count]) {
//      id obj = self.imageViewArray[purgeIndex];
//      UIScrollView *purgeScrollView = ([obj isKindOfClass:[UIScrollView class]]) ? obj : nil;
//      if (!purgeScrollView)
//        return;
//      __block UIImageView *purgeImageView;
//      [purgeScrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[UIImageView class]]) {
//          purgeImageView = obj;
//          *stop = YES;
//        }
//      }];
//      if (purgeImageView) {
//        purgeImageView.image = nil;
//        purgeImageView = nil;
//        purgeScrollView = nil;
//        [purgeImageView removeFromSuperview];
//        [purgeScrollView removeFromSuperview];
//        APPhotoInfo *photoInfo = self.metadata[purgeIndex];
//        [self.imageViewArray replaceObjectAtIndex:purgeIndex withObject:photoInfo];
//        UIActivityIndicatorView *indicator = self.downloadIndicators[purgeIndex];
//        [indicator startAnimating];
//        [indicator setHidden:NO];
//      }
//    }
//  });
//  if (oldIndex > -1) {
//    id oldObj = self.imageViewArray[oldIndex];
//    if ([oldObj isKindOfClass:[UIScrollView class]]) {
//      UIScrollView *oldScrollView = oldObj;
//      dispatch_async(dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.2
//                         animations:^{
//                           oldScrollView.zoomScale = 1.0f;
//                         }];
//      });
//    }
//  }
//
//
//}
//
//-(UIImageView*)imageViewForIndex:(NSInteger)index {
//    APPhotoInfo *currentInfo = self.metadata[index];
//    CGRect currentFrame = CGRectMake(0, 0, [self sizePhotoForPage:currentInfo.size].width, [self sizePhotoForPage:currentInfo.size].height);
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:currentFrame];
//    imageView.clipsToBounds = YES;
//    return imageView;
//}
//
//-(UIScrollView *)scrollViewForIndex:(NSInteger)index {
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
//    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
//    recognizer.minimumPressDuration = 0.5;
//    [scrollView addGestureRecognizer:recognizer];
//    scrollView.maximumZoomScale = 4.0f;
//    scrollView.delegate = self;
//    scrollView.pagingEnabled = NO;
//    return scrollView;
//}

//- (void)setMetadataViewForIndex:(NSInteger)index {
//    APPhotoInfo *photoInfo = self.metadata[index];
//    self.metadataView.usernameLabel.text = [photoInfo.username uppercaseString];
//    self.metadataView.timestampLabel.text = [APUtil formatDateForEventCreationScreen:photoInfo.timestamp];
//}
//
//#pragma mark - UIScrollViewDelegate Methods
//
//-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    __block UIImageView *imageView;
//    
//    [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[UIImageView class]]) {
//            imageView = obj;
//            *stop = YES;
//        }
//    }];
//    return imageView;
//}
//
//#pragma mark - Sizing Util Methods
//
//-(CGSize)sizePhotoForPage:(CGSize)photoSize {
//    CGFloat width = self.screenWidth;
//    
//    CGSize newSize = CGSizeMake(width, 0);
//    if (photoSize.width > width) {
//        CGFloat divisor = photoSize.width / width;
//        newSize.height = photoSize.height/ divisor;
//    }else{
//        CGFloat factor = width / photoSize.width;
//        newSize.height = photoSize.height * factor;
//    }
//    
//    return newSize;
//}
//
//-(CGRect)frameForImageViewAtIndex:(NSInteger)index {
//    CGFloat x = self.screenWidth * index;
//    APPhotoInfo *currentInfo = self.metadata[index];
//    CGSize photoSize = [self sizePhotoForPage:[currentInfo size]];
//    return CGRectMake(x, 0, photoSize.width, photoSize.height);
//}
//
//
//
//-(CGPoint)centerForImageViewAtIndex:(NSInteger)index {
//    CGFloat x = (self.screenWidth * index) + 160;
//    return CGPointMake(x, CGRectGetMidY(self.view.bounds));
//}

#pragma mark - Cleanup

- (void)dealloc {
    self.backRecognizer = nil;
}

@end
