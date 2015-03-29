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

@interface APPhotoViewController () <UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *backRecognizer;
@property (assign, nonatomic) BOOL longPressed;
@property (strong, nonatomic) NSArray *metadata;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation APPhotoViewController

- (instancetype)initWithMetadata:(NSArray *)metadata atIndexPath:(NSIndexPath *)indexPath forCollectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithCollectionViewLayout:layout]) {
        self.clearsSelectionOnViewWillAppear = YES;
        _metadata = [metadata copy];
        _selectedIndexPath = indexPath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView registerClass:[APImageCollectionViewCell class] forCellWithReuseIdentifier:APImageCollectionCellIdentifier];
    
    [self.collectionView scrollToItemAtIndexPath:self.selectedIndexPath atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

#pragma mark - UICollectionViewDelegate and Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.metadata.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    APImageCollectionViewCell *cell = (APImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:APImageCollectionCellIdentifier forIndexPath:indexPath];
    cell.navigationControllerContainer = self.navigationController;
    APPhotoInfo *photoInfo = self.metadata[indexPath.item];
    [cell setPhotoInfo:photoInfo];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}

- (void)tapGestureRecognized:(UITapGestureRecognizer*)recognizer {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 200) {
        self.longPressed = NO;
        switch (buttonIndex) {
            case 0:{
                NSArray *reportedPhotos = [APUtil getReportedPhotoIDs];
                APPhotoInfo *reportedPhotoInfo = self.metadata[self.selectedIndexPath.item];
                NSString *reportedPhotoID = reportedPhotoInfo.refID;
                if (![reportedPhotos containsObject:reportedPhotoID]) {
                    [APUtil saveReportedPhotoID:reportedPhotoID];
                    [SVProgressHUD showWithStatus:@"reporting..."];
                    [[APConnectionManager sharedManager] reportImageForImageRefID:reportedPhotoID success:^(BOOL succeeded) {
                        if (succeeded) {
                            NSMutableArray *newMetadata = [self.metadata mutableCopy];
                            [newMetadata removeObject:reportedPhotoInfo];
                            self.metadata = newMetadata;
                            [self.collectionView reloadData];
                            [SVProgressHUD dismiss];
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
            case 1:{
                APImageCollectionViewCell *cell = (APImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndexPath.item inSection:0]];
                UIImage *selectedImage = cell.imageView.image;
                [APUtil saveImageToCameraRoll:selectedImage];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    self.backRecognizer = nil;
}

@end
