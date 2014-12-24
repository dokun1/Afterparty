//
//  APCollectionViewGalleryFlowLayout.m
//  Afterparty
//
//  Created by David Okun on 12/24/14.
//  Copyright (c) 2014 Afterparty. All rights reserved.
//

#import "APCollectionViewGalleryFlowLayout.h"

@implementation APCollectionViewGalleryFlowLayout

- (instancetype)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 0.0f;
        self.minimumInteritemSpacing = 0.0f;
    }
    return self;
}

@end
