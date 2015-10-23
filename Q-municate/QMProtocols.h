//
//  QMProtocols.h
//  Q-municate
//
//  Created by Igor Alefirenko on 18.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//


@class QMTableViewCell;

#ifndef Q_municate_Protocols_h
#define Q_municate_Protocols_h

/**
 *  QMUsersListDelegate protocol
 */
@protocol QMUsersListDelegate <NSObject>
@optional

/**
 *  Is called when user clicked Add button on user cell
 *
 *  @param cell     cell that was clicked
 *  @param sender   button instance that was clicked
 */
- (void)usersListCell:(QMTableViewCell *)cell pressAddBtn:(UIButton *)sender;

@end

/**
 *  NotificationServiceDelegate protocol
 */
@protocol QMNotificationHandlerDelegate <NSObject>
@required

/**
 *  Is called when dialog fetching is complete and ready to return requested dialog
 *
 *  @param chatDialog QBChatDialog instance. Successfully fetched dialog
 */
- (void)notificationHandlerDidSucceedFetchingDialog:(QBChatDialog *)chatDialog;

@optional

/**
 *  Is called when dialog was not found nor in memory storage nor in cache
 *  and NotificationHandler started requesting dialog from server
 */
- (void)notificationHandlerDidStartLoadingDialogFromServer;

/**
 *  Is called when dialog request from server was completed
 */
- (void)notificationHandlerDidFinishLoadingDialogFromServer;

/**
 *  Is called when dialog was not found in both memory storage and cache
 *  and server request return nil
 */
- (void)notificationHandlerDidFailFetchingDialog;
@end


#endif
