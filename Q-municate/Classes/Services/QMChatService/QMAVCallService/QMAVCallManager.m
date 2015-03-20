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
@end

const NSTimeInterval kQBAnswerTimeInterval = 40.0f;
const NSTimeInterval kQBRTCDisconnectTimeInterval = 15.0f;

NSString *const kAudioCallController = @"AudioCallIdentifier";
NSString *const kVideoCallController = @"VideoCallIdentifier";
NSString *const kIncomingCallController = @"IncomingCallIdentifier";

NSString *const kUserIds = @"UserIds";
NSString *const kUserName = @"UserName";

@implementation QMAVCallManager
{
    QMApi *api;
    NSTimer *callingSoundTimer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        if( IS_IPAD ){
            self.speakerEnabled = YES;
        }
        self.frontCamera = YES;
    }
    return self;
}

- (void)start{
    [super start];
    api = [QMApi instance];
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
    [api requestPermissionToMicrophoneWithCompletion:^(BOOL granted) {
        if( granted ) {
            if( conferenceType == QBConferenceTypeAudio ) {
                if( completion ) {
                    completion(granted);
                }
            }
            else if( conferenceType == QBConferenceTypeVideo ) {
                [api requestPermissionToCameraWithCompletion:^(BOOL authorized) {
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
    event.message = [NSString stringWithFormat:@"%@ is calling you", api.currentUser.fullName];
    [QBRequest createEvent:event successBlock:nil errorBlock:nil];
}

- (void)callToUsers:(NSArray *)users withConferenceType:(QBConferenceType)conferenceType pushEnabled:(BOOL)pushEnabled {
    __weak __typeof(self) weakSelf = self;
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
            [self startPlayingCallingSound];
            weakSelf.session = session;
            
            QMBaseCallsController *vc = (QMBaseCallsController *)[weakSelf.mainStoryboard instantiateViewControllerWithIdentifier:(conferenceType == QBConferenceTypeVideo) ? kVideoCallController : kAudioCallController];
            
            NSUInteger opponentID = [((NSNumber *)users[0]) unsignedIntegerValue];
            vc.session = weakSelf.session;
            vc.opponent = [[QMApi instance] userWithID:opponentID];
            
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
            [navVC setNavigationBarHidden:YES];
            
            if( pushEnabled ){
                [self sendPushToUserWithUserID:opponentID];
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
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSString *category = [audioSession category];
    NSError *setCategoryError = nil;
    
    [audioSession setCategory:category
                  withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                        error:&setCategoryError];
    
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
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        weakSelf.session = nil;
        if( [weakSelf currentlyPresentedViewController] ){
            [[weakSelf currentlyPresentedViewController] dismissViewControllerAnimated:YES completion:nil];
        }
        if( IS_IPAD ){
            weakSelf.speakerEnabled = YES;
        }
        else{
            weakSelf.speakerEnabled = NO;
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


# pragma mark Sounds Public methods -

- (void)startPlayingCallingSound {
    [self stopAllSounds];
    callingSoundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                        target:self
                                                      selector:@selector(playCallingSound:)
                                                      userInfo:nil
                                                       repeats:YES];
    [self playCallingSound:nil];
}

- (void)startPlayingRingtoneSound {
    [self stopAllSounds];
    callingSoundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
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
    if( callingSoundTimer ){
        [callingSoundTimer invalidate];
        callingSoundTimer = nil;
    }
    [QMSysPlayer stopAllSounds];
}
@end
