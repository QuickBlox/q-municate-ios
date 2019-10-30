//
//  QMGroupHeaderView.h
//  Q-municate
//
//  Created by Injoit on 4/18/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMImageView.h"

NS_ASSUME_NONNULL_BEGIN

@class QMGroupHeaderView;

/**
 *  QMGroupHeaderViewDelegate protocol. Used to notify about actions on current view.
 */
@protocol QMGroupHeaderViewDelegate <NSObject>

/**
 *  Protocol methods down below are required to be implemented
 */
@required

/**
 *  Notifying about avatar image view received tap.
 *
 *  @param groupHeaderView QMGroupHeaderView instance
 *  @param avatarImageView QMImageView instance of avatar image
 */
- (void)groupHeaderView:(QMGroupHeaderView *)groupHeaderView didTapAvatar:(QMImageView *)avatarImageView;

@end

/**
 *  QMGroupHeaderView class interface.
 *  This view is used as Group info header and contains its avatar and name.
 */
@interface QMGroupHeaderView : UIControl

/**
 *  Delegate instance that conforms to QMGroupHeaderViewDelegate protocol.
 */
@property (weak, nonatomic, nullable) id<QMGroupHeaderViewDelegate> delegate;

/**
 *  Avatar Image View.
 */
@property (weak, nonatomic) IBOutlet QMImageView *avatarImage;

/**
 *  Set title and avatar for group using avatar url if existent and placeholder ID.
 *
 *  @param title         name of group chat
 *  @param avatarUrl     avatar url
 *  @param placeholderID placeholder ID
 */
- (void)setTitle:(nullable NSString *)title avatarUrl:(nullable NSString *)avatarUrl;

@end

NS_ASSUME_NONNULL_END
