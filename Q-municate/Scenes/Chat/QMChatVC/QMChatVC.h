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

@property (nonatomic) CGFloat additionalNavigationBarHeight;

/**
 *  Chat dialog.
 */
@property (strong, nonatomic, nullable) QBChatDialog *chatDialog;

/**
 *  Chat view controller with chat dialog.
 *
 *  @param chatDialog chat dialog
 *
 *  @return QMChatViewController new instance.
 */
+ (nullable instancetype)chatViewControllerWithChatDialog:(nullable QBChatDialog *)chatDialog;

@end

