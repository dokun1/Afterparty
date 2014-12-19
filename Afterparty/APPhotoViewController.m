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
#import "APImageCollectionViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>

@import AssetsLibrary;

static NSString *const kCollectionViewCellIdentifier = @"imageCollectionViewCell";

@interface APPhotoViewController () <UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate, UIScrollViewDelegate>

@property (assign, nonatomic) CGFloat screenWidth;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITapGestureRecognizer *backRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressRecognizer;
@property (assign, nonatomic) BOOL longPressed;
@property (strong, nonatomic) APMetadataPhotoOverlayView *metadataView;


@end

@implementation APPhotoViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor afterpartyBlackColor];
    
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor afterpartyBlackColor];
//    [self.collectionView registerClass:[APImageCollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    self.backRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [self.view addGestureRecognizer:self.backRecognizer];
    
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognized:)];
    self.longPressRecognizer.minimumPressDuration = 0.7;
    [self.view addGestureRecognizer:self.longPressRecognizer];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.metadata.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    APImageCollectionViewCell *cell =  (APImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier forIndexPath:indexPath];
//    APPhotoInfo *photoInfo = self.metadata[indexPath.item];
//    cell.photoInfo = photoInfo;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:123];
    
    [imageView setImage:[UIImage imageNamed:@"stock3"]];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    for (APImageCollectionViewCell *cell in [self.collectionView visibleCells]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        self.selectedIndex = indexPath.item;
    }
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

-(void)longPressRecognized:(id)sender {
    if (self.longPressed == YES) {
        return;
    }
    self.longPressed = YES;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Report" otherButtonTitles:@"Save", nil];
    actionSheet.tag = 200;
    [actionSheet showInView:self.view];
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
                APPhotoInfo *reportedPhotoInfo = self.metadata[self.selectedIndex];
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
    
    APImageCollectionViewCell *cell = (APImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
    UIImage *selectedImage = cell.imageView.image;

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

#pragma mark - Cleanup

- (void)dealloc {
    self.backRecognizer = nil;
}

@end
