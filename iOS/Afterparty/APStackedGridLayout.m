//
//  AfterpartyStackedGridLayout.m
//  Afterparty
//
//  Created by David Okun on 1/20/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import "APStackedGridLayout.h"
#import "APStackedGridLayoutSection.h"

@interface APStackedGridLayout ()

@property (strong, nonatomic) NSMutableArray *sectionData;
@property (assign, nonatomic) CGFloat height;
@property (weak, nonatomic) id<StackedGridLayoutDelegate> myDelegate;

@end

@implementation APStackedGridLayout

-(void)prepareLayout {
    [super prepareLayout];
    
    self.myDelegate = (id<StackedGridLayoutDelegate>)self.collectionView.delegate;
    self.sectionData = [NSMutableArray new];
    self.height = 0.0f;
    
    CGPoint currentOrigin = CGPointZero;

    currentOrigin.y = self.height;
    
    NSInteger numberOfColumns = [self.myDelegate collectionView:self.collectionView
                                                     layout:self
                                   numberOfColumnsInSection:0];
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    
    UIEdgeInsets itemInsets = [self.myDelegate collectionView:self.collectionView
                                                   layout:self itemInsetsForSectionAtIndex:0];
    
    APStackedGridLayoutSection *section = [[APStackedGridLayoutSection alloc] initWithOrigin:currentOrigin width:self.collectionView.bounds.size.width columns:numberOfColumns itemInsets:itemInsets];
    
    for (NSInteger i = 0; i < numberOfItems; i++) {
        CGFloat itemWidth = (section.columnWidth - section.itemInsets.left - section.itemInsets.right);
        NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
        CGSize itemSize = [self.myDelegate collectionView:self.collectionView layout:self sizeForItemWithWidth:itemWidth atIndexPath:itemIndexPath];
        [section addItemOfSize:itemSize forIndex:i];
    }
    
    [self.sectionData addObject:section];
    
    self.height += section.frame.size.height;
    currentOrigin.y = self.height;
}

-(CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width, self.height);
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    APStackedGridLayoutSection *section = self.sectionData[indexPath.section];
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = [section frameForItemAtIndex:indexPath.item];
    return attributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [NSMutableArray new];
    [self.sectionData enumerateObjectsUsingBlock:^(APStackedGridLayoutSection *section, NSUInteger sectionIndex, BOOL *stop) {
        CGRect sectionFrame = section.frame;
        
        if (CGRectIntersectsRect(sectionFrame, rect)) {
            for (NSInteger index = 0; index < section.numberOfItems; index++) {
                CGRect frame = [section frameForItemAtIndex:index];
                if (CGRectIntersectsRect(frame, rect)) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:sectionIndex];
                    UICollectionViewLayoutAttributes *la = [self layoutAttributesForItemAtIndexPath:indexPath];
                    [attributes addObject:la];
                }
            }
        }
    }];
    
    return attributes;
}

@end
