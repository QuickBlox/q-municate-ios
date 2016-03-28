//
//  QMChatVC.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/9/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Chat view controller.
 */
@interface QMChatVC : QMChatViewController

/**
 *  Chat dialog.
 */
@property (strong, nonatomic) QBChatDialog *chatDialog;

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

/**
 *  Chat view controller with chat dialog.
 *
 *  @param chatDialog chat dialog
 *
 *  @return QMChatViewController new instance.
 */
+ (nullable instancetype)chatViewControllerWithChatDialog:(QBChatDialog *)chatDialog;

@end

NS_ASSUME_NONNULL_END
