//
//  QMBaseCallsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMBaseCallsController.h"
#import "QMChatReceiver.h"
#import "AppDelegate.h"


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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.opponentsView.backgroundColor = [UIColor clearColor];
    [self.contentView updateViewWithUser:self.opponent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)subscribeForNotifications
{
    __weak typeof(self) weakSelf = self;
    
    /** CALL WAS ACCEPTED */
    [[QMChatReceiver instance] chatCallDidAcceptCustomParametersWithTarget:self block:^(NSUInteger userID, NSDictionary *customParameters) {
        [weakSelf callAcceptedByUser];
    }];
    
    /** CALL WAS STARTED */
    [[QMChatReceiver instance] chatCallDidStartWithTarget:self block:^(NSUInteger userID, NSString *sessionID) {
        [weakSelf callStartedWithUser];
    }];
    
    /** CALL WAS REJECTED */
    [[QMChatReceiver instance] chatCallDidRejectByUserWithTarget:self block:^(NSUInteger userID) {
        [weakSelf callRejectedByUser];
    }];
    
    /** CALL WAS STOPPED */
    [[QMChatReceiver instance] chatCallDidStopCustomParametersWithTarget:self block:^(NSUInteger userID, NSString *status, NSDictionary *customParameters) {
        [weakSelf callStoppedByOpponentForReason:status];
    }];
}

#pragma mark - Override actions

// Override this method in child:
- (void)startCall{}

// Override this method in child:
- (void)confirmCall {
    [[QMApi instance] acceptCallFromUser:self.opponent.ID opponentView:self.opponentsView];
}

// Override this method in child:
- (IBAction)leftControlTapped:(id)sender {}

// Override this method in child:
- (IBAction)rightControlTapped:(id)sender {}

- (IBAction)stopCallTapped:(id)sender {

    [[QMApi instance] finishCall];
    
    [self.contentView updateViewWithStatus:kCallWasStoppedByUserStatus];
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    
    self.opponentsView.hidden = YES;
    [QMSoundManager playEndOfCallSound];
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:2.0f];
}

#pragma mark - Calls notifications

// Override this method in child:
- (void)callAcceptedByUser {
}

// Override this method in child:
- (void)callStartedWithUser {
}

- (void)callRejectedByUser {
    
    self.opponentsView.hidden = YES;
    
    [self.contentView updateViewWithStatus:kUserIsBusyStatus];
    [[QMSoundManager shared] stopAllSounds];
    [QMSoundManager playBusySound];
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:2.0f];
}

- (void)callStoppedByOpponentForReason:(NSString *)reason {
    
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

- (void)dismissCallsController {
    
    [[QMSoundManager shared] stopAllSounds];
    
    if (_isOpponentCaller) {
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate.incomingCallService hideIncomingCallControllerWithStatus:nil];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
