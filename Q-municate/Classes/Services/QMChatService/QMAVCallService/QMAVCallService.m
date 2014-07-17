//
//  QMAVCallService.m
//  Qmunicate
//
//  Created by Andrey on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAVCallService.h"
#import "QMChatReceiver.h"
#import "QMIncomingCallService.h"

@interface QMAVCallService()

@property (strong, nonatomic) QBWebRTCVideoChat *activeStream;
@property (nonatomic, assign) QBVideoChatConferenceType conferenceType;
@property (strong, nonatomic) NSString *currentSessionID;
@property (strong, nonatomic) NSDictionary *customParams;

@end

@implementation QMAVCallService

- (id)init
{
    if (self = [super init]) {
        [self subscribToNotifications];
    }
    return self;
}

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

- (void)acceptCallFromUser:(NSUInteger)userID andOpponentView:(QBVideoView *)opponentView {
    
    [self initActiveStreamWithOpponentView:opponentView
                                 sessionID:self.currentSessionID
                            conferenceType:self.conferenceType];
    
    self.activeStream.viewToRenderOpponentVideoStream.remotePlatform = self.customParams[qbvideochat_platform];
    self.activeStream.viewToRenderOpponentVideoStream.remoteVideoOrientation = [QBChatUtils interfaceOrientationFromString:self.customParams[qbvideochat_device_orientation]];
    
    [self.activeStream acceptCallWithOpponentID:userID customParameters:self.customParams];
}

- (void)rejectCallFromUser:(NSUInteger)userID andOpponentView:(QBVideoView *)opponentView {
    
    [self initActiveStreamWithOpponentView:opponentView
                                 sessionID:self.currentSessionID
                            conferenceType:self.conferenceType];
    [self.activeStream rejectCallWithOpponentID:userID];
    [self releaseActiveStream];
}

- (void)releaseActiveStream
{
    [[QBChat instance] unregisterWebRTCVideoChatInstance:self.activeStream];
    self.activeStream = nil;
}

- (void)callToUser:(NSUInteger)userID
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

- (void)finishCallFromOpponent
{
    [self cancelCall];
}


#pragma mark - Notifications

- (void)subscribToNotifications
{
    // incoming call signal:
    [[QMChatReceiver instance] chatDidReceiveCallRequestCustomParametesrWithTarget:self block:^(NSUInteger userID, NSString *sessionID, QBVideoChatConferenceType conferenceType, NSDictionary *customParameters) {
        self.customParams = customParameters;
        self.currentSessionID = sessionID;
        self.conferenceType = conferenceType;
    }];
    
    //call was rejected:
    [[QMChatReceiver instance] chatCallDidRejectByUserWithTarget:self block:^(NSUInteger userID) {
        [self releaseActiveStream];
    }];
    
    // call was stopped:
    [[QMChatReceiver instance] chatCallDidStopWithTarget:self block:^(NSUInteger userID, NSString *status) {
        [self releaseActiveStream];
    }];
}

@end
