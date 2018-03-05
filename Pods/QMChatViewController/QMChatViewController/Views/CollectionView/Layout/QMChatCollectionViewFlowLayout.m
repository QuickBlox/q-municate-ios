//
//  QMChatCollectionViewFlowLayout.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCollectionViewFlowLayout.h"
#import "QMChatCellLayoutAttributes.h"
#import "QMCollectionViewFlowLayoutInvalidationContext.h"

#import "QMChatCollectionView.h"

@interface QMChatCollectionViewFlowLayout()
@property (strong, nonatomic) NSMutableDictionary *cache;
@end

@implementation QMChatCollectionViewFlowLayout

@dynamic chatCollectionView;

- (QMChatCollectionView *)chatCollectionView {
    
    return (id)self.collectionView;
}

//MARK: - Initialization

- (void)configureFlowLayout {
    
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.sectionInset = UIEdgeInsetsMake(10.0f, 4.0f, 10.0f, 4.0f);
    self.minimumLineSpacing = 4.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveApplicationMemoryWarningNotification:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    /**
     *  Init cache
     */
    self.cache = [[NSMutableDictionary alloc] init];
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self configureFlowLayout];
    }
    
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self configureFlowLayout];
}

+ (Class)layoutAttributesClass {
    
    return [QMChatCellLayoutAttributes class];
}

+ (Class)invalidationContextClass {
    
    return [QMCollectionViewFlowLayoutInvalidationContext class];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGFloat)itemWidth {
    
    return CGRectGetWidth(self.collectionView.frame) - self.sectionInset.left - self.sectionInset.right;
}

//MARK: - Notifications

- (void)didReceiveApplicationMemoryWarningNotification:(NSNotification *)notification {
    
    [self resetLayout];
}

//MARK: - Collection view flow layout

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds {
    
    QMCollectionViewFlowLayoutInvalidationContext *context = [QMCollectionViewFlowLayoutInvalidationContext context];
    
    if (self.collectionView.bounds.size.width != newBounds.size.width) {
        context.invalidateFlowLayoutMessagesCache = YES;
    }
    
    return context;
}

- (void)invalidateLayoutWithContext:(QMCollectionViewFlowLayoutInvalidationContext *)context {
    
    if (context.invalidateDataSourceCounts) {
        context.invalidateFlowLayoutAttributes = YES;
        context.invalidateFlowLayoutDelegateMetrics = YES;
    }
    
    if (context.invalidateFlowLayoutMessagesCache) {
        
        [self resetLayout];
    }
    
    [super invalidateLayoutWithContext:context];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *attributesInRect = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect]
                                                     copyItems:YES];

    [attributesInRect enumerateObjectsUsingBlock:^(QMChatCellLayoutAttributes *attributesItem, NSUInteger idx, BOOL *stop) {
        
        if (attributesItem.representedElementCategory == UICollectionElementCategoryCell) {
            [self configureCellLayoutAttributes:attributesItem];
        }
    }];
    
    return attributesInRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    QMChatCellLayoutAttributes *customAttributes = (id)[super layoutAttributesForItemAtIndexPath:indexPath];
    
    if (customAttributes.representedElementCategory == UICollectionElementCategoryCell) {
        [self configureCellLayoutAttributes:customAttributes];
    }
    
    return customAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    CGRect oldBounds = self.collectionView.bounds;
    return !CGSizeEqualToSize(oldBounds.size, newBounds.size) ? YES : NO;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    
    [super prepareForCollectionViewUpdates:updateItems];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger index, BOOL *stop) {
    
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            
            CGFloat collectionViewHeight = CGRectGetHeight(self.collectionView.bounds);
            
            QMChatCellLayoutAttributes *attributes =
            [QMChatCellLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
            
            if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
                [self configureCellLayoutAttributes:attributes];
            }
            
            attributes.frame = CGRectMake(0.0f,
                                          collectionViewHeight + CGRectGetHeight(attributes.frame),
                                          CGRectGetWidth(attributes.frame),
                                          CGRectGetHeight(attributes.frame));
        }
    }];
}

//MARK:- Invalidation utilities

- (void)resetLayout {
    [self.cache removeAllObjects];
}

//MARK: - Message cell layout utilities

- (void)removeSizeFromCacheForItemID:(NSString *)itemID {
    [self.cache removeObjectForKey:itemID];
}

- (CGSize)containerViewSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //Item unique id
    NSString *itemID = [self.chatCollectionView.dataSource collectionView:self.chatCollectionView
                                                        itemIdAtIndexPath:indexPath];

    NSValue *cachedSize = [self.cache objectForKey:itemID];
    
    if (cachedSize != nil) {
        
        return [cachedSize CGSizeValue];
    }

    QMChatCellLayoutModel layoutModel =
    [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                     layoutModelAtIndexPath:indexPath];
    
    CGSize finalSize;
    
    if (CGSizeEqualToSize(layoutModel.staticContainerSize, CGSizeZero)) {
        
        //  from the cell xibs, there is a 2 point space between avatar and bubble
        CGFloat spacingBetweenAvatarAndBubble = 2.0f;
        CGFloat horizontalContainerInsets = layoutModel.containerInsets.left + layoutModel.containerInsets.right;
        CGFloat horizontalInsetsTotal = horizontalContainerInsets + spacingBetweenAvatarAndBubble;
        CGFloat maximumWidth = self.itemWidth - layoutModel.avatarSize.width - layoutModel.maxWidthMarginSpace;
        
        if (layoutModel.maxWidth > 0) {
            maximumWidth = MIN(maximumWidth, layoutModel.maxWidth - layoutModel.avatarSize.width - layoutModel.maxWidthMarginSpace);
        }
        NSAssert(maximumWidth >= 0, @"Maximum width cannot be a negative nuber. Please check your maxWidthMarginSpace value.");
        
        CGSize dynamicSize = [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                                                       dynamicSizeAtIndexPath:indexPath
                                                                     maxWidth:maximumWidth - horizontalInsetsTotal];
        CGFloat verticalContainerInsets =
        layoutModel.containerInsets.top + layoutModel.containerInsets.bottom +
        layoutModel.topLabelHeight + layoutModel.bottomLabelHeight;
        
        CGFloat additionalSpace =
        layoutModel.spaceBetweenTextViewAndBottomLabel + layoutModel.spaceBetweenTopLabelAndTextView;
        
        CGFloat finalWidth = dynamicSize.width + horizontalContainerInsets;
        
        CGFloat cellHeight = dynamicSize.height + verticalContainerInsets + additionalSpace;
        CGFloat finalCellHeight = MAX(cellHeight, layoutModel.avatarSize.height);
        
        CGFloat minWidth = [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                                                        minWidthAtIndexPath:indexPath];
        minWidth += horizontalContainerInsets;
        
        finalSize = CGSizeMake(MIN(MAX(finalWidth, minWidth), maximumWidth), finalCellHeight);
    }
    else {
        
        finalSize = layoutModel.staticContainerSize;
    }
    
    [self.cache setObject:[NSValue valueWithCGSize:finalSize] forKey:itemID];
    
    return finalSize;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize containerSize = [self containerViewSizeForItemAtIndexPath:indexPath];
    
    return CGSizeMake(self.itemWidth, ceilf(containerSize.height));
}

- (void)configureCellLayoutAttributes:(QMChatCellLayoutAttributes *)layoutAttributes {
    
    NSIndexPath *indexPath = layoutAttributes.indexPath;
    
    CGSize containerSize = [self containerViewSizeForItemAtIndexPath:indexPath];
    layoutAttributes.containerSize = containerSize;
    
    // fix for content size changes (example: split view display mode change)
    CGRect frame = layoutAttributes.frame;
    frame.origin.x = self.sectionInset.left;
    frame.size.width = [self itemWidth];
    layoutAttributes.frame = frame;
    
    QMChatCellLayoutModel layoutModel =
    [self.chatCollectionView.delegate collectionView:self.chatCollectionView
                              layoutModelAtIndexPath:indexPath];
    
    layoutAttributes.avatarSize = layoutModel.avatarSize;
    layoutAttributes.containerInsets = layoutModel.containerInsets;
    layoutAttributes.topLabelHeight = layoutModel.topLabelHeight;
    layoutAttributes.bottomLabelHeight = layoutModel.bottomLabelHeight;
    layoutAttributes.spaceBetweenTopLabelAndTextView = layoutModel.spaceBetweenTopLabelAndTextView;
    layoutAttributes.spaceBetweenTextViewAndBottomLabel = layoutModel.spaceBetweenTextViewAndBottomLabel;
}

@end
