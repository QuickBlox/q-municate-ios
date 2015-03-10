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
#import "QMIncomingCallHandler.h"

@implementation QMBaseCallsController

#pragma mark - LifeCycle

- (void)dealloc {
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self subscribeForNotifications];
    !self.isOpponentCaller ? [self startCall] : [self confirmCall];

    [self.contentView updateViewWithUser:self.opponent];
//    self.opponentsView.backgroundColor = [UIColor clearColor];
}

- (void)subscribeForNotifications {
    
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
    [[QMApi instance] acceptCall];
}

// Override this method in child:
- (IBAction)leftControlTapped:(id)sender {}

// Override this method in child:
- (IBAction)rightControlTapped:(id)sender {}

- (IBAction)stopCallTapped:(id)sender {

    [[QMApi instance] finishCall];
    [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_CALL_WAS_STOPPED", nil)];
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    
//    self.opponentsView.hidden = YES;
    [QMSoundManager playEndOfCallSound];
}

#pragma mark - Calls notifications

// Override this method in child:
- (void)callAcceptedByUser {
}

// Override this method in child:


- (void)callRejectedByUser {
    
//    self.opponentsView.hidden = YES;
    
    [self.contentView updateViewWithStatus:NSLocalizedString(@"QM_STR_USER_IS_BUSY", nil)];
    [[QMSoundManager shared] stopAllSounds];
    [QMSoundManager playBusySound];
}

- (void)callStoppedByOpponentForReason:(NSString *)reason {
    
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];

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

@end
