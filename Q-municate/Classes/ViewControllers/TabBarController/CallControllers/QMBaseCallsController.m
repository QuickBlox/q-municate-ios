//
//  QMBaseCallsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMBaseCallsController.h"
#import "QMChatService.h"
#import "QMSoundManager.h"
#import "QMUtilities.h"

@interface QMBaseCallsController ()

@property (weak, nonatomic) IBOutlet QBVideoView *opponentsView;

@end

@implementation QMBaseCallsController


#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.opponentsView.backgroundColor = [UIColor clearColor];
    
    if (!_isOpponentCaller) {
        [self startCall];
    } else {
        [self confirmCall];
    }
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

- (void)setOpponent:(QBUUser *)opponent
{
    self.opponent = opponent;
}

- (void)startCall
{
    // Override this method in child:
}

- (void)confirmCall
{
    // Override this method in child:
    [[QMChatService shared] acceptCallFromUser:self.opponent.ID opponentView:self.opponentsView];
    
}


#pragma mark - Override actions:

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
    [[QMChatService shared] finishCall];
    
    [self.contentView updateViewWithStatus:<#(NSString *)#>];
    
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    
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
    //
}

- (void)callRejectedByUser
{
    [[QMSoundManager shared] stopAllSounds];
    [QMSoundManager playBusySound];
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:2.0f];
}

- (void)callStoppedByOpponentForReason:(NSNotification *)notification
{
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
        [QMSoundManager playBusySound];
    } else {
        [self.contentView updateViewWithStatus:kCallWasStoppedByUserStatus];
        [QMSoundManager playEndOfCallSound];
    }
    
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:1.0];
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
