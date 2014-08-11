//
//  QMAudioCallController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAudioCallController.h"

@interface QMAudioCallController ()

@end

@implementation QMAudioCallController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Overriden actions

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
    [[QMApi instance] callUser:self.opponent.ID opponentView:self.opponentsView conferenceType:QBVideoChatConferenceTypeAudio];
    [QMSoundManager playCallingSound];
}

- (void)confirmCall {
    
    [super confirmCall];
    [self startCallDurationTimer];
}

#pragma mark - Protocol

- (void)callAcceptedByUser {
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    [self callStartedWithUser];
}

- (void)callStartedWithUser {
    
    [self startCallDurationTimer];
}

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

@end
