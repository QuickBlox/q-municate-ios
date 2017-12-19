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

extern NSString * const QMVoipCallEventKey;

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

/**
 *  Notifies that active call state changed.
 *
 *  @param callManager         QMCallManager instance
 *  @param willHaveActiveCall  active call state
 */
- (void)callManager:(QMCallManager *)callManager willChangeActiveCallState:(BOOL)willHaveActiveCall;

/**
 *  Notifies when microphone state was changed from call kit.
 *
 *  @param callManager QMCallManager instance
 */
- (void)callManagerDidChangeMicrophoneState:(QMCallManager *)callManager;

/**
 *  Notifies that call was ended by callkit.
 *
 *  @param callManager QMCallManager instance
 */
- (void)callManagerCallWasEndedByCallKit:(QMCallManager *)callManager;

@end

/**
 *  QMCallManager class interface.
 *  Used as a basic manager for calls.
 */
@interface QMCallManager : QMBaseService

/**
 *  Add delegate (Multicast)
 *
 *  @param delegate Instance confirmed QMCallManagerDelegate protocol
 */
- (void)addDelegate:(id<QMCallManagerDelegate>)delegate;

/**
 *  Remove delegate from observed list
 *
 *  @param delegate Instance confirmed QMCallManagerDelegate protocol
 */
- (void)removeDelegate:(id<QMCallManagerDelegate>)delegate;

/**
 *  Determines whether callkit is available or not.
 */
@property (class, readonly, getter=isCallKitAvailable) BOOL callKitAvailable;

/**
 *  Current session.
 */
@property (strong, nonatomic, readonly, nullable) QBRTCSession *session;

/**
 *   Whether active call is in progress.
 */
@property (assign, nonatomic, readonly) BOOL hasActiveCall;

/**
 *  Current call UUID
 */
@property (strong, nonatomic, readonly, nullable) NSUUID *callUUID;

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

/**
 *  Performing call kit preparations.
 *
 *  @discussion When VOIP push received.
 */
- (void)performCallKitPreparations;

@end

NS_ASSUME_NONNULL_END
