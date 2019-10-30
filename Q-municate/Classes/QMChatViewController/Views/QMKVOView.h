//
//  QMKVOView.h
//  
//
//  Created by Injoit on 10/12/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMKVOView : UIView

@property (nonatomic, copy, nullable) void (^hostViewFrameChangeBlock)(UIView * _Nullable view, BOOL Animated);

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIView *inputView;

@end

NS_ASSUME_NONNULL_END
