//
//  QMBaseCallsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMBaseCallsController.h"
#import "QMChatReceiver.h"
#import "QMAVCallManager.h"

@implementation QMBaseCallsController
{
    QMAVCallManager *av;
    BOOL isRunning;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    av = [QMApi instance].avCallManager;
    if( av.session ){
        self.session = av.session;
    }
    
    [QBRTCClient.instance addDelegate:self];
    
    [self subscribeForNotifications];
    !self.isOpponentCaller ? [self startCall] : [self confirmCall];
    
    [self.contentView updateViewWithUser:self.opponent conferenceType:self.session.conferenceType];
    [self updateButtonsState];
}

- (void)updateButtonsState{
    [self.btnMic setSelected:!self.session.audioEnabled];
    [self.btnSwitchCamera setSelected:!av.isFrontCamera];
    [self.btnVideo setSelected:!self.session.videoEnabled];
    [self.btnSpeaker setSelected:av.isSpeakerEnabled];
    [self.camOffView setHidden:self.session.videoEnabled];
}

- (void)subscribeForNotifications {

}

#pragma mark - Override actions

// Override this method in child:
- (void)startCall{}

// Override this method in child:
- (void)confirmCall {
    [[QMApi instance] acceptCall];
}

- (IBAction)stopCallTapped:(id)sender {
    [self.contentView stopTimer];
    
    [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_CALL_WAS_STOPPED", nil)];
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    [QMSoundManager playEndOfCallSound];
    
    [[QMApi instance] finishCall];
    [self stopActivityIndicator];
}

- (void)startActivityIndicator {
    [self.activityIndicator setAlpha:1.0];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
}

- (void)stopActivityIndicator {
    [self.activityIndicator setAlpha:0.0];
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
}

#pragma mark - Calls notifications

// Override this method in child:
- (void)callAcceptedByUser {
}

// Override this method in child:
- (void)callStartedWithUser {
    
}

- (void)callRejectedByUser {
    [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_USER_IS_BUSY", nil)];
    [[QMSoundManager shared] stopAllSounds];
    [QMSoundManager playBusySound];
}

- (void)callStoppedByOpponentForReason:(NSString *)reason {
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    [self.contentView stopTimer];
    
    if ([reason isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]) {
        [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_USER_DOESNT_ANSWER", nil)];
        [QMSoundManager playBusySound];
    } else if ([reason isEqualToString:kStopVideoChatCallStatus_BadConnection]) {
        [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_BAD_CONNECTION", nil)];
        [QMSoundManager playEndOfCallSound];
    } else if ([reason isEqualToString:kStopVideoChatCallStatus_Manually]) {
        [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_USER_IS_BUSY", nil)];
        [QMSoundManager playEndOfCallSound];
    } else {
        [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_CALL_WAS_STOPPED", nil)];
        [QMSoundManager playEndOfCallSound];
    }
}

- (IBAction)speakerTapped:(id)sender {
    if( isRunning ){
        return;
    }
    isRunning = YES;
    [self.session switchAudioOutput:^(BOOL isSpeaker) {
        av.speakerEnabled = isSpeaker;
        [(IAButton *)sender setSelected:isSpeaker];
        isRunning = NO;
    }];
}

- (IBAction)cameraSwitchTapped:(id)sender {
    if( isRunning ){
        return;
    }
    isRunning = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.session switchCamera:^(BOOL isFrontCamera) {
            av.frontCamera = isFrontCamera;
            [(IAButton *)sender setSelected:!isFrontCamera];
            isRunning = NO;
        }];
    });
}

- (IBAction)muteTapped:(id)sender {
    [self.session setAudioEnabled:!self.session.audioEnabled];
    [(IAButton *)sender setSelected:!self.session.audioEnabled];
}

- (IBAction)videoTapped:(id)sender {
    [self.session setVideoEnabled:!self.session.videoEnabled];
    [(IAButton *)sender setSelected:!self.session.videoEnabled];
}

- (void)dealloc {
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    [QBRTCClient.instance removeDelegate:self];
}

#pragma mark QBRTCSession delegate -

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    ILog(@"connectedToUser:%@", userID);
    [self.contentView startTimerIfNeeded];
}

- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID {
    ILog(@"disconnectedFromUser:%@", userID);
}

- (void)session:(QBRTCSession *)session disconnectTimeoutForUser:(NSNumber *)userID {
    ILog(@"disconnectTimeoutForUser:%@", userID);
}

- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_Manually];
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID {
    [self.contentView stopTimer];
    [self stopActivityIndicator];
    [self callStoppedByOpponentForReason:nil];
}

- (void)sessionWillClose:(QBRTCSession *)session {
    QBRTCConnectionState state = [session connectionStateForUser:@(self.opponent.ID)];
    
    if( state == QBRTCConnectionFailed ){
        [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_BadConnection];
    }
    else if( state == QBRTCConnectionRejected ){
        [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_Manually];
    }
    else if( state == QBRTCConnectionNoAnswer ){
        [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_OpponentDidNotAnswer];
    }
    else if( state != QBRTCConnectionUnknow ){
        [self callStoppedByOpponentForReason:nil];
    }
}

- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack {
    self.localVideoTrack = videoTrack;
}

- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    self.opponentVideoTrack = videoTrack;
}

@end
