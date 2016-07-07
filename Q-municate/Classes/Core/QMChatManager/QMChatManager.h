//
//  QMChatManager.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

@class QMChatLocationSnapshotter;

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents basic chat managing and tasks.
 */
@interface QMChatManager : QMBaseService

/**
 *  Chat location snapshotter.
 *
 *  @discussion Chat location snapshotter will be lazy loaded when first requested.
 */
@property (readonly, strong, nonatomic) QMChatLocationSnapshotter *chatLocationSnapshotter;

/**
 *  Disconnect from QBChat.
 *
 *  @return task with result
 */
- (BFTask *)disconnectFromChat;

/**
 *  Disconnect from chat if needed.
 *
 *  @discussion Use this method when disconnecting on app going background.
 *  By this chat will not disconnect if there is any active call.
 *
 *  @return task with result
 */
- (nullable BFTask *)disconnectFromChatIfNeeded;

/**
 *  Add users to group chat dialog and send notification message.
 *
 *  @param users      array of QBUUser instances
 *  @param chatDialog group chat dialog instance
 *
 *  @return task with result
 */
- (BFTask *)addUsers:(NSArray <QBUUser *> *)users toGroupChatDialog:(QBChatDialog *)chatDialog;

/**
 *  Change group chat dialog avatar and send notification message.
 *
 *  @param avatar     avatar image
 *  @param chatDialog chat dialog to update
 *
 *  @return task with result
 */
- (BFTask *)changeAvatar:(UIImage *)avatar forGroupChatDialog:(QBChatDialog *)chatDialog;

/**
 *  Change name for group chat dialog and send notification message.
 *
 *  @param name       new name for a specific group chat
 *  @param chatDialog chat dialog to update
 *
 *  @return task with result
 */
- (BFTask *)changeName:(NSString *)name forGroupChatDialog:(QBChatDialog *)chatDialog;

/**
 *  Leave group chat dialog and send notification message.
 *
 *  @param chatDialog group chat dialog to leave
 *
 *  @return task with result
 */
- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog;

@end

NS_ASSUME_NONNULL_END
