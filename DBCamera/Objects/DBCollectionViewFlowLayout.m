//
//  DBCollectionViewFlowLayout.m
//  DBCamera
//
//  Created by iBo on 06/03/14.
//  Copyright (c) 2014 PSSD - Daniele Bogo. All rights reserved.
//

#import "DBCollectionViewFlowLayout.h"

@implementation DBCollectionViewFlowLayout

-(instancetype) init
{
    self = [super init];
    if ( self ) {
        CGFloat separationBetweenImages = 7;
        CGFloat totalWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat imageSide = (totalWidth - separationBetweenImages * 2) / 3;
        [self setItemSize:(CGSize){ imageSide, imageSide }];
        [self setScrollDirection:UICollectionViewScrollDirectionVertical];
        [self setSectionInset:UIEdgeInsetsZero];
        [self setMinimumLineSpacing:separationBetweenImages];
        [self setMinimumInteritemSpacing:separationBetweenImages];
    }
    return self;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

@end