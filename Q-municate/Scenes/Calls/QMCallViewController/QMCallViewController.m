//
//  QMCallViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCallViewController.h"
#import "QMCallToolbar.h"
#import "QMCallButtonsFactory.h"
#import "QMCallInfoView.h"
#import "QMCore.h"
#import "QMLocalVideoView.h"
#import "QMColors.h"
#import "QMSoundManager.h"
#import "QMHelpers.h"

static UIColor *videoCallBarBackgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    });
    
    return color;
}

static const NSTimeInterval kQMRefreshTimeInterval = 1.0f;
static const NSTimeInterval kQMHideBarsAfterTime = 5.0f;
static const NSTimeInterval kQMBadConnectionTimeOut = 1.5f;

static const CGFloat kQMToolbarHeightSmall = 78.0f;
static const CGFloat kQMToolbarHeightBig = 226.0f;

@interface QMCallViewController ()

<
QBRTCClientDelegate,
QMCallManagerDelegate,
QBRTCAudioSessionDelegate
>

@property (assign, nonatomic) QMCallState callState;

@property (strong, nonatomic) QMCallToolbar *toolbar;
@property (strong, nonatomic) QMCallInfoView *callInfoView;

@property (strong, nonatomic) NSTimer *hideBarsTimer;

@property (strong, nonatomic) NSTimer *callTimer;
@property (assign, nonatomic) NSTimeInterval callDuration;

@property (strong, nonatomic) NSTimer *badConnectionTimer;

@property (assign, nonatomic) BOOL disconnected;
@property (assign, nonatomic, readonly) BOOL isVideoCall;
@property (strong, nonatomic, readonly) QBRTCSession *session;
@property (strong, nonatomic) QBRTCCameraCapture *cameraCapture;

@property (strong, nonatomic) QMLocalVideoView *localVideoView;
@property (strong, nonatomic) QBRTCRemoteVideoView *opponentVideoView;

@property (strong, nonatomic) UIView *topLayoutBackgroundView;

@property (strong, nonatomic) UIButton *muteButton;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *declineButton;
@property (strong, nonatomic) UIButton *acceptButton;
@property (strong, nonatomic) UIButton *speakerButton;

@end

@implementation QMCallViewController

@dynamic session;
@dynamic isVideoCall;

//MARK: - Construction

+ (instancetype)callControllerWithState:(QMCallState)callState {
    
    QMCallViewController *callVC = [[self alloc] init];
    callVC.callState = callState;
    
    return callVC;
}

//MARK: - Life cycle

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[QBRTCClient instance] addDelegate:self];
    [[QMCore instance].callManager addDelegate:self];
    [[QBRTCAudioSession instance] addDelegate:self];
    
    if (self.isVideoCall) {
        
        // configuring controller for base video call
        self.view.backgroundColor = QMVideoCallBackgroundColor();
        
        // configuring camera capture
        self.cameraCapture = [[QBRTCCameraCapture alloc]
                              initWithVideoFormat:[QBRTCVideoFormat defaultFormat]
                              position:AVCaptureDevicePositionFront];
        [self.cameraCapture startSession:nil];
        
        // Aspect fill for preview layer
        self.cameraCapture.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
        
        // configuring opponents video view
        self.opponentVideoView = [[QBRTCRemoteVideoView alloc]
                                  initWithFrame:CGRectMake(0,
                                                           0,
                                                           CGRectGetWidth([UIScreen mainScreen].bounds),
                                                           CGRectGetHeight([UIScreen mainScreen].bounds))];
        self.opponentVideoView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.opponentVideoView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        [self.view addSubview:self.opponentVideoView];
        
        // configuring local video view
        self.localVideoView = [[QMLocalVideoView alloc] initWithPreviewLayer:self.cameraCapture.previewLayer];
        self.localVideoView.frame = self.opponentVideoView.bounds;
        self.localVideoView.autoresizingMask = self.opponentVideoView.autoresizingMask;
        
        [self.view addSubview:self.localVideoView];
    }
    
    [self configureCallController];
}

//MARK: - Configurations
//MARK: - Base configuration

- (void)configureCallController {
    
    [self configureCallInfoView];
    [self configureToolbar];
}

- (void)configureCallInfoView {
    
    QBUUser *opponentUser = [QMCore.instance.callManager opponentUser];
    
    if (self.callInfoView == nil) {
        // base call info view configuration
        self.callInfoView = [QMCallInfoView callInfoViewWithUser:opponentUser];
        
        // updating frame width to fill current screen
        CGRect frame = self.callInfoView.frame;
        frame.size.width = CGRectGetWidth([UIScreen mainScreen].bounds);
        self.callInfoView.frame = frame;
        self.callInfoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.view addSubview:self.callInfoView];
        
        if (self.isVideoCall) {
            // setting text color for dark video controller
            [self.callInfoView setTextColor:[UIColor whiteColor]];
        }
    }
    else if (self.callState == QMCallStateActiveVideoCall) {
        
        // configuring specific info view for active video call
        [self.callInfoView removeFromSuperview];
        self.callInfoView = nil;
        
        self.callInfoView = [QMCallInfoView videoCallInfoViewWithUser:opponentUser];
        // updating frame with top layout guide and screen fullfill
        self.callInfoView.frame = CGRectMake(0,
                                             self.topLayoutGuide.length,
                                             CGRectGetWidth([UIScreen mainScreen].bounds),
                                             CGRectGetHeight(self.callInfoView.frame));
        self.callInfoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.callInfoView.backgroundColor = videoCallBarBackgroundColor();
        
        [self.view insertSubview:self.callInfoView belowSubview:self.localVideoView];
    }
    
    NSString *bottomText = nil;
    switch (self.callState) {
            
        case QMCallStateIncomingAudioCall:
            bottomText = NSLocalizedString(@"QM_STR_INCOMING_CALL", nil);
            break;
            
        case QMCallStateIncomingVideoCall:
            bottomText = NSLocalizedString(@"QM_STR_INCOMING_VIDEO_CALL", nil);
            break;
            
        case QMCallStateOutgoingAudioCall:
            [self initializeAudioSessionIfNeeded];
            bottomText = NSLocalizedString(@"QM_STR_CALLING", nil);
            break;
            
        case QMCallStateOutgoingVideoCall:
            [self initializeAudioSessionIfNeeded];
            bottomText = NSLocalizedString(@"QM_STR_VIDEO_CALLING", nil);
            break;
            
        case QMCallStateActiveAudioCall:
        case QMCallStateActiveVideoCall:
            [self initializeAudioSessionIfNeeded];
            bottomText = NSLocalizedString(@"QM_STR_CONNECTING", nil);
            break;
    }
    
    self.callInfoView.bottomText = bottomText;
}

- (void)configureToolbar {
    
    [self.toolbar removeFromSuperview];
    self.toolbar = nil;
    
    CGFloat toolbarHeight = 0;
    switch (self.callState) {
            
        case QMCallStateIncomingAudioCall:
        case QMCallStateIncomingVideoCall:
        case QMCallStateOutgoingAudioCall:
        case QMCallStateActiveAudioCall:
            toolbarHeight = kQMToolbarHeightBig;
            break;
            
        case QMCallStateOutgoingVideoCall:
        case QMCallStateActiveVideoCall:
            toolbarHeight = kQMToolbarHeightSmall;
            break;
    }
    
    self.toolbar = [[QMCallToolbar alloc]
                    initWithFrame:CGRectMake(0,
                                             CGRectGetHeight([UIScreen mainScreen].bounds) - toolbarHeight,
                                             CGRectGetWidth([UIScreen mainScreen].bounds),
                                             toolbarHeight)];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:self.toolbar];
    
    [self configureToolbarButtons];
    
    [self.toolbar updateItemsDisplay];
}

- (void)configureToolbarButtons {
    
    switch (self.callState) {
            
        case QMCallStateOutgoingAudioCall:
        case QMCallStateActiveAudioCall:
            
            [self configureMuteButton];
            [self configureDeclineButton];
            [self configureSpeakerButton];
            
            break;
            
        case QMCallStateOutgoingVideoCall:
        case QMCallStateActiveVideoCall: {
            
            @weakify(self);
            
            self.cameraButton = [QMCallButtonsFactory cameraButton];
            [self.toolbar addButton:self.cameraButton action:^(UIButton * _Nonnull sender) {
                
                @strongify(self);
                self.localVideoView.previewLayerVisible = sender.selected;
                self.session.localMediaStream.videoTrack.enabled = sender.selected;
                sender.selected = !sender.selected;
            }];
            
            [self.toolbar addButton:[QMCallButtonsFactory cameraRotationButton] action:^(UIButton * _Nonnull sender) {
                
                @strongify(self);
                AVCaptureDevicePosition previousPosition = self.cameraCapture.position;
                AVCaptureDevicePosition position = previousPosition == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
                self.cameraCapture.position = position;
                
                sender.selected = !sender.selected;
            }];
            
            [self configureMuteButton];
            
            [self configureDeclineButton];
            
            break;
        }
            
        case QMCallStateIncomingAudioCall: {
            
            @weakify(self);
            
            self.declineButton = [QMCallButtonsFactory declineButton];
            [self.toolbar addButton:self.declineButton action:^(UIButton * _Nonnull sender) {
                
                @strongify(self);
                sender.enabled = NO;
                [self rejectCall];
            }];
            
            self.acceptButton = [QMCallButtonsFactory acceptButton];
            [self.toolbar addButton:self.acceptButton action:^(UIButton * _Nonnull sender) {
                
                @strongify(self);
                sender.userInteractionEnabled = NO;
                [QMCore.instance.callManager stopAllSounds];
                
                self.callState = QMCallStateActiveAudioCall;
                [self configureCallController];
                
                [self.session acceptCall:nil];
            }];
            
            break;
        }
            
        case QMCallStateIncomingVideoCall: {
            
            @weakify(self);
            
            self.declineButton = [QMCallButtonsFactory declineButton];
            [self.toolbar addButton:self.declineButton action:^(UIButton * _Nonnull sender) {
                
                @strongify(self);
                sender.enabled = NO;
                [self rejectCall];
            }];
            
            self.acceptButton = [QMCallButtonsFactory acceptVideoCallButton];
            [self.toolbar addButton:self.acceptButton action:^(UIButton * _Nonnull sender) {
                
                @strongify(self);
                sender.userInteractionEnabled = NO;
                [QMCore.instance.callManager stopAllSounds];
                
                self.callState = QMCallStateActiveVideoCall;
                [self configureCallController];
                
                [self.session acceptCall:nil];
                
                [self configureVideoCall];
            }];
            
            break;
        }
    }
}

//MARK: - Reusable toolbar buttons

- (void)configureMuteButton {
    
    self.muteButton = self.isVideoCall ? [QMCallButtonsFactory muteVideoCallButton] : [QMCallButtonsFactory muteAudioCallButton];
    
    if (self.session.localMediaStream) {
        
        self.muteButton.selected = !self.session.localMediaStream.audioTrack.enabled;
    }
    
    @weakify(self);
    [self.toolbar addButton:self.muteButton action:^(UIButton * _Nonnull sender) {
        
        @strongify(self);
        self.session.localMediaStream.audioTrack.enabled = sender.selected;
        sender.selected = !sender.selected;
    }];
}

- (void)configureDeclineButton {
    
    self.declineButton = self.isVideoCall ? [QMCallButtonsFactory declineVideoCallButton] : [QMCallButtonsFactory declineButton];
    
    @weakify(self);
    [self.toolbar addButton:self.declineButton action:^(UIButton * _Nonnull sender) {
        
        @strongify(self);
        sender.enabled = NO;
        [self stopCallTimer];
        [self stopHideBarsTimer];
        
        NSString *bottomText = nil;
        if (self.callState == QMCallStateActiveAudioCall ||
            self.callState == QMCallStateActiveVideoCall) {
            
            bottomText = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"QM_STR_CALL_WAS_STOPPED", nil) ,
                          QMStringForTimeInterval(self.callDuration)];
            
            [QMCore.instance.callManager sendCallNotificationMessageWithState:QMCallNotificationStateHangUp
                                                                     duration:self.callDuration];
        }
        else {
            
            bottomText = NSLocalizedString(@"QM_STR_CALL_WAS_STOPPED", nil);
        }
        
        if (self.callState == QMCallStateOutgoingAudioCall
            || self.callState == QMCallStateOutgoingVideoCall) {
            
            [QMCore.instance.callManager sendCallNotificationMessageWithState:QMCallNotificationStateMissedNoAnswer duration:0];
        }
        
        self.callInfoView.bottomText = bottomText;
        
        [self.session hangUp:nil];
    }];
}

- (void)configureSpeakerButton {
    
    self.speakerButton = [QMCallButtonsFactory speakerButton];
    
    QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
    self.speakerButton.selected = audioSession.currentAudioDevice == QBRTCAudioDeviceSpeaker;
    
    [self.toolbar addButton:self.speakerButton action:^(UIButton * _Nonnull sender) {
        
        QBRTCAudioDevice audioDevice = audioSession.currentAudioDevice == QBRTCAudioDeviceSpeaker ? QBRTCAudioDeviceReceiver : QBRTCAudioDeviceSpeaker;
        audioSession.currentAudioDevice = audioDevice;
        
        sender.selected = audioDevice == QBRTCAudioDeviceSpeaker;
    }];
}

//MARK: - Video call configuration

- (void)configureVideoCall {
    
    // configuring local video view frame
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    self.localVideoView.frame = [QMLocalVideoView preferredFrameForInterfaceOrientation:interfaceOrientation];
    self.localVideoView.blurEffectEnabled = NO;
    self.localVideoView.autoresizingMask = UIViewAutoresizingNone;
    
    // toolbar background color
    self.toolbar.backgroundColor = videoCallBarBackgroundColor();
    
    // adding status bar background
    [self.view addSubview:self.topLayoutBackgroundView];
    
    // adding gesture recognizer to opponents video view
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateBarsVisibility)];
    [self.opponentVideoView addGestureRecognizer:gestureRecognizer];
    
    // starting hide bars timer
    [self startHideBarsTimer];
}

//MARK: - Active video call bars visibility

- (void)updateBarsVisibility {
    
    [self updateBarsVisibilityForceShow:NO];
}

- (void)updateBarsVisibilityForceShow:(BOOL)forceShow {
    
    CGFloat alpha = self.callInfoView.alpha > 0 || self.toolbar.alpha > 0 ? 0 : 1.0f;
    
    if (forceShow) {
        
        alpha = 1.0f;
    }
    
    [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
        
        self.callInfoView.alpha =
        self.toolbar.alpha = alpha;
    }];
    
    if (alpha > 0 && self.hideBarsTimer == nil) {
        
        [self startHideBarsTimer];
    }
    else {
        
        [self stopHideBarsTimer];
    }
}

//MARK: - UIContentContainer protocol

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> __unused context) {
        
        if (self.callState == QMCallStateActiveVideoCall) {
            // This block is used to update layout for views
            // after interface orientation change
            
            // updating local video view frame after interface rotation
            UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
            self.localVideoView.frame = [QMLocalVideoView preferredFrameForInterfaceOrientation:interfaceOrientation];
            
            // Updating call info view frame with toplayout guide as a starting point
            CGRect infoFrame = self.callInfoView.frame;
            infoFrame.origin.y = self.topLayoutGuide.length;
            self.callInfoView.frame = infoFrame;
            
            // updating top layout background view
            CGRect topLayoutBackgroundFrame = self.topLayoutBackgroundView.frame;
            topLayoutBackgroundFrame.size.height = self.topLayoutGuide.length;
            self.topLayoutBackgroundView.frame = topLayoutBackgroundFrame;
        }
        
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}


//MARK: - Actions

- (void)initializeAudioSessionIfNeeded {
    QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
    if (!audioSession.isInitialized) {
        [audioSession initializeWithConfigurationBlock:^(QBRTCAudioSessionConfiguration *configuration) {
            // adding blutetooth support
            configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
            configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
            
            // adding airplay support
            configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
            
            if (self.session.conferenceType == QBRTCConferenceTypeVideo) {
                // setting mode to video chat to enable airplay audio and speaker only
                configuration.mode = AVAudioSessionModeVideoChat;
            }
        }];
    }
}

- (void)showBadConnectionInformation {
    self.callInfoView.bottomText = NSLocalizedString(@"QM_STR_LOST_CONNECTION_TRYING_TO_RESUME", nil);
    if (self.isVideoCall) {
        
        [self updateBarsVisibilityForceShow:YES];
    }
    [self.badConnectionTimer invalidate];
    self.badConnectionTimer = nil;
}

- (void)rejectCall {
    
    [self.session rejectCall:nil];
    
    [QMCore.instance.callManager sendCallNotificationMessageWithState:QMCallNotificationStateMissedNoAnswer duration:0];
}

//MARK: - Timers
//MARK: - Call Timer

- (void)refreshCallTime {
    
    if (!self.disconnected) {
        self.callDuration += kQMRefreshTimeInterval;
        self.callInfoView.bottomText = QMStringForTimeInterval(self.callDuration);
    }
}

- (void)startCallTimer {
    
    self.disconnected = NO;
    
    if (self.callTimer == nil) {
        // if timer already existent there is no need to create a new one
        // normally this method would never be called twice per one call
        // but there was a strengh behaviour one time
        // where webrtc for some reason called an unexpected delegates
        // multiple times
        self.callTimer = [NSTimer scheduledTimerWithTimeInterval:kQMRefreshTimeInterval
                                                          target:self
                                                        selector:@selector(refreshCallTime)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

- (void)stopCallTimer {
    
    if (self.callTimer != nil) {
        
        [self.callTimer invalidate];
        self.callTimer = nil;
    }
}

//MARK: - Hide bars timer

- (void)startHideBarsTimer {
    
    self.hideBarsTimer = [NSTimer scheduledTimerWithTimeInterval:kQMHideBarsAfterTime
                                                          target:self
                                                        selector:@selector(updateBarsVisibility)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)stopHideBarsTimer {
    
    if (self.hideBarsTimer != nil) {
        
        [self.hideBarsTimer invalidate];
        self.hideBarsTimer = nil;
    }
}

//MARK: - Getters

- (QBRTCSession *)session {
    
    return QMCore.instance.callManager.session;
}

- (BOOL)isVideoCall {
    
    return QMCore.instance.callManager.session.conferenceType == QBRTCConferenceTypeVideo;
}

- (UIView *)topLayoutBackgroundView {
    
    if (_topLayoutBackgroundView == nil) {
        
        _topLayoutBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            CGRectGetWidth([UIScreen mainScreen].bounds),
                                                                            self.topLayoutGuide.length)];
        _topLayoutBackgroundView.backgroundColor = [UIColor blackColor];
        _topLayoutBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    return _topLayoutBackgroundView;
}

//MARK: - QBRTCClientDelegate

- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)__unused userID {
    
    if (self.session != session) {
        
        return;
    }
    
    [self.opponentVideoView setVideoTrack:videoTrack];
}

- (void)session:(QBRTCSession *)session userDidNotRespond:(NSNumber *)userID {
    
    if (self.session != session) {
        
        return;
    }
    
    self.declineButton.enabled = NO;
    
    [QMCore.instance.callManager stopAllSounds];
    
    if (![self.session.initiatorID isEqualToNumber:userID]) {
        // there is QBRTC bug, when userID is always opponents iD
        // even  for user, who did not answer, this delegate will be called
        // with opponent user ID
        [QMCore.instance.callManager sendCallNotificationMessageWithState:QMCallNotificationStateMissedNoAnswer duration:0];
    }
    
    self.callInfoView.bottomText = NSLocalizedString(@"QM_STR_USER_DOESNT_ANSWER", nil);
}

- (void)session:(QBRTCSession *)session rejectedByUser:(NSNumber *)__unused userID userInfo:(NSDictionary *)__unused userInfo {
    
    if (self.session != session) {
        
        return;
    }
    
    self.declineButton.enabled = NO;
    
    [QMCore.instance.callManager stopAllSounds];
    
    self.callInfoView.bottomText = NSLocalizedString(@"QM_STR_USER_IS_BUSY", nil);
}

- (void)session:(QBRTCSession *)session acceptedByUser:(NSNumber *)__unused userID userInfo:(NSDictionary *)__unused userInfo {
    
    if (self.session != session) {
        
        return;
    }
    
    [[QMCore instance].callManager stopAllSounds];
    
    self.callState = session.conferenceType == QBRTCConferenceTypeVideo ? QMCallStateActiveVideoCall : QMCallStateActiveAudioCall;
    [self configureCallController];
    
    if (self.isVideoCall) {
        // configuring video call
        [self configureVideoCall];
    }
}

- (void)session:(QBRTCSession *)session hungUpByUser:(NSNumber *)__unused userID userInfo:(NSDictionary *)__unused userInfo {
    
    if (self.session != session) {
        
        return;
    }
    
    [self.badConnectionTimer invalidate];
    self.badConnectionTimer = nil;
    
    if (self.callState == QMCallStateIncomingAudioCall
        || self.callState == QMCallStateIncomingVideoCall) {
        
        self.callInfoView.bottomText = NSLocalizedString(@"QM_STR_CALL_WAS_CANCELLED", nil);
    }
    else {
        
        self.callInfoView.bottomText = [NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"QM_STR_CALL_WAS_STOPPED", nil), QMStringForTimeInterval(self.callDuration)];
    }
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)__unused userID {
    
    if (self.session != session) {
        
        return;
    }
    
    // starting timer
    [self startCallTimer];
}

- (void)session:(QBRTCSession *)session disconnectedFromUser:(NSNumber *)__unused userID {
    
    if (self.session != session) {
        
        return;
    }
    
    self.disconnected = YES;
    self.badConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:kQMBadConnectionTimeOut
                                                               target:self
                                                             selector:@selector(showBadConnectionInformation)
                                                             userInfo:nil
                                                              repeats:NO];
}

- (void)session:(QBRTCSession *)session connectionFailedForUser:(NSNumber *)__unused userID {
    
    if (self.session != session) {
        
        return;
    }
    
    self.callInfoView.bottomText = NSLocalizedString(@"QM_STR_BAD_CONNECTION", nil);
}

- (void)sessionDidClose:(QBRTCSession *)session {
    if (self.session != session) {
        return;
    }
    
    self.acceptButton.enabled = NO;
    self.declineButton.enabled = NO;
    
    [[QMCore instance].callManager stopAllSounds];
    
    [[QBRTCAudioSession instance] deinitialize];
    
    if (self.isVideoCall) {
        
        [self updateBarsVisibilityForceShow:YES];
    }
    
    [self stopCallTimer];
}

//MARK: - QMCallManagerDelegate

- (void)callManager:(QMCallManager *)__unused callManager willCloseCurrentSession:(QBRTCSession *)__unused session {
    
    if (self.cameraCapture != nil) {
        
        [self.cameraCapture stopSession:nil];
        self.cameraCapture = nil;
    }
}

- (void)callManager:(nonnull QMCallManager *)__unused callManager willChangeActiveCallState:(BOOL)__unused willHaveActiveCall {
    
}

// MARK: - QBRTCAudioSessionDelegate

- (void)audioSession:(QBRTCAudioSession *)__unused audioSession didChangeCurrentAudioDevice:(QBRTCAudioDevice)updatedAudioDevice {
    
    BOOL isSpeaker = updatedAudioDevice == QBRTCAudioDeviceSpeaker;
    if (self.speakerButton.selected != isSpeaker) {
        
        self.speakerButton.selected = isSpeaker;
    }
}

//MARK: - Overrides

- (UIStatusBarStyle)preferredStatusBarStyle {
    // light status bar for dark controller
    return self.isVideoCall ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

@end
