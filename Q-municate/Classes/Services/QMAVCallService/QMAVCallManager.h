//
//  QMAVCallManager.h
//  Q-municate
//
//  Created by Anton Sokolchenko on 3/6/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMIncomingCallController.h"
#import <QMBaseService.h>

@interface QMAVCallManager : QMBaseService <QBRTCClientDelegate, UIAlertViewDelegate>

/** QBRTC **/
@property (strong, nonatomic) QBRTCSession *session;
@property (strong, nonatomic) QBRTCCameraCapture *cameraCapture;
@property (strong, nonatomic) QBRTCVideoTrack *remoteVideoTrack;

/** Custom properties **/
@property (assign, nonatomic, getter=isFrontCamera) BOOL frontCamera;
@property (assign, nonatomic, getter=isOpponentCaller) BOOL opponentCaller;

/**
 *  Indicates whether we have an active call or not
 */
@property (assign, nonatomic) BOOL hasActiveCall;

/** Call handling **/
- (void)acceptCall;
- (void)rejectCall;
- (void)hangUpCall;

/**
 *  Call to users with IDs.
 *
 *  @param users          array of QBUUser instances
 *  @param conferenceType QBConferenceType
 *  @param pushEnabled is user if offline he will receive a push notifications
 */
- (void)callToUsers:(NSArray *)users withConferenceType:(QBRTCConferenceType)conferenceType pushEnabled:(BOOL)pushEnabled;

/**
 *  Check permissions and show alert if permissions are denied.
 *
 *  @param conferenceType QBConferenceType
 */
- (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType completion:(void(^)(BOOL canContinue))completion;

/**
 *  If camera capture not exist allocating and starting session.
 */
- (void)startCameraCapture;

/**
 *  If camera capture exist stopping session and dellocating it.
 */
- (void)stopCameraCapture;

@end
