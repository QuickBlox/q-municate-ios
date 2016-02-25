//
//  QMBaseCallsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMBaseCallsController.h"
#import "QMAVCallManager.h"


@implementation QMBaseCallsController
{
    AVAudioSessionCategoryOptions categoryOptions;
    AVAudioSessionCategoryOptions defaultCategoryOptions;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[QBRTCClient instance] addDelegate:self];
    
    self.btnSpeaker.userInteractionEnabled = NO;

    if( [QMApi instance].avCallManager.session ){
        self.session = [QMApi instance].avCallManager.session;
    }
    
    if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
        [[QMApi instance].avCallManager startCameraCapture];
    }
    
    [self.contentView updateViewWithUser:self.opponent conferenceType:self.session.conferenceType isOpponentCaller:[[QMApi instance].avCallManager isOpponentCaller]];
}

- (void)updateButtonsState {
    [self.btnMic setSelected:!self.session.localMediaStream.audioTrack.enabled];
    [self.btnSwitchCamera setSelected:!QMApi.instance.avCallManager.isFrontCamera];
    [self.btnSwitchCamera setUserInteractionEnabled:self.session.localMediaStream.videoTrack.enabled];
    [self.btnVideo setSelected:!self.session.localMediaStream.videoTrack.enabled];
    [self.btnSpeaker setSelected:[[AVAudioSession sharedInstance] categoryOptions] == AVAudioSessionCategoryOptionDefaultToSpeaker];
    [self.camOffView setHidden:self.session.localMediaStream.videoTrack.enabled];
}

#pragma mark - Override actions

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

	QBRTCSoundRouter *router = [QBRTCSoundRouter instance];
	QBRTCSoundRoute  currentRoute = [router currentSoundRoute];
	
	sender.selected =  currentRoute == QBRTCSoundRouteSpeaker;
	
	if( currentRoute == QBRTCSoundRouteSpeaker ){
		[router setCurrentSoundRoute:QBRTCSoundRouteReceiver];
	}
	else{
		[router setCurrentSoundRoute:QBRTCSoundRouteSpeaker];
	}
}

- (IBAction)cameraSwitchTapped:(IAButton *)sender {

    AVCaptureDevicePosition position = [[QMApi instance].avCallManager.cameraCapture currentPosition];
    AVCaptureDevicePosition newPosition = position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    
    if ([[QMApi instance].avCallManager.cameraCapture hasCameraForPosition:newPosition]) {
        
        if (newPosition == AVCaptureDevicePositionFront) {
            
            [QMApi instance].avCallManager.frontCamera = YES;
        }
        else if(newPosition == AVCaptureDevicePositionBack) {
            
            [QMApi instance].avCallManager.frontCamera = NO;
        }
        
        [[QMApi instance].avCallManager.cameraCapture selectCameraPosition:newPosition];
    }

    [sender setSelected:![QMApi instance].avCallManager.frontCamera];
}

- (IBAction)muteTapped:(id)sender {
    [self.session.localMediaStream.audioTrack setEnabled:!self.session.localMediaStream.audioTrack.enabled];
    [(IAButton *)sender setSelected:!self.session.localMediaStream.audioTrack.enabled];
}

- (IBAction)videoTapped:(id)sender {
    [self.session.localMediaStream.videoTrack setEnabled:!self.session.localMediaStream.videoTrack.enabled];
    
    [(IAButton *)sender setSelected:!self.session.localMediaStream.videoTrack.enabled];
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

- (void)session:(QBRTCSession *)session disconnectedByTimeoutFromUser:(NSNumber *)userID {
    ILog(@"disconnectTimeoutForUser:%@", userID);
}

- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo {
    
    if (session == self.session) {
        if( [userID unsignedIntegerValue] != [[[QMApi instance] currentUser] ID]) {
            // current user not initiated end of call
            [self callStoppedByOpponentForReason:kStopVideoChatCallStatus_Manually];
        }
        else{
            [self callStoppedByOpponentForReason:nil];
        }
    }
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo{
    
    if (session == self.session) {
        [self.contentView stopTimer];
        [self stopActivityIndicator];
        [self callStoppedByOpponentForReason:nil];
    }
}

- (void)sessionDidClose:(QBRTCSession *)session {
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
    else if( state != QBRTCConnectionUnknown && state != QBRTCConnectionClosed ){
        [self callStoppedByOpponentForReason:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream {
    self.btnMic.enabled = YES;
    [self updateButtonsState];
}

@end
