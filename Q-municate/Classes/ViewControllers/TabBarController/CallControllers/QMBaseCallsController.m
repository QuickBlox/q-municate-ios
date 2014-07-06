//
//  QMBaseCallsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMBaseCallsController.h"


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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callAcceptedByUser) name:kCallDidAcceptByUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStartedWithUser) name:kCallDidStartedByUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRejectedByUser) name:kCallWasRejectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStoppedByOpponentForReason:) name:kCallWasStoppedNotification object:nil];
}


#pragma mark - Override actions

- (void)startCall
{
    // Override this method in child:
}

- (void)confirmCall
{
    [[QMChatService shared] acceptCallFromUser:self.opponent.ID opponentView:self.opponentsView];
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
    [[QMChatService shared] finishCall];
    
    [self.contentView updateViewWithStatus:kCallWasStoppedByUserStatus];
    
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    
#warning Refactor this:
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
#warning Refactor this:
    self.opponentsView.hidden = YES;
    
    [self.contentView updateViewWithStatus:kUserIsBusyStatus];
    [[QMSoundManager shared] stopAllSounds];
    [QMSoundManager playBusySound];
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:2.0f];
}

- (void)callStoppedByOpponentForReason:(NSNotification *)notification
{
#warning Refactor this:
    self.opponentsView.hidden = YES;
    
    NSString *reason = notification.userInfo[@"reason"];
    
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
    
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:2.0];
}

- (void)dismissCallsController
{
    [[QMSoundManager shared] stopAllSounds];
    
    if (_isOpponentCaller) {
        [QMUtilities.shared dismissIncomingCallController];
        return;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
