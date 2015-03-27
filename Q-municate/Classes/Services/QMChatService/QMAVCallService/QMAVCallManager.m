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
#import "REAlertView+QMSuccess.h"
#import "QBUUser+CustomParameters.h"

@interface QMAVCallManager()
@property (strong, nonatomic, readonly) UIStoryboard *mainStoryboard;

/// active view controller
@property (weak, nonatomic) UIViewController *currentlyPresentedViewController;

@property (strong, nonatomic) NSTimer *callingSoundTimer;
@property (assign, nonatomic) AVAudioSessionCategoryOptions avCategoryOptions;

@end

const NSTimeInterval kQBAnswerTimeInterval = 40.0f;
const NSTimeInterval kQBRTCDisconnectTimeInterval = 15.0f;

NSString *const kAudioCallController = @"AudioCallIdentifier";
NSString *const kVideoCallController = @"VideoCallIdentifier";
NSString *const kIncomingCallController = @"IncomingCallIdentifier";

NSString *const kUserIds = @"UserIds";
NSString *const kUserName = @"UserName";

@implementation QMAVCallManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        self.frontCamera = YES;
    }
    return self;
}

- (void)start{
    [super start];
    [QBRTCClient.instance addDelegate:self];
    [QBRTCConfig setDTLSEnabled:YES];
}

- (void)stop{
    [super stop];
    [QBRTCClient.instance removeDelegate:self];
}

#pragma mark - RootViewController

- (UIViewController *)rootViewController {
    
    return UIApplication.sharedApplication.delegate.window.rootViewController;
}

#pragma mark - Public methods

- (void)acceptCall{
    if( self.session ){
        [self.session acceptCall:nil];
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

- (void)checkPermissionsWithConferenceType:(QBConferenceType)conferenceType completion:(void(^)(BOOL canContinue))completion {
    __weak __typeof(self) weakSelf = self;
    [[QMApi instance] requestPermissionToMicrophoneWithCompletion:^(BOOL granted) {
        if( granted ) {
            if( conferenceType == QBConferenceTypeAudio ) {
                if( completion ) {
                    completion(granted);
                }
            }
            else if( conferenceType == QBConferenceTypeVideo ) {
                
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
    event.isDevelopmentEnvironment =  NO;
    event.usersIDs = [@(opponentID) stringValue];
    event.notificationType = QBMNotificationTypePush;
    event.type = QBMEventTypeOneShot;
    event.message = [NSString stringWithFormat:@"%@ is calling you", [QMApi instance].currentUser.fullName];
    [QBRequest createEvent:event successBlock:nil errorBlock:nil];
}

- (void)callToUsers:(NSArray *)users withConferenceType:(QBConferenceType)conferenceType pushEnabled:(BOOL)pushEnabled {
    __weak __typeof(self) weakSelf = self;
    
    [self saveAudioSessionSettings];
    
    [self setAudioSessionDefaultToSpeakerIfNeeded]; // to make our ringtone go through the speaker
    
    [self checkPermissionsWithConferenceType:conferenceType completion:^(BOOL canContinue) {
        
        if( !canContinue ){
            return;
        }
        
        assert(users && users.count);
        
        if (weakSelf.session) {
            return;
        }
        
        QBRTCSession *session = [QBRTCClient.instance createNewSessionWithOpponents:users
                                                                 withConferenceType:conferenceType];
        
        if (session) {
            [weakSelf startPlayingCallingSound];
            weakSelf.session = session;
            
            QMBaseCallsController *vc = (QMBaseCallsController *)[weakSelf.mainStoryboard instantiateViewControllerWithIdentifier:(conferenceType == QBConferenceTypeVideo) ? kVideoCallController : kAudioCallController];
            
            NSUInteger opponentID = [((NSNumber *)users[0]) unsignedIntegerValue];
            vc.session = weakSelf.session;
            vc.opponent = [[QMApi instance] userWithID:opponentID];
            
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            [navVC setNavigationBarHidden:YES];
            
            if( pushEnabled ){
                [weakSelf sendPushToUserWithUserID:opponentID];
            }
            
            [weakSelf.rootViewController presentViewController:navVC
                                                      animated:YES
                                                    completion:nil];
            [weakSelf.session startCall:@{kUserIds: users}];
            weakSelf.currentlyPresentedViewController = navVC;
        }
        else {
            
            [SVProgressHUD showErrorWithStatus:@"Error creating new session"];
        }
    }];
}

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session {
    
    if (self.session) {
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    self.session = session;
    [self saveAudioSessionSettings];
    [self setAudioSessionDefaultToSpeakerIfNeeded];
    [self startPlayingRingtoneSound];
    
    QMIncomingCallController *incomingVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:kIncomingCallController];
    
    incomingVC.session = session;
    incomingVC.opponentID = [session.callerID unsignedIntegerValue];
    incomingVC.callType = session.conferenceType;
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:incomingVC];
    [navVC setNavigationBarHidden:YES];
    [self.rootViewController presentViewController:navVC
                                          animated:YES
                                        completion:nil];
    
    self.currentlyPresentedViewController = navVC;
}

- (void)sessionWillClose:(QBRTCSession *)session {
    if( self.session != session ){
        // may be we rejected someone else call while we are talking with another person
        return;
    }
    [self stopAllSounds];
    ILog(@"session will close");
    [SVProgressHUD dismiss];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    if( self.session != session ){
        // may be we rejected someone else call while we are talking with another person
        return;
    }
    [self restoreAudioSessionSettings];
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

- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack{
    self.localVideoTrack = videoTrack;
}

- (void)session:(QBRTCSession *)session didReceiveRemoteVideoTrack:(QBRTCVideoTrack *)videoTrack fromUser:(NSNumber *)userID{
    self.remoteVideoTrack = videoTrack;
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID{
    [self stopAllSounds];
}

#pragma mark - AVAudioSession save/restore -

- (void)setAvSessionCurrentCategoryOptions:(AVAudioSessionCategoryOptions)avSessionCurrentCategoryOptions {
    if( _avSessionCurrentCategoryOptions == avSessionCurrentCategoryOptions ){
        return;
    }
    _avSessionCurrentCategoryOptions = avSessionCurrentCategoryOptions;

    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    
    NSError *err = nil;
    [avSession setCategory:avSession.category withOptions:avSessionCurrentCategoryOptions error:&err];
    if( err ) {
        ILog(@"%@", err);
    }
    [avSession setActive:YES error:nil];
}

- (void)setAudioSessionDefaultToSpeakerIfNeeded {
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    
    if( avSession.categoryOptions == AVAudioSessionCategoryOptionDefaultToSpeaker ){
        return;
    }
    
    NSError *err = nil;
    [avSession setCategory:avSession.category withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&err];
    if( err ) {
        ILog(@"%@", err);
    }
}

- (void)setAudioSessionDefaultToHeadphoneIfNeeded {
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    
    if( avSession.categoryOptions == 0 ){
        return;
    }
    
    NSError *err = nil;
    [avSession setCategory:avSession.category withOptions:0 error:&err];
    if( err ) {
        ILog(@"%@", err);
    }
}

- (void)saveAudioSessionSettings {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    self.avCategoryOptions = session.categoryOptions;
    [session setActive:YES error:nil];
}

- (void)restoreAudioSessionSettings {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSString *category = [session category];
    
    NSError *error = nil;
    [session setCategory:category withOptions:self.avCategoryOptions error:&error];
    
    if( error ) {
        ILog(@"%@", error);
    }
}

#pragma mark Sounds Public methods -

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
