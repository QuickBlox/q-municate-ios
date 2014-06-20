//
//  QMVideoCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//
#import "AppDelegate.h"

#import "QMVideoCallController.h"
#import "QMChatService.h"
#import "QMUtilities.h"

@interface QMVideoCallController () {
    BOOL callWasConfirmedByMe;
    BOOL callWasAccepted;             // start or confirm call
    
    BOOL headphoneUsed;
    BOOL microphoneIsMuted;
    BOOL backCameraUsed;
    
    double_t timeRemained;
}

@property (weak, nonatomic) IBOutlet UIButton *LeftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSTimer *callDuration;

// Audio calls UI
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *callDurationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarView;

// Video calls UI
@property (weak, nonatomic) IBOutlet QBVideoView *opponentsView;
@property (weak, nonatomic) IBOutlet UIImageView *myView;

@end

@implementation QMVideoCallController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.opponentsView.backgroundColor = [UIColor clearColor];
    
    callWasAccepted = NO;
    headphoneUsed = NO;
    microphoneIsMuted = NO;
    backCameraUsed = NO;
    
    [self configureUserAvatarCircledView];
    
    [self configureControlsForCallView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callAcceptedByUser) name:kCallDidAcceptByUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStartedWithUser) name:kCallDidStartedByUserNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callRejectedByUser) name:kCallWasRejectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callStoppedByOpponentForReason:) name:kCallWasStoppedNotification object:nil];
    
    [self.userAvatarView setImage:self.userImage];
    [self.userNameLabel setText:self.opponent.fullName];
    [self.callDurationLabel setText:@"Calling..."];
    
    if (!_isOpponentCall) {
        [self startCall];
        callWasConfirmedByMe = NO;
    } else {
        [self confirmCall];
        callWasConfirmedByMe = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureUserAvatarCircledView
{
    self.userAvatarView.layer.cornerRadius = self.userAvatarView.frame.size.width / 2;
    self.userAvatarView.layer.borderWidth = 2.0f;
    self.userAvatarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userAvatarView.layer.masksToBounds = YES;
}

- (void)configureControlsForCallView
{
    if (_videoEnabled) {
        [self.LeftButton setImage:[UIImage imageNamed:@"mute_off"] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"switchcam"] forState:UIControlStateNormal];
    } else {
        [self.LeftButton setImage:[UIImage imageNamed:@"dynamic_on"] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"mute_off"] forState:UIControlStateNormal];
    }
}

- (void)configureCallUIForAcceptedCall
{
    // UI:
    if (_videoEnabled) {
        [self activateVideoCallUI];
    } else {
        [self activateAudioCallUI];
    }
    [self.spinner startAnimating];
}

- (void)activateAudioCallUI
{
    self.userNameLabel.hidden = NO;
    self.callDurationLabel.hidden = NO;
    self.userAvatarView.hidden = NO;
    
    self.opponentsView.hidden =YES;
    self.myView.hidden = YES;
}

- (void)activateVideoCallUI
{
    self.userNameLabel.hidden = YES;
    self.callDurationLabel.hidden = YES;
    self.userAvatarView.hidden = YES;
    
    self.opponentsView.hidden = NO;
    self.myView.hidden = NO;
}

#pragma mark - Timer

- (void)startTimer
{
    if (self.callDuration == nil) {
        timeRemained = 0;
        self.callDuration = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCallDurationLabel) userInfo:nil repeats:YES];
        [self.callDuration fire];
    }
}

- (void)stopTimer
{
    [self.callDuration invalidate];
    self.callDuration = nil;
}


#pragma mark - Actions

- (void)activeStreamInit
{
    if (self.videoEnabled) {
        [[QMChatService shared] initActiveStreamWithOpponentView:self.opponentsView callType:QMVideoChatTypeVideo];
    } else {
        [[QMChatService shared] initActiveStreamWithOpponentView:self.opponentsView callType:QMVideoChatTypeAudio];
    }
}

- (void)startCall
{
    [self activeStreamInit];
    [[QMChatService shared] callUser:self.opponent.ID withVideo:self.videoEnabled];
    
    // play sound:
    [[QMUtilities shared] playSoundOfType:QMSoundPlayTypeCallingNow];
}

- (void)confirmCall
{
    [self activeStreamInit];
    
    [[QMChatService shared] acceptCallFromUser:self.opponent.ID withVideo:self.videoEnabled];
    
    //UI:
    [self configureCallUIForAcceptedCall];
    
    callWasAccepted = YES;
}

- (void)callAcceptedByUser
{
    [self configureCallUIForAcceptedCall];
    callWasAccepted = YES;
    
    // stop playing sound:
    [[QMUtilities shared] stopPlaying];
}

- (void)callStartedWithUser
{
    [self.spinner stopAnimating];
    if (!_videoEnabled) {
        [self startTimer];
    }
}

- (void)callRejectedByUser
{
    [[QMChatService shared] releaseActiveStream];
    self.callDurationLabel.text = @"User is busy";
    self.opponentsView.hidden = YES;
    // stop playing sound:
    [[QMUtilities shared] stopPlaying];
    
    callWasAccepted = NO;
    
    [[QMUtilities shared] playSoundOfType:QMSoundPlayTypeUserIsBusy];
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:2.0f];
}

- (void)callStoppedByOpponentForReason:(NSNotification *)notification
{
    if (!_videoEnabled) {
        [self stopTimer];
    }
    NSString *reason = notification.userInfo[@"reason"];
    
    if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
    }
    [[QMChatService shared] releaseActiveStream];
    
    self.opponentsView.hidden = YES;
    
    callWasAccepted = NO;
    
    // stop playing sound:
    [[QMUtilities shared] stopPlaying];
    
    if ([reason isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]) {
        self.callDurationLabel.text = @"User doesn't answer";
        [[QMUtilities shared] playSoundOfType:QMSoundPlayTypeUserIsBusy];
    } else if ([reason isEqualToString:kStopVideoChatCallStatus_BadConnection]) {
        [[[UIAlertView alloc] initWithTitle:@"Stopped" message:@"Connection was stopped due bad connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:2.0f];
}

- (IBAction)endOfCall:(id)sender
{
    self.opponentsView.hidden = YES;
    if (!_videoEnabled) {
        [self.callDuration invalidate];
        self.callDuration = nil;
    }
    if (callWasAccepted) {
        [[QMChatService shared] finishCall];
        
        self.callDurationLabel.text = @"Call finished";
    } else {
        [[QMChatService shared] cancelCall];
        
        self.callDurationLabel.text = @"Call canceled";
    }
    [[QMChatService shared] releaseActiveStream];
    
    // stop playing sound:
    [[QMUtilities shared] stopPlaying];
    
    [[QMUtilities shared] playSoundOfType:QMSoundPlayTypeEndOfCall];
    [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:1.0f];
}

- (void)dismissCallsController
{
    [[QMUtilities shared] stopPlaying];
    
    if (callWasConfirmedByMe) {
        [QMUtilities dismissIncomingCallController:nil];
        return;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - Controls

- (IBAction)leftControlTapped:(id)sender
{
    if (_videoEnabled) {
        [self microphoneTapped];
        // update icon: 
        if (microphoneIsMuted) {
            [self.LeftButton setImage:[UIImage imageNamed:@"mute_on"] forState:UIControlStateNormal];
        } else {
            [self.LeftButton setImage:[UIImage imageNamed:@"mute_off"] forState:UIControlStateNormal];
        }
    } else {
        [self dynamicTapped];
        // update icon:
        if (headphoneUsed) {
            [self.LeftButton setImage:[UIImage imageNamed:@"dynamic"] forState:UIControlStateNormal];
        } else {
            [self.LeftButton setImage:[UIImage imageNamed:@"dynamic_on"] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)rightControlTapped:(id)sender
{
    if (_videoEnabled) {
        [self cameraTapped];
    } else {
        [self microphoneTapped];
        if (microphoneIsMuted) {
            [self.rightButton setImage:[UIImage imageNamed:@"mute_on"] forState:UIControlStateNormal];
        } else {
            [self.rightButton setImage:[UIImage imageNamed:@"mute_off"] forState:UIControlStateNormal];
        }
    }
}

- (void)microphoneTapped
{
    microphoneIsMuted = !microphoneIsMuted;
//    if (microphoneIsMuted) {
//        [QMChatService shared].activeStream.microphoneEnabled = NO;
//    } else {
//        [QMChatService shared].activeStream.microphoneEnabled = YES;
//    }
}

- (void)cameraTapped
{
    backCameraUsed = !backCameraUsed;
//    if (backCameraUsed) {
//        [QMChatService shared].activeStream.useBackCamera = YES;
//    } else {
//        [QMChatService shared].activeStream.useBackCamera = NO;
//    }
}

- (void)dynamicTapped
{
    headphoneUsed = !headphoneUsed;
}

#pragma mark - 

- (void)updateCallDurationLabel
{
    timeRemained++;
    self.callDurationLabel.text = [[QMUtilities shared] formattedTimeFromTimeInterval:timeRemained];
}

@end
