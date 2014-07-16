//
//  QMBaseCallsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMBaseCallsController.h"
#import "QMChatReceiver.h"


@implementation QMBaseCallsController


#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self subscribeForNotifications];
    
    if (!_isOpponentCaller) {
        [self startCall];
    } else {
        [self confirmCall];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.opponentsView.backgroundColor = [UIColor clearColor];
    [self.contentView updateViewWithUser:self.opponent];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)subscribeForNotifications
{
    /** CALL WAS ACCEPTED */
    [[QMChatReceiver instance] chatCallDidAcceptWithTarget:self block:^(NSUInteger userID) {
        [self callAcceptedByUser];
    }];
    
    /** CALL WAS STARTED */
    [[QMChatReceiver instance] chatCallDidStartWithTarget:self block:^(NSUInteger userID, NSString *sessionID) {
        [self callStartedWithUser];
    }];
    
    /** CALL WAS REJECTED */
    [[QMChatReceiver instance] chatCallDidRejectByUserWithTarget:self block:^(NSUInteger userID) {
        [self callRejectedByUser];
    }];
    
    /** CALL WAS STOPPED */
    [[QMChatReceiver instance] chatCallDidStopWithTarget:self block:^(NSUInteger userID, NSString *status) {
        [self callStoppedByOpponentForReason:status];
    }];
}


#pragma mark - Override actions

- (void)startCall
{
    // Override this method in child:
}

- (void)confirmCall
{
    [[QMApi instance] acceptCallFromUser:self.opponent.ID opponentView:self.opponentsView];
    // Override this method in child:
}

- (IBAction)leftControlTapped:(id)sender
{
    // Override this method in child:
}

- (IBAction)rightControlTapped:(id)sender
{
    // Override this method in child:
}

- (IBAction)stopCallTapped:(id)sender
{
    [[QMApi instance] finishCall];
    
    [self.contentView updateViewWithStatus:kCallWasStoppedByUserStatus];
    
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    
    self.opponentsView.hidden = YES;
    [QMSoundManager playEndOfCallSound];
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:1.0f];
}


#pragma mark - Calls notifications

- (void)callAcceptedByUser
{
    // Override this method in child:
}

- (void)callStartedWithUser
{
    // Override this method in child:
}

- (void)callRejectedByUser
{
    self.opponentsView.hidden = YES;
    
    [self.contentView updateViewWithStatus:kUserIsBusyStatus];
    [[QMSoundManager shared] stopAllSounds];
    [QMSoundManager playBusySound];
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:2.0f];
}

- (void)callStoppedByOpponentForReason:(NSString *)reason
{
#warning Refactor this:
    self.opponentsView.hidden = YES;
    
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];

    if ([reason isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]) {
        [self.contentView updateViewWithStatus:kUserDoesntAnswerStatus];
        [QMSoundManager playBusySound];
    } else if ([reason isEqualToString:kStopVideoChatCallStatus_BadConnection]) {
        [self.contentView updateViewWithStatus:kCallBadConnectionStatus];
        [QMSoundManager playEndOfCallSound];
    } else if ([reason isEqualToString:kStopVideoChatCallStatus_Manually]) {
        [self.contentView updateViewWithStatus:kUserIsBusyStatus];
        [QMSoundManager playEndOfCallSound];
    } else {
        [self.contentView updateViewWithStatus:kCallWasStoppedByUserStatus];
        [QMSoundManager playEndOfCallSound];
    }
    
    [self dismissCallsController];
}

- (void)dismissCallsController
{
    [[QMSoundManager shared] stopAllSounds];
    
    if (_isOpponentCaller) {
        [QMIncomingCallService.shared hideIncomingCallControllerWithStatus:nil];
        return;
    }
    [self performSelector:@selector(dismissViewControllerAnimated:completion:) withObject:self afterDelay:2.0f];
}

@end
