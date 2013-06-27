//
//  TUAlbumViewLayout.m
//  TuneUno
//
//  Created by mattneary on 6/12/13.
//  Copyright (c) 2013 mattneary. All rights reserved.
//

#import "TUAlbumViewLayout.h"

@implementation TUAlbumViewLayout

- (id)init {
    if(self) {
        self.itemSize = CGSizeMake(50, 50);
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    int index = 0;
    for(UICollectionViewLayoutAttributes* attributes in array) {        
        if(CGRectIntersectsRect(attributes.frame, rect)){
            attributes.frame = CGRectMake((index*50)%300, floor(index/6)*50, 50, 50);
        }
        index++;
    }
    return array;
}
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
@end
