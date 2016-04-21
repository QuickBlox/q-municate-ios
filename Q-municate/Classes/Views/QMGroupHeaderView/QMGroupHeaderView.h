//
//  QMGroupHeaderView.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMGroupHeaderView class interface.
 *  This view is used as Group info header and contains its avatar and name.
 */
@interface QMGroupHeaderView : UIControl

/**
 *  Set title and avatar for group using avatar url if existent and placeholder ID.
 *
 *  @param title         name of group chat
 *  @param avatarUrl     avatar url
 *  @param placeholderID placeholder ID
 */
- (void)setTitle:(nullable NSString *)title avatarUrl:(nullable NSString *)avatarUrl placeholderID:(NSUInteger)placeholderID;

@end

NS_ASSUME_NONNULL_END
