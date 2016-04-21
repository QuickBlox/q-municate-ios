//
//  QMChatManager.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  This class represents basic chat managing and tasks.
 */
@interface QMChatManager : QMBaseService

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
- (BFTask *)disconnectFromChatIfNeeded;

/**
 *  Add users to group chat dialog.
 *
 *  @param users      array of QBUUser instances
 *  @param chatDialog group chat dialog instance
 *
 *  @return task with result
 */
- (BFTask *)addUsers:(NSArray <QBUUser *> *)users toGroupChatDialog:(QBChatDialog *)chatDialog;

/**
 *  Leave group chat dialog and send notification in it.
 *
 *  @param chatDialog group chat dialog to leave
 *
 *  @return task with result
 */
- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog;

@end

NS_ASSUME_NONNULL_END
