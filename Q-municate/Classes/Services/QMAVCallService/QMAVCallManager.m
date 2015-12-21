//
//  QMAVCallManager.m
//  Q-municate
//
//  Created by Anton Sokolchenko on 3/6/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMAVCallManager.h"
#import "SVProgressHUD.h"
#import "QMBaseCallsController.h"
#import "QMApi.h"
#import "QMDevice.h"
#import "REAlertView+QMSuccess.h"

@interface QMAVCallManager()

/// active view controller
@property (weak, nonatomic) UIViewController *currentlyPresentedViewController;

@property (strong, nonatomic) NSTimer *callingSoundTimer;
@property (assign, nonatomic) AVAudioSessionCategoryOptions avCategoryOptions;

@end

const NSTimeInterval kQBAnswerTimeInterval = 60.f;
const NSTimeInterval kQBRTCDisconnectTimeInterval = 30.f;
const NSTimeInterval kQBDialingTimeInterval = 5.f;

NSString *const kAudioCallController = @"AudioCallIdentifier";
NSString *const kVideoCallController = @"VideoCallIdentifier";
NSString *const kIncomingCallController = @"IncomingCallIdentifier";

NSString *const kUserIds = @"UserIds";
NSString *const kUserName = @"UserName";

@implementation QMAVCallManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [QBRTCConfig setAnswerTimeInterval:kQBAnswerTimeInterval];
        [QBRTCConfig setDisconnectTimeInterval:kQBRTCDisconnectTimeInterval];
        [QBRTCConfig setDialingTimeInterval:kQBDialingTimeInterval];
        
        self.frontCamera = YES;
    }
    return self;
}

- (void)serviceWillStart {
    [[QBRTCClient instance] addDelegate:self];
    [QBRTCConfig setDTLSEnabled:YES];
}

#pragma mark - RootViewController

- (UIViewController *)rootViewController {
    
    return UIApplication.sharedApplication.delegate.window.rootViewController;
}

#pragma mark - properties

- (void)setHasActiveCall:(BOOL)hasActiveCall {
    if (_hasActiveCall != hasActiveCall) {
        _hasActiveCall = hasActiveCall;
        
        if (!_hasActiveCall) {
            [[QMApi instance] disconnectFromChatIfNeeded];
        }
    }
}

#pragma mark - Public methods

- (void)acceptCall{
    [self stopAllSounds];
    if( self.session ){
        [self.session acceptCall:nil];
        self.hasActiveCall = YES;
    }
    else{
        NSLog(@"error in -acceptCall: session does not exists");
    }
}

- (void)rejectCall{
    [self stopAllSounds];
    if( self.session ){
        [self.session rejectCall:@{@"reject" : @"busy"}];
    }
    else{
        NSLog(@"error in -rejectCall: session does not exists");
    }
}

- (void)hangUpCall{
    if( self.session ){
        [self.session hangUp:@{@"session" : @"hang up"}];
    }
    else{
        NSLog(@"error in -rejectCall: session does not exists");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if( alertView.cancelButtonIndex != buttonIndex ){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType completion:(void(^)(BOOL canContinue))completion {
    __weak __typeof(self) weakSelf = self;
    [[QMApi instance] requestPermissionToMicrophoneWithCompletion:^(BOOL granted) {
        if( granted ) {
            if( conferenceType == QBRTCConferenceTypeAudio ) {
                if( completion ) {
                    completion(granted);
                }
            }
            else if( conferenceType == QBRTCConferenceTypeVideo ) {
                
                [[QMApi instance] requestPermissionToCameraWithCompletion:^(BOOL authorized) {
                    if( authorized && completion ) {
                        completion(authorized);
                    }
                    else if( !authorized){
                        if (&UIApplicationOpenSettingsURLString != NULL) {
                            [[[UIAlertView alloc] initWithTitle:@"Camera error" message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_CAMERA", nil) delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:@"Settings", nil] show];
                        }
                        else{
                            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_CAMERA", nil) actionSuccess:NO];
                        }
                    }
                }];
            }
        }
        else {
            if (&UIApplicationOpenSettingsURLString != NULL) {
                [[[UIAlertView alloc] initWithTitle:@"Microphone error" message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_MICROPHONE", nil)  delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:@"Settings", nil] show];
            }
            else{
                [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_MICROPHONE", nil) actionSuccess:NO];
            }
        }
    }];
}

- (void)sendPushToUserWithUserID:(NSUInteger)opponentID{
    QBMEvent *event = [QBMEvent event];
    event.usersIDs = [@(opponentID) stringValue];
    event.notificationType = QBMNotificationTypePush;
    event.type = QBMEventTypeOneShot;
    event.message = [NSString stringWithFormat:@"%@ is calling you", [QMApi instance].currentUser.fullName];
    [QBRequest createEvent:event successBlock:nil errorBlock:nil];
}

- (void)callToUsers:(NSArray *)users withConferenceType:(QBRTCConferenceType)conferenceType pushEnabled:(BOOL)pushEnabled {
    __weak __typeof(self) weakSelf = self;
    [[QBRTCSoundRouter instance] initialize];
    [[QBRTCSoundRouter instance] setCurrentSoundRoute:QBRTCSoundRouteSpeaker]; // to make our ringtone go through the speaker
    
    [self checkPermissionsWithConferenceType:conferenceType completion:^(BOOL canContinue) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        if( !canContinue ){
            return;
        }
        
        assert(users && users.count);
        
        if (strongSelf.session) {
            return;
        }
        
        QBRTCSession *session = [QBRTCClient.instance createNewSessionWithOpponents:users
                                                                 withConferenceType:conferenceType];
        
        if (session) {
            self.opponentCaller = NO;
            self.frontCamera = YES;
            
            [strongSelf startPlayingCallingSound];
            strongSelf.session = session;
            
            QMBaseCallsController *vc = (QMBaseCallsController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:(conferenceType == QBRTCConferenceTypeVideo) ? kVideoCallController : kAudioCallController];
            
            NSUInteger opponentID = [((NSNumber *)users[0]) unsignedIntegerValue];
            vc.session = strongSelf.session;
            vc.opponent = [[QMApi instance] userWithID:opponentID];
            
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            [navVC setNavigationBarHidden:YES];
            
            if( pushEnabled ){
                [strongSelf sendPushToUserWithUserID:opponentID];
            }
            
            [strongSelf.rootViewController presentViewController:navVC
                                                      animated:YES
                                                    completion:nil];
            [strongSelf.session startCall:@{kUserIds: users}];
            strongSelf.hasActiveCall = YES;
            strongSelf.currentlyPresentedViewController = navVC;
        }
        else {
            
            [SVProgressHUD showErrorWithStatus:@"Error creating new session"];
        }
    }];
}

- (void)startCameraCapture {
    if (self.session.conferenceType != QBRTCConferenceTypeVideo) return;
    
    if (self.cameraCapture == nil) {
        QBRTCVideoFormat *videoFormat = [[QBRTCVideoFormat alloc] init];
        videoFormat.frameRate = 30;
        videoFormat.pixelFormat = QBRTCPixelFormat420f;
        
        CGFloat videoWidth;
        CGFloat videoHeight;
        
        if ([QMDevice isIphone6Plus]) {
            videoWidth = 640.;
            videoHeight = 480.;
        } else if ([QMDevice isIphone6]) {
            videoWidth = 480.;
            videoHeight = 360.;
        } else {
            videoWidth = 352.;
            videoHeight = 288.;
        }
        videoFormat.width = videoWidth;
        videoFormat.height = videoHeight;
        
        // QBRTCCameraCapture class used to capture frames using AVFoundation APIs
        self.cameraCapture = [[QBRTCCameraCapture alloc] initWithVideoFormat:videoFormat position:AVCaptureDevicePositionFront]; // or AVCaptureDevicePositionBack
        
        [self.cameraCapture startSession];
    }
}

- (void)stopCameraCapture {
    if (self.cameraCapture != nil) {
        [self.cameraCapture stopSession];
        self.cameraCapture = nil;
    }
}

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)userInfo {
    if (self.session) {
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    self.opponentCaller = YES;
    self.frontCamera = YES;
    
    [[QBRTCSoundRouter instance] initialize];
    
    self.session = session;
    [[QBRTCSoundRouter instance] setCurrentSoundRoute:QBRTCSoundRouteSpeaker];
    [self startPlayingRingtoneSound];
    
    QMIncomingCallController *incomingVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kIncomingCallController];
    
    incomingVC.session = session;
    incomingVC.opponentID = [session.initiatorID unsignedIntegerValue];
    incomingVC.callType = session.conferenceType;
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:incomingVC];
    [navVC setNavigationBarHidden:YES];
    [self.rootViewController presentViewController:navVC
                                          animated:YES
                                        completion:nil];
    
    self.currentlyPresentedViewController = navVC;
}

- (void)sessionDidClose:(QBRTCSession *)session {
    if( self.session != session ){
        // may be we rejected someone else call while we are talking with another person
        return;
    }
    
    [self stopAllSounds];
    ILog(@"session will close");
    [SVProgressHUD dismiss];
    
    [[QBRTCSoundRouter instance] deinitialize];
    
    [self stopCameraCapture];
    self.hasActiveCall = NO;
    
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        weakSelf.session = nil;
        if( [weakSelf currentlyPresentedViewController] ){
            [[weakSelf currentlyPresentedViewController] dismissViewControllerAnimated:YES completion:nil];
        }
        if( !IS_IPAD ){
            weakSelf.frontCamera = YES;
        }
    });
}

- (void)session:(QBRTCSession *)session initializedLocalMediaStream:(QBRTCMediaStream *)mediaStream {
    
    session.localMediaStream.videoTrack.videoCapture = self.cameraCapture;
}

- (void)session:(QBRTCSession *)session receivedRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID {
    
    if (session == self.session) {
        self.remoteVideoTrack = videoTrack;
    }
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    
    if (session == self.session) {
        [self stopAllSounds];
    }
}

- (void)startPlayingCallingSound {
    [self stopAllSounds];
    self.callingSoundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                              target:self
                                                            selector:@selector(playCallingSound:)
                                                            userInfo:nil
                                                             repeats:YES];
    [self playCallingSound:nil];
}

- (void)startPlayingRingtoneSound {
    
    [self stopAllSounds];
    self.callingSoundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                              target:self
                                                            selector:@selector(playRingtoneSound:)
                                                            userInfo:nil
                                                             repeats:YES];
    [self playRingtoneSound:nil];
}

# pragma mark Sounds Private methods -

- (void)playCallingSound:(id)sender {
    [QMSoundManager playCallingSound];
}

- (void)playRingtoneSound:(id)sender {
    [QMSoundManager playRingtoneSound];
}

- (void)stopAllSounds {
    
    if( self.callingSoundTimer ){
        [self.callingSoundTimer invalidate];
        self.callingSoundTimer = nil;
    }
    
    [QMSysPlayer stopAllSounds];
}
@end
