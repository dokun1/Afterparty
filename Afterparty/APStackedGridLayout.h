//
//  AfterpartyStackedGridLayout.h
//  Afterparty
//
//  Created by David Okun on 1/20/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StackedGridLayoutDelegate <UICollectionViewDelegate>

-(NSInteger)collectionView:(UICollectionView*)cv layout:(UICollectionViewLayout*)cvl numberOfColumnsInSection:(NSInteger)section;
-(CGSize)collectionView:(UICollectionView*)cv layout:(UICollectionViewLayout*)cvl sizeForItemWithWidth:(CGFloat)width atIndexPath:(NSIndexPath*)indexPath;
-(UIEdgeInsets)collectionView:(UICollectionView*)cv layout:(UICollectionViewLayout*)cvl itemInsetsForSectionAtIndex:(NSInteger)section;

@end

@interface APStackedGridLayout : UICollectionViewLayout

@end
