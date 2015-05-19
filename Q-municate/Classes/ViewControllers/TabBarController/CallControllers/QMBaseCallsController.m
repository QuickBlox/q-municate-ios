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
    AVAudioSessionCategoryOptions categoryOptions;
    AVAudioSessionCategoryOptions defaultCategoryOptions;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnSpeaker.userInteractionEnabled = NO;

    if( QMApi.instance.avCallManager.session ){
        self.session = QMApi.instance.avCallManager.session;
    }
    [QBRTCClient.instance addDelegate:self];
    
    [self subscribeForNotifications];
    !self.isOpponentCaller ? [self startCall] : [self confirmCall];
    
    [self.contentView updateViewWithUser:self.opponent conferenceType:self.session.conferenceType isOpponentCaller:self.isOpponentCaller];
    [self updateButtonsState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionRouteChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
}

- (void)audioSessionRouteChanged:(NSNotification *)notification {
    
}

- (void)updateButtonsState {
    [self.btnMic setSelected:!self.session.audioEnabled];
    [self.btnSwitchCamera setSelected:!QMApi.instance.avCallManager.isFrontCamera];
    [self.btnSwitchCamera setUserInteractionEnabled:self.session.videoEnabled];
    [self.btnVideo setSelected:!self.session.videoEnabled];
    [self.btnSpeaker setSelected:[[AVAudioSession sharedInstance] categoryOptions] == AVAudioSessionCategoryOptionDefaultToSpeaker];
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
    [[QMApi instance] finishCall];
    [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_CALL_WAS_STOPPED", nil)];
    // stop playing sound:
    [[QMSoundManager instance] stopAllSounds];
    
    // need a delay to give a time to a WebRTC to unload resources
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [QMSoundManager playEndOfCallSound];
    });
    
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
- (void)callStartedWithUser {
    
}

- (void)callStoppedByOpponentForReason:(NSString *)reason {
    // stop playing sound:
    [[QMSoundManager instance] stopAllSounds];
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

- (IBAction)speakerTapped:(IAButton *)sender {

    AVAudioSessionCategoryOptions currentOptions = [[AVAudioSession sharedInstance] categoryOptions];
    //IPAD
    if (currentOptions != AVAudioSessionCategoryOptionDefaultToSpeaker) {
        categoryOptions = AVAudioSessionCategoryOptionDefaultToSpeaker;
        [sender setSelected:YES];
    }
    else {
        categoryOptions = 0;
        [sender setSelected:NO];
    }
    
    [[[QMApi instance] avCallManager] setAvSessionCurrentCategoryOptions:categoryOptions];
}

- (IBAction)cameraSwitchTapped:(IAButton *)sender {

    [self.session switchCamera:^(BOOL isFrontCamera) {
        QMApi.instance.avCallManager.frontCamera = isFrontCamera;
        [sender setSelected:!isFrontCamera];
    }];
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
    self.btnSpeaker.userInteractionEnabled = YES;
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
    if( [userID unsignedIntegerValue] != [[[QMApi instance] currentUser] ID]) {
        // current user not initiated end of call
        [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_Manually];
    }
    else{
         [self callStoppedByOpponentForReason:nil];
    }
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo{
    [self.contentView stopTimer];
    [self stopActivityIndicator];
    [self callStoppedByOpponentForReason:nil];
}

- (void)sessionWillClose:(QBRTCSession *)session {
    
    if( self.session != session ){
        return;
    }
    
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
    else if( state != QBRTCConnectionUnknow && state != QBRTCConnectionClosed ){
        [self callStoppedByOpponentForReason:nil];
    }
}

- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack {
    self.localVideoTrack = videoTrack;
}

- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    self.opponentVideoTrack = videoTrack;
}

- (void)sessionDidClose:(QBRTCSession *)session {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

@end
