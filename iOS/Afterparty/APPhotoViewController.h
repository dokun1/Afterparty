//
//  AfterpartyPhotoViewController.h
//  Afterparty
//
//  Created by David Okun on 3/2/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APPhotoViewController : UICollectionViewController

- (instancetype)initWithMetadata:(NSArray *)metadata atIndexPath:(NSIndexPath *)indexPath forCollectionViewLayout:(UICollectionViewLayout *)layout;

@end
