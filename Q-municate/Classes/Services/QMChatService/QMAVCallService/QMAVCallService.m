//
//  QMAVCallService.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAVCallService.h"
#import "QMChatReceiver.h"

@interface QMAVCallService()

@property (strong, nonatomic) QBWebRTCVideoChat *activeStream;
@property (nonatomic, assign) enum QBVideoChatConferenceType conferenceType;
@property (strong, nonatomic) NSString *currentSessionID;
@property (strong, nonatomic) NSDictionary *customParams;

@end

@implementation QMAVCallService

- (void)start {
    
    [super start];
    
    __weak typeof(self) weakSelf = self;
    // incoming call signal:
    [[QMChatReceiver instance] chatDidReceiveCallRequestCustomParametesrWithTarget:self block:^(NSUInteger userID, NSString *sessionID, enum QBVideoChatConferenceType conferenceType, NSDictionary *customParameters) {
        weakSelf.customParams = customParameters;
        weakSelf.currentSessionID = sessionID;
        weakSelf.conferenceType = conferenceType;
    }];
    
    //call was rejected:
    [[QMChatReceiver instance] chatCallDidRejectByUserWithTarget:self block:^(NSUInteger userID) {
        [weakSelf releaseActiveStream];
    }];
    
    // call was stopped:
    [[QMChatReceiver instance] chatCallDidStopCustomParametersWithTarget:self block:^(NSUInteger userID, NSString *status, NSDictionary *customParameters) {
        [weakSelf releaseActiveStream];
    }];
}

- (void)stop {
    [super stop];
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
}

- (void)initActiveStreamWithOpponentView:(QBVideoView *)opponentView sessionID:(NSString *)sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType {
    
    if (sessionID == nil) {
        self.activeStream = [[QBChat instance] createWebRTCVideoChatInstance];
    } else {
        self.activeStream = [[QBChat instance] createAndRegisterWebRTCVideoChatInstanceWithSessionID:self.currentSessionID];
    }
    
    self.activeStream.currentConferenceType = conferenceType;
    self.activeStream.viewToRenderOpponentVideoStream = opponentView;
}

- (void)acceptCallFromUser:(NSUInteger)userID andOpponentView:(QBVideoView *)opponentView {
    
    [self initActiveStreamWithOpponentView:opponentView  sessionID:self.currentSessionID conferenceType:self.conferenceType];
    
    self.activeStream.viewToRenderOpponentVideoStream.remotePlatform = self.customParams[qbvideochat_platform];
    self.activeStream.viewToRenderOpponentVideoStream.remoteVideoOrientation = [QBChatUtils interfaceOrientationFromString:self.customParams[qbvideochat_device_orientation]];
    
    [self.activeStream acceptCallWithOpponentID:userID customParameters:self.customParams];
}

- (void)rejectCallFromUser:(NSUInteger)userID andOpponentView:(QBVideoView *)opponentView {
    
    [self initActiveStreamWithOpponentView:opponentView sessionID:self.currentSessionID conferenceType:self.conferenceType];
    [self.activeStream rejectCallWithOpponentID:userID];
    [self releaseActiveStream];
}

- (void)releaseActiveStream
{
    [[QBChat instance] unregisterWebRTCVideoChatInstance:self.activeStream];
    self.activeStream = nil;
}

- (void)callToUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView conferenceType:(enum QBVideoChatConferenceType)conferenceType
{
    [self initActiveStreamWithOpponentView:opponentView
                                 sessionID:nil
                            conferenceType:conferenceType];
    [self.activeStream callUser:userID];
}

- (void)cancelCall {
    
    [self.activeStream cancelCall];
    [self releaseActiveStream];
}

- (void)finishCallFromOpponent {
    
    [self cancelCall];
}

@end
