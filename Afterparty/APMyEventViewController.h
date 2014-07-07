//
//  AfterpartyMyEventViewController.h
//  Afterparty
//
//  Created by David Okun on 11/22/13.
//  Copyright (c) 2013 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APConnectionManager.h"
#import "FXBlurView.h"
#import "APPhotoCommentTableView.h"
#import "APStackedGridLayout.h"
#import "APPhotoViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "APLabel.h"
#import "APButton.h"
#import "APPhotoCell.h"
#import "APComment.h"
#import "APPhotoInfo.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "APCameraOverlayViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <UIKit+AFNetworking.h>
#import "APMyEventUpdateLocationViewController.h"
#import "UIAlertView+APAlert.h"
#import "UIColor+APColor.h"
#import "APUtil.h"
#import "UIImage+APImage.h"
#import "APPhotoUploadQueue.h"

@interface APMyEventViewController : UIViewController 

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) APStackedGridLayout *layout;

@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet APLabel *countdownLabel;
@property (weak, nonatomic) IBOutlet APLabel *eventEndsLabel;

@property (strong, nonatomic) NSDictionary *eventDict;

@end
