//
//  QMVideoCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//
#import "AppDelegate.h"
#import "AsyncImageView.h"
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
@property (weak, nonatomic) IBOutlet AsyncImageView *userAvatarView;

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
    
    if (self.userImage != nil) {
        [self.userAvatarView setImage:self.userImage];
    } else {
        // set placeholder:
        [self.userAvatarView setImage:[UIImage imageNamed:@"upic_call"]];
        // load image for url:
        [self.userAvatarView setImageURL:[NSURL URLWithString:self.opponent.website]];
    }
    
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
    if (self.callType == QMVideoChatTypeVideo) {
        [self.LeftButton setImage:[UIImage imageNamed:@"mute_off"] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"switchcam"] forState:UIControlStateNormal];
    } else if (self.callType == QMVideoChatTypeAudio) {
        [self.LeftButton setImage:[UIImage imageNamed:@"dynamic_on"] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"mute_off"] forState:UIControlStateNormal];
    }
}

- (void)configureCallUIForAcceptedCall
{
    // UI:
    if (self.callType == QMVideoChatTypeVideo) {
        [self activateVideoCallUI];
    } else if (self.callType == QMVideoChatTypeAudio) {
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

- (void)startCall
{
    [[QMChatService shared] callUser:self.opponent.ID opponentView:self.opponentsView callType:self.callType];
    
    // play sound:
    [[QMUtilities shared] playSoundOfType:QMSoundPlayTypeCallingNow];
}

- (void)confirmCall
{
    [[QMChatService shared] acceptCallFromUser:self.opponent.ID opponentView:self.opponentsView];
    
    //UI:
    [self configureCallUIForAcceptedCall];
    [self callStartedWithUser];
    
    callWasAccepted = YES;
}

- (void)callAcceptedByUser
{
    [self configureCallUIForAcceptedCall];
    callWasAccepted = YES;
    
    // stop playing sound:
    [[QMUtilities shared] stopPlaying];
    
    [self callStartedWithUser];
}

- (void)callStartedWithUser
{
    [self.spinner stopAnimating];
    if (self.callType == QMVideoChatTypeAudio) {
        [self startTimer];
    }
}

- (void)callRejectedByUser
{
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
    // audio call timer:
    if (self.callType == QMVideoChatTypeAudio) {
        [self stopTimer];
    }
    NSString *reason = notification.userInfo[@"reason"];
    
    if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
    }
    
    self.opponentsView.hidden = YES;
    
    callWasAccepted = NO;
    
    // stop playing sound:
    [[QMUtilities shared] stopPlaying];
    
    if ([reason isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]) {
        self.callDurationLabel.text = @"User doesn't answer";
        [[QMUtilities shared] playSoundOfType:QMSoundPlayTypeUserIsBusy];
    } else if ([reason isEqualToString:kStopVideoChatCallStatus_BadConnection]) {
        self.callDurationLabel.text = @"Call was stopped";
        [[[UIAlertView alloc] initWithTitle:@"Stopped" message:@"Call was stopped due bad connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        self.callDurationLabel.text = @"Call was stopped";
    }
    
    if (_isOpponentCall) {
        [self performSelector:@selector(dismissCallsController) withObject:self afterDelay:2.0f];
        return;
    }
    [self performSelector:@selector(dismissViewControllerAnimated:completion:) withObject:self afterDelay:2.0f];
}

- (IBAction)endOfCall:(id)sender
{
     [[QMChatService shared] finishCall];
    
    self.opponentsView.hidden = YES;
    if (self.callType == QMVideoChatTypeAudio) {
        [self stopTimer];
    }
    
    if (callWasAccepted) {
        self.callDurationLabel.text = @"Call finished";
    } else {
        self.callDurationLabel.text = @"Call canceled";
    }
    
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
    // Not Implemented
}

- (IBAction)rightControlTapped:(id)sender
{
    // Not Implemented
}


#pragma mark - Audio Call Timer

- (void)updateCallDurationLabel
{
    timeRemained++;
    self.callDurationLabel.text = [[QMUtilities shared] formattedTimeFromTimeInterval:timeRemained];
}

@end
