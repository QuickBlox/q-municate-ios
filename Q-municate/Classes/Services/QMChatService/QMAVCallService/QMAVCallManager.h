//
//  QMAVCallManager.h
//  Q-municate
//
//  Created by Anton Sokolchenko on 3/6/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMIncomingCallController.h"
#import "QMBaseService.h"

@interface QMAVCallManager : QMBaseService <QBRTCClientDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) QBRTCSession *session;

@property (assign, nonatomic, getter=isFrontCamera) BOOL frontCamera;
@property (assign, nonatomic, getter=isSpeakerEnabled) BOOL speakerEnabled;

@property (strong, nonatomic) QBRTCVideoTrack *localVideoTrack;
@property (strong, nonatomic) QBRTCVideoTrack *remoteVideoTrack;

- (void)acceptCall;
- (void)rejectCall;
- (void)hangUpCall;

/**
 *  call to users ids
 *
 *  @param users          array of QBUUser instances
 *  @param conferenceType QBConferenceType
 *  @param pushEnabled is user if offline he will receive a push notifications
 */
- (void)callToUsers:(NSArray *)users withConferenceType:(QBConferenceType)conferenceType pushEnabled:(BOOL)pushEnabled;

/**
 *  check permissions and show alert if permissions are denied
 *
 *  @param conferenceType QBConferenceType
 */
- (void)checkPermissionsWithConferenceType:(QBConferenceType)conferenceType completion:(void(^)(BOOL canContinue))completion;

@end
