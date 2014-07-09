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
@property (nonatomic, assign) QBVideoChatConferenceType conferenceType;
@property (strong, nonatomic) NSString *currentSessionID;

@end

@implementation QMAVCallService

- (void)initActiveStreamWithOpponentView:(QBVideoView *)opponentView
                               sessionID:(NSString *)sessionID
                          conferenceType:(QBVideoChatConferenceType)conferenceType {
    
    if (sessionID == nil) {
        self.activeStream = [[QBChat instance] createWebRTCVideoChatInstance];
    } else {
        self.activeStream = [[QBChat instance] createAndRegisterWebRTCVideoChatInstanceWithSessionID:self.currentSessionID];
    }
    
    self.activeStream.currentConferenceType = conferenceType;
    self.activeStream.viewToRenderOpponentVideoStream = opponentView;
}

- (void)acceptCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView {
    
    [self initActiveStreamWithOpponentView:opponentView
                                 sessionID:self.currentSessionID
                            conferenceType:self.conferenceType];
    
//    self.activeStream.viewToRenderOpponentVideoStream.remotePlatform = self.customParams[qbvideochat_platform];
//    self.activeStream.viewToRenderOpponentVideoStream.remoteVideoOrientation = [QBChatUtils interfaceOrientationFromString:self.customParams[qbvideochat_device_orientation]];
//    
//    [self.activeStream acceptCallWithOpponentID:userID customParameters:self.customParams];
}

- (void)rejectCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView {
    
    [self initActiveStreamWithOpponentView:opponentView
                                 sessionID:self.currentSessionID
                            conferenceType:self.conferenceType];
    [self.activeStream rejectCallWithOpponentID:userID];
    [self releaseActiveStream];
}

- (void)releaseActiveStream {
    //Destroy active stream:
    [[QBChat instance] unregisterWebRTCVideoChatInstance:self.activeStream];
    
    [self clearCallsCacheParams];
}

- (void)callUser:(NSUInteger)userID
    opponentView:(QBVideoView *)opponentView
  conferenceType:(QBVideoChatConferenceType)conferenceType {
    
    [self initActiveStreamWithOpponentView:opponentView
                                 sessionID:nil
                            conferenceType:conferenceType];
    [self.activeStream callUser:userID];
}

- (void)cancelCall
{
    [self.activeStream finishCall];
    [self releaseActiveStream];
}

- (void)finishCall
{
    [self cancelCall];
}

#pragma mark - QBChatDelegate - Audio/Video Calls

// incoming call:
- (void)chatDidReceiveCallRequestFromUser:(NSUInteger)userID
                            withSessionID:(NSString *)sessionID
                           conferenceType:(QBVideoChatConferenceType)conferenceType
                         customParameters:(NSDictionary *)customParameters
{
//    self.customParams = customParameters;
//    self.currentSessionID = sessionID;
//    self.callType = conferenceType;
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kIncomingCallNotification object:nil userInfo:@{@"id" : @(userID), @"type" : @(conferenceType)}];
}

// user doesn't answer:
-(void) chatCallUserDidNotAnswer:(NSUInteger)userID
{
    [self releaseActiveStream];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:@{@"reason":kStopVideoChatCallStatus_OpponentDidNotAnswer}];
}

// call finished of canceled:
- (void)chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status {
    [self releaseActiveStream];
    
    NSString *stopCallReason = nil;
    if ([status isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]) {
        stopCallReason = kStopVideoChatCallStatus_OpponentDidNotAnswer;
    } else if ([status isEqualToString:kStopVideoChatCallStatus_Manually]) {
        stopCallReason = kStopVideoChatCallStatus_Manually;
    } else if ([status isEqualToString:kStopVideoChatCallStatus_Cancel]) {
        stopCallReason = kStopVideoChatCallStatus_Cancel;
    } else if ([status isEqualToString:kStopVideoChatCallStatus_BadConnection]) {
        stopCallReason = kStopVideoChatCallStatus_BadConnection;
    }
    
    if (status == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:@{@"reason":stopCallReason}];
}

- (void)clearCallsCacheParams {
    
//    self.customParams = nil;
//    self.currentSessionID = nil;
//    self.callType = 0;
}


// call accepted:
- (void)chatCallDidAcceptByUser:(NSUInteger)userID {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallDidAcceptByUserNotification object:nil];
}

// call started:
- (void)chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallDidStartedByUserNotification object:nil];
}

// call rejected:
- (void)chatCallDidRejectByUser:(NSUInteger)userID {
    [self releaseActiveStream];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasRejectedNotification object:nil];
}

@end
