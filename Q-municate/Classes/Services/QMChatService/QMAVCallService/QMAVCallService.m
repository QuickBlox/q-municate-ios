//
//  QMAVCallService.m
//  Qmunicate
//
//  Created by Andrey on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAVCallService.h"

@interface QMAVCallService()

@property (strong, nonatomic) QBWebRTCVideoChat *activeStream;
@property (nonatomic, assign) int callType;
@property (strong, nonatomic) NSString *currentSessionID;

@end

@implementation QMAVCallService


#pragma mark -
#pragma mark Video Chat

/**
 Called in case when opponent is calling to you
 
 @param userID ID of uopponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
 */
-(void) chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString*)sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType {
    
}

/**
 Called in case when opponent is calling to you
 
 @param userID ID of uopponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
 @param customParameters Custom caller parameters
 */
-(void)chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString*)sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType customParameters:(NSDictionary *)customParameters {
    
}

/**
 Called in case when you are calling to user, but hi hasn't answered
 
 @param userID ID of opponent
 */
-(void) chatCallUserDidNotAnswer:(NSUInteger)userID {
    
}

/**
 Called in case when opponent has accepted you call
 
 @param userID ID of opponent
 */
- (void) chatCallDidAcceptByUser:(NSUInteger)userID {
    
}

/**
 Called in case when opponent has accepted you call
 
 @param userID ID of opponent
 @param customParameters Custom caller parameters
 */
-(void) chatCallDidAcceptByUser:(NSUInteger)userID customParameters:(NSDictionary *)customParameters {
    
}

/**
 Called in case when opponent has rejected you call
 
 @param userID ID of opponent
 */
-(void) chatCallDidRejectByUser:(NSUInteger)userID {
    
}

/**
 Called in case when opponent has finished call
 
 @param userID ID of opponent
 @param status Reason of finish call. There are 2 reasons: 1) Opponent did not answer - 'kStopVideoChatCallStatus_OpponentDidNotAnswer'. 2) Opponent finish call with method 'finishCall' - 'kStopVideoChatCallStatus_Manually'
 */
- (void) chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status {
    
}

/**
 Called in case when opponent has finished call
 
 @param userID ID of opponent
 @param status Reason of finish call. There are 2 reasons: 1) Opponent did not answer - 'kStopVideoChatCallStatus_OpponentDidNotAnswer'. 2) Opponent finish call with method 'finishCall' - 'kStopVideoChatCallStatus_Manually'
 @param customParameters Custom caller parameters
 */
- (void) chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status customParameters:(NSDictionary *)customParameters {
    
}

/**
 Called in case when call has started
 
 @param userID ID of opponent
 @param sessionID ID of session
 */
-(void) chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID {
    
}

/**
 Called in case when start using TURN relay for video chat (not p2p).
 */
- (void)didStartUseTURNForVideoChat {
    
}

//
//- (void)initActiveStreamWithOpponentView:(QBVideoView *)opponentView sessionID:(NSString *)sessionID callType:(QMVideoChatType)type {
//    // Active stream initialize:
//    if (sessionID == nil)
//    {
//        self.activeStream = [[QBChat instance] createWebRTCVideoChatInstance];
//    } else {
//        self.activeStream = [[QBChat instance] createAndRegisterWebRTCVideoChatInstanceWithSessionID:self.currentSessionID];
//    }
//    // set conference type:
//    self.activeStream.currentConferenceType = (int)type;
//    
//    // set opponent' view
//    self.activeStream.viewToRenderOpponentVideoStream = opponentView;
//}
//
//- (void)acceptCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView
//{
//    [self initActiveStreamWithOpponentView:opponentView sessionID:self.currentSessionID callType:self.callType];
//    
//    self.activeStream.viewToRenderOpponentVideoStream.remotePlatform = self.customParams[qbvideochat_platform];
//    self.activeStream.viewToRenderOpponentVideoStream.remoteVideoOrientation = [QBChatUtils interfaceOrientationFromString:self.customParams[qbvideochat_device_orientation]];
//    
//    [self.activeStream acceptCallWithOpponentID:userID customParameters:self.customParams];
//}
//
//- (void)rejectCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView
//{
//    [self initActiveStreamWithOpponentView:opponentView sessionID:self.currentSessionID callType:self.callType];
//    [self.activeStream rejectCallWithOpponentID:userID];
//    [self releaseActiveStream];
//}
//
//
//- (void)releaseActiveStream
//{
//    //Destroy active stream:
//    [[QBChat instance] unregisterWebRTCVideoChatInstance:self.activeStream];
//    
//    [self clearCallsCacheParams];
//}
//
//- (void)callUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView callType:(QMVideoChatType)callType
//{
//    [self initActiveStreamWithOpponentView:opponentView sessionID:nil callType:callType];
//    [self.activeStream callUser:userID];
//}
//
//- (void)cancelCall
//{
//    [self.activeStream finishCall];
//    [self releaseActiveStream];
//}
//
//- (void)finishCall
//{
//    [self cancelCall];
//}
//
//#pragma mark - QBChatDelegate - Audio/Video Calls
//
//// incoming call:
//- (void)chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString *)_sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType customParameters:(NSDictionary *)customParameters
//{
//    self.customParams = customParameters;
//    self.currentSessionID = _sessionID;
//    self.callType = (NSUInteger)conferenceType;
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kIncomingCallNotification object:nil userInfo:@{@"id" : @(userID), @"type" : @(conferenceType)}];
//}
//
//// user doesn't answer:
//-(void) chatCallUserDidNotAnswer:(NSUInteger)userID
//{
//    [self releaseActiveStream];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:@{@"reason":kStopVideoChatCallStatus_OpponentDidNotAnswer}];
//}
//
//// call finished of canceled:
//- (void)chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status
//{
//    [self releaseActiveStream];
//    
//    NSString *stopCallReason = nil;
//    if ([status isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]) {
//        stopCallReason = kStopVideoChatCallStatus_OpponentDidNotAnswer;
//    } else if ([status isEqualToString:kStopVideoChatCallStatus_Manually]) {
//        stopCallReason = kStopVideoChatCallStatus_Manually;
//    } else if ([status isEqualToString:kStopVideoChatCallStatus_Cancel]) {
//        stopCallReason = kStopVideoChatCallStatus_Cancel;
//    } else if ([status isEqualToString:kStopVideoChatCallStatus_BadConnection]) {
//        stopCallReason = kStopVideoChatCallStatus_BadConnection;
//    }
//    
//    if (status == nil) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:nil];
//        return;
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:@{@"reason":stopCallReason}];
//}
//
//- (void)clearCallsCacheParams
//{
//    self.customParams = nil;
//    self.currentSessionID = nil;
//    self.callType = 0;
//}
//
//
//// call accepted:
//- (void)chatCallDidAcceptByUser:(NSUInteger)userID
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kCallDidAcceptByUserNotification object:nil];
//}
//
//// call started:
//- (void)chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:kCallDidStartedByUserNotification object:nil];
//}
//
//// call rejected:
//- (void)chatCallDidRejectByUser:(NSUInteger)userID
//{
//    [self releaseActiveStream];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasRejectedNotification object:nil];
//}



@end
