//
//  QMCallManager.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

#import "QBChatMessage+QMCallNotifications.h"

@class QMCallManager;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QMCallManagerDelegate protocol. Used to notify about session updates.
 */
@protocol QMCallManagerDelegate <NSObject>

/**
 *  Protocol methods down below are required to be implemented
 */
@required

/**
 *  Notifying about current session been closed.
 *
 *  @param callManager QMCallManager instance
 *  @param session     current session to close
 */
- (void)callManager:(QMCallManager *)callManager willCloseCurrentSession:(QBRTCSession *)session;

@end

/**
 *  QMCallManager class interface.
 *  Used as a basic manager for calls.
 */
@interface QMCallManager : QMBaseService

/**
 *  Delegate instance that conforms to QMCallManagerDelegate protocol.
 */
@property (weak, nonatomic, nullable) id<QMCallManagerDelegate> delegate;

/**
 *  Current session.
 */
@property (strong, nonatomic, readonly, nullable) QBRTCSession *session;

/**
 *   Whether active call is in progress.
 */
@property (assign, nonatomic, readonly) BOOL hasActiveCall;

/**
 *  Call to user with ID and conference type.
 *
 *  @param userID         user ID to call
 *  @param conferenceType QBRTCConferenceType value
 */
- (void)callToUserWithID:(NSUInteger)userID conferenceType:(QBRTCConferenceType)conferenceType;

/**
 *  Current opponent user.
 *
 *  @return Current opponent user if session exists
 */
- (nullable QBUUser *)opponentUser;

/**
 *  List of quickblox ICE servers.
 *
 *  @return Array of quickblox ICE servers
 */
- (NSArray *)quickbloxICE;

/**
 *  Stop all active sounds and its timers.
 */
- (void)stopAllSounds;

/**
 *  Send call notification message with state.
 *
 *  @param state    call notification state
 *  @param duration call duration if needed
 */
- (void)sendCallNotificationMessageWithState:(QMCallNotificationState)state duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
