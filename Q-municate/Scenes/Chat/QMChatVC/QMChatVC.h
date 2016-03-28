//
//  QMChatVC.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/9/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatViewController.h"

/**
 *  Chat view controller.
 */
@interface QMChatVC : QMChatViewController

/**
 *  Chat dialog.
 */
@property (strong, nonatomic, nonnull) QBChatDialog *chatDialog;

/**
 *  Init.
 *
 *  @warning Unavailable. Use 'chatViewControllerWithChatDialog:' instead.
 *
 *  @return QMChatVC new instance.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 *  Init with coder.
 *
 *  @param aDecoder a decoder
 *
 *  @warning Unavailable. Use 'chatViewControllerWithChatDialog:' instead.
 *
 *  @return QMChatVC new instance.
 */
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 *  Init with nib name and bundle.
 *
 *  @param nibNameOrNil   nib name
 *  @param nibBundleOrNil nib bundle
 *
 *  @warning Unavailable. Use 'chatViewControllerWithChatDialog:' instead.
 *
 *  @return QMChatVC new instance.
 */
- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 *  Chat view controller with chat dialog.
 *
 *  @param chatDialog chat dialog
 *
 *  @return QMChatViewController new instance.
 */
+ (nullable instancetype)chatViewControllerWithChatDialog:(nonnull QBChatDialog *)chatDialog;

@end
