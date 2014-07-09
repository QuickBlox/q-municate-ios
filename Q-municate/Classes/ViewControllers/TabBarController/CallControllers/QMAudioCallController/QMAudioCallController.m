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


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Overriden actions

- (IBAction)leftControlTapped:(id)sender
{
    //
}

- (IBAction)rightControlTapped:(id)sender
{
    //
}

- (IBAction)stopCallTapped:(id)sender
{
    [super stopCallTapped:sender];
    [self stopCallDurationTimer];
}


#pragma mark - Overriden methods

-(void)startCall
{
//    [[QMChatService shared] callUser:self.opponent.ID opponentView:self.opponentsView callType:QBVideoChatConferenceTypeAudio];
    [QMSoundManager playCallingSound];
}

-(void)confirmCall
{
    [super confirmCall];
    [self startCallDurationTimer];
}


#pragma mark - Protocol

- (void)callAcceptedByUser
{
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    [self callStartedWithUser];
}

- (void)callStartedWithUser
{
    [self startCallDurationTimer];
}

- (void)callStoppedByOpponentForReason:(NSNotification *)notification
{
    [self stopCallDurationTimer];
    [super callStoppedByOpponentForReason:notification];
}

- (void)startCallDurationTimer
{
    [self.contentView startTimer];
}

- (void)stopCallDurationTimer
{
    [self.contentView stopTimer];
}

@end
