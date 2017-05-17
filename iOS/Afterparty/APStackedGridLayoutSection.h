//
//  AfterpartyStackedGridLayoutSection.h
//  Afterparty
//
//  Created by David Okun on 1/20/14.
//  Copyright (c) 2014 DMOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APStackedGridLayoutSection : NSObject

@property (nonatomic, assign, readonly) CGRect       frame;
@property (nonatomic, assign, readonly) UIEdgeInsets itemInsets;
@property (nonatomic, assign, readonly) CGFloat      columnWidth;
@property (nonatomic, assign, readonly) NSInteger    numberOfItems;

-(id)initWithOrigin:(CGPoint)origin width:(CGFloat)width columns:(NSInteger)columns itemInsets:(UIEdgeInsets)itemInsets;

-(void)addItemOfSize:(CGSize)size forIndex:(NSInteger)index;

-(CGRect)frameForItemAtIndex:(NSInteger)index;

@end
