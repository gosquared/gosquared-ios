//
//  GSChatViewLayout.m
//  GoSquared
//
//  Created by Edward Wellbrook on 02/03/2016.
//  Copyright © 2016 Go Squared Ltd. All rights reserved.
//

#import "GSChatViewLayout.h"

@implementation GSChatViewLayout

- (instancetype)init
{
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumInteritemSpacing = CGFLOAT_MAX;
        self.minimumLineSpacing = 2;
    }
    return self;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return [self gs_layoutAttributesForItemAtIndexPath:itemIndexPath];
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    return [self gs_layoutAttributesForItemAtIndexPath:itemIndexPath];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *originalAttrs = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *attributes = [[NSMutableArray alloc] initWithArray:originalAttrs copyItems:YES];

    for (UICollectionViewLayoutAttributes *attrs in attributes) {
        if (attrs.representedElementCategory == UICollectionElementCategoryCell) {
            attrs.frame = [self gs_layoutAttributesForItemAtIndexPath:attrs.indexPath].frame;
        }
    }

    return attributes;
}

- (UICollectionViewLayoutAttributes *)gs_layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs = [[super layoutAttributesForItemAtIndexPath:indexPath] copy];
    CGRect frame = attrs.frame;

    if ([self.chatLayoutDelegate messageIsOwnAtIndexPath:attrs.indexPath]) {
        frame.origin.x = self.collectionView.frame.size.width - 4 - frame.size.width;
    } else {
        frame.origin.x = 4 + 32 + 4;
    }

    attrs.frame = frame;

    return attrs;
}

@end
