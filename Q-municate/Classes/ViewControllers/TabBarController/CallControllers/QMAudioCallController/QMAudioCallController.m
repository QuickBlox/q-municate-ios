//
//  QMAudioCallController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAudioCallController.h"

@interface QMAudioCallController ()<QBRTCClientDelegate>

@end

@implementation QMAudioCallController

- (void)viewDidLoad {
    [super viewDidLoad];
    [QBRTCClient.instance addDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Overridden actions

- (IBAction)leftControlTapped:(id)sender {
    //
}

- (IBAction)rightControlTapped:(id)sender {
    //
}

- (IBAction)stopCallTapped:(id)sender {
    [self stopCallDurationTimer];
    [super stopCallTapped:sender];
}

#pragma mark - Overriden methods

- (void)startCall {
    [[QMApi instance] callToUser:self.opponentID conferenceType:QBConferenceTypeAudio];
    [QMSoundManager playCallingSound];
}

- (void)confirmCall {
    
    [super confirmCall];
    [self startCallDurationTimer];
}

#pragma mark - Protocol

- (void)callStoppedByOpponentForReason:(NSString *)reason {
    
    [self stopCallDurationTimer];
    [super callStoppedByOpponentForReason:reason];
}

- (void)startCallDurationTimer {
    
    [self.contentView startTimer];
}

- (void)stopCallDurationTimer {
    
    [self.contentView stopTimer];
}

#pragma mark QBRTCSession delegate -

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID{
    [[QMSoundManager shared] stopAllSounds];
    [self startCallDurationTimer];
}

- (void)session:(QBRTCSession *)session disconnectTimeoutForUser:(NSNumber *)userID{
    [super callStoppedByOpponentForReason:kStopVideoChatCallStatus_OpponentDidNotAnswer];
}

- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)userID userInfo:(NSDictionary *)userInfo{
    [super callStoppedByOpponentForReason:kStopVideoChatCallStatus_Manually];
}

- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)userID{
    [self stopCallDurationTimer];
    [super callStoppedByOpponentForReason:nil];
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)userID{
    [self stopCallDurationTimer];
    [super callStoppedByOpponentForReason:nil];
}

- (void)dealloc{
    [QBRTCClient.instance removeDelegate:self];
}
@end
