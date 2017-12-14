//
//  QMCallManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCallManager.h"

#import "QMCore.h"
#import "QMCallViewController.h"
#import "QMSoundManager.h"
#import "QMPermissions.h"
#import "QMNotification.h"
#import "QMCallKitAdapter.h"

static const NSTimeInterval kQMAnswerTimeInterval = 60.0f;
static const NSTimeInterval kQMDialingTimeInterval = 5.0f;
static const NSTimeInterval kQMCallViewControllerEndScreenDelay = 1.0f;

NSString * const QMVoipCallEventKey = @"VOIPCall";

@interface QMCallManager ()
<
QBRTCClientDelegate,
QMCallKitAdapterUsersStorageProtocol
>

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;
@property (strong, nonatomic) QBMulticastDelegate <QMCallManagerDelegate> *multicastDelegate;

@property (strong, nonatomic, readwrite) QBRTCSession *session;
@property (assign, nonatomic, readwrite) BOOL hasActiveCall;
@property (strong, nonatomic) NSTimer *soundTimer;

@property (strong, nonatomic) UIWindow *callWindow;

@property (strong, nonatomic) QMCallKitAdapter *callKitAdapter;
@property (strong, nonatomic, readwrite) NSUUID *callUUID;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation QMCallManager

@dynamic serviceManager;

+ (BOOL)isCallKitAvailable {
    return QMCallKitAdapter.isCallKitAvailable;
}

- (void)serviceWillStart {
    
    [QBRTCConfig setAnswerTimeInterval:kQMAnswerTimeInterval];
    [QBRTCConfig setDialingTimeInterval:kQMDialingTimeInterval];
    
    _multicastDelegate = (id<QMCallManagerDelegate>)[[QBMulticastDelegate alloc] init];
    
    [[QBRTCClient instance] addDelegate:self];
    
    if (QMCallKitAdapter.isCallKitAvailable) {
        _callKitAdapter = [[QMCallKitAdapter alloc] initWithUsersStorage:self];
        @weakify(self);
        // mic was muted by callkit actions
        [_callKitAdapter setOnMicrophoneMuteAction:^{
            @strongify(self);
            [self.multicastDelegate callManagerDidChangeMicrophoneState:self];
        }];
        // call was ended by callkit actions
        [_callKitAdapter setOnCallEndedByCallKitAction:^{
            @strongify(self);
            if (self.callWindow == nil) {
                // if no call window in existence that means that call was ended
                // on our side while not established, send appropriate notification
                [self sendCallNotificationMessageWithState:QMCallNotificationStateMissedNoAnswer duration:0];
            }
        }];
    }
}

// MARK: - Call managing

- (void)callToUserWithID:(NSUInteger)userID conferenceType:(QBRTCConferenceType)conferenceType {
    
    @weakify(self);
    [self checkPermissionsWithConferenceType:conferenceType completion:^(BOOL granted) {
        
        @strongify(self);
        
        if (!granted) {
            // no permissions
            return;
        }
        
        if (self.session != nil) {
            // session in progress
            return;
        }
        
        self.session = [[QBRTCClient instance] createNewSessionWithOpponents:@[@(userID)]
                                                          withConferenceType:conferenceType];
        
        if (self.session == nil) {
            // failed to create session
            return;
        }
        
        if (QMCallKitAdapter.isCallKitAvailable) {
            self.callUUID = [NSUUID UUID];
            [self.callKitAdapter startCallWithUserID:@(userID) session:self.session uuid:self.callUUID];
        }
        
        [self startPlayingCallingSound];
        
        // instantiating view controller
        QMCallState callState = conferenceType == QBRTCConferenceTypeVideo ? QMCallStateOutgoingVideoCall : QMCallStateOutgoingAudioCall;
        
        QBUUser *opponentUser = [self.serviceManager.usersService.usersMemoryStorage userWithID:userID];
        QBUUser *currentUser = self.serviceManager.currentProfile.userData;
        
        NSString *callerName = currentUser.fullName ?: [NSString stringWithFormat:@"%tu", currentUser.ID];
        NSString *pushText = [NSString stringWithFormat:@"%@ %@", callerName, NSLocalizedString(@"QM_STR_IS_CALLING_YOU", nil)];
        
        [QMNotification sendPushNotificationToUser:opponentUser
                                          withText:pushText
                                       extraParams:@{
                                                     QMVoipCallEventKey : @"1",
                                                     }
                                            isVoip:YES];
        
        [self prepareCallWindow];
        
        self.callWindow.rootViewController = [QMCallViewController callControllerWithState:callState];
        
        [self.session startCall:nil];
        self.hasActiveCall = YES;
        
        if (QMCallKitAdapter.isCallKitAvailable) {
            [self.callKitAdapter updateCallWithUUID:self.callUUID connectingAtDate:[NSDate date]];
        }
    }];
}

- (void)prepareCallWindow {
    
    // hiding keyboard
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    self.callWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // displaying window under status bar
    self.callWindow.windowLevel = UIWindowLevelStatusBar - 1;
    [self.callWindow makeKeyAndVisible];
}

//MARK: - Setters

- (void)setHasActiveCall:(BOOL)hasActiveCall {
    
    if (_hasActiveCall != hasActiveCall) {
        
        [self.multicastDelegate callManager:self willChangeActiveCallState:hasActiveCall];
        
        _hasActiveCall = hasActiveCall;
        
        if (!QMCallKitAdapter.isCallKitAvailable
            && self.session.conferenceType == QBRTCConferenceTypeAudio) {
            // enabling proximity sensor only if call kit is not available
            // as callkit handling this by default
            [UIDevice currentDevice].proximityMonitoringEnabled = hasActiveCall;
        }
    }
}

//MARK: - Getters

- (QBUUser *)opponentUser {
    
    if (self.session == nil) {
        // no active session
        return nil;
    }
    
    NSUInteger opponentID;
    
    NSUInteger initiatorID = self.session.initiatorID.unsignedIntegerValue;
    if (initiatorID == self.serviceManager.currentProfile.userData.ID) {
        
        opponentID = [self.session.opponentsIDs.firstObject unsignedIntegerValue];
    }
    else {
        
        opponentID = initiatorID;
    }
    
    QBUUser *opponentUser = [self.serviceManager.usersService.usersMemoryStorage userWithID:opponentID];
    
    return opponentUser;
}

// MARK: - Methods

- (void)performCallKitPreparations {
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateBackground
        && _backgroundTask == UIBackgroundTaskInvalid) {
        _backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [application endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
        // as we are in the background, do not send initial presence in chat
        // so we won't appear online for all users, only send initial presence
        // when we will be back in foreground
        [QBChat instance].manualInitialPresence = YES;
    }
    QBChat *chat = QBChat.instance;
    if (!chat.isConnected && !chat.isConnecting) {
        [self.serviceManager login];
    }
}

//MARK: - QBRTCClientDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session userInfo:(NSDictionary *)__unused userInfo {
    
    if (self.session != nil) {
        // session in progress
        [session rejectCall:nil];
        // sending appropriate notification
        QBChatMessage *message = [self _callNotificationMessageForSession:session state:QMCallNotificationStateMissedNoAnswer];
        [self _sendNotificationMessage:message];
        return;
    }
    
    if (session.initiatorID.unsignedIntegerValue == self.serviceManager.currentProfile.userData.ID) {
        // skipping call from ourselves
        return;
    }
    
    self.session = session;
    self.hasActiveCall = YES;
    
    if (QMCallKitAdapter.isCallKitAvailable) {
        self.callUUID = [NSUUID UUID];
        
        @weakify(self);
        [_callKitAdapter reportIncomingCallWithUserID:session.initiatorID session:session uuid:self.callUUID onAcceptAction:^{
            @strongify(self);
            // initializing controller
            QMCallState callState = session.conferenceType == QBRTCConferenceTypeVideo ? QMCallStateActiveVideoCall : QMCallStateActiveAudioCall;
            
            [self prepareCallWindow];
            self.callWindow.rootViewController = [QMCallViewController callControllerWithState:callState];
            
        } completion:nil];
    }
    else {
        [self startPlayingRingtoneSound];
        
        // initializing controller
        QMCallState callState = session.conferenceType == QBRTCConferenceTypeVideo ? QMCallStateIncomingVideoCall : QMCallStateIncomingAudioCall;
        
        [self prepareCallWindow];
        self.callWindow.rootViewController = [QMCallViewController callControllerWithState:callState];
    }
}

- (void)session:(QBRTCSession *)__unused session updatedStatsReport:(QBRTCStatsReport *)report forUserID:(NSNumber *)userID {
    
    ILog(@"Stats report for userID: %@\n%@", userID, [report statsString]);
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)__unused userID {
    
    if (self.session == session) {
        // stopping calling sounds
        [self stopAllSounds];
        
        if (QMCallKitAdapter.isCallKitAvailable
            && [session.initiatorID unsignedIntegerValue] == self.serviceManager.currentProfile.userData.ID) {
            [_callKitAdapter updateCallWithUUID:_callUUID connectedAtDate:[NSDate date]];
        }
    }
}

- (void)sessionDidClose:(QBRTCSession *)session {
    
    if (self.session != session) {
        // may be we rejected some one else call
        // while talking with another person
        return;
    }
    
    self.hasActiveCall = NO;
    
    if (QMCallKitAdapter.isCallKitAvailable) {
        [self.callKitAdapter endCallWithUUID:self.callUUID completion:nil];
        self.callUUID = nil;
    }
    
    if (_backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
        _backgroundTask = UIBackgroundTaskInvalid;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground
            && self.backgroundTask == UIBackgroundTaskInvalid) {
            // dispatching chat disconnect in 1.5 second so message about call end
            // from webrtc does not cut mid sending (ideally webrtc should wait
            // untill message about hangup did send, which is not the case now)
            // checking for background task being invalid though, to avoid disconnecting
            // from chat when another call has already being received in background
            [self.serviceManager.chatManager disconnectFromChatIfNeeded];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kQMCallViewControllerEndScreenDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
            [QMSoundManager playEndOfCallSound];
        }
        
        [self.multicastDelegate callManager:self willCloseCurrentSession:session];
        
        self.callWindow.rootViewController = nil;
        self.callWindow = nil;
        
        self.session = nil;
    });
}

//MARK: - Multicast delegate

- (void)addDelegate:(id<QMCallManagerDelegate>)delegate {
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id<QMCallManagerDelegate>)delegate {
    [self.multicastDelegate removeDelegate:delegate];
}

//MARK: - Sound management

- (void)startPlayingCallingSound {
    
    [self stopAllSounds];
    [QMSoundManager playCallingSound];
    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                       target:[QMSoundManager class]
                                                     selector:@selector(playCallingSound)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)startPlayingRingtoneSound {
    
    [self stopAllSounds];
    
    [QMSoundManager playRingtoneSound];
    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:[QBRTCConfig dialingTimeInterval]
                                                       target:[QMSoundManager class]
                                                     selector:@selector(playRingtoneSound)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)stopAllSounds {
    
    if (self.soundTimer != nil) {
        
        [self.soundTimer invalidate];
        self.soundTimer = nil;
    }
    
    [[QMSoundManager instance] stopAllSounds];
}

//MARK: - Permissions check

- (void)checkPermissionsWithConferenceType:(QBRTCConferenceType)conferenceType completion:(PermissionBlock)completion {
    
    @weakify(self);
    [QMPermissions requestPermissionToMicrophoneWithCompletion:^(BOOL granted) {
        
        @strongify(self);
        if (granted) {
            
            switch (conferenceType) {
                    
                case QBRTCConferenceTypeAudio:
                    
                    if (completion) {
                        
                        completion(granted);
                    }
                    
                    break;
                    
                case QBRTCConferenceTypeVideo: {
                    
                    [QMPermissions requestPermissionToCameraWithCompletion:^(BOOL videoGranted) {
                        
                        if (!videoGranted) {
                            
                            // showing error alert with a suggestion
                            // to go to the settings
                            [self showAlertWithTitle:NSLocalizedString(@"QM_STR_CAMERA_ERROR", nil)
                                             message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_CAMERA", nil)];
                        }
                        
                        if (completion) {
                            
                            completion(videoGranted);
                        }
                    }];
                    
                    break;
                }
            }
        }
        else {
            
            // showing error alert with a suggestion
            // to go to the settings
            [self showAlertWithTitle:NSLocalizedString(@"QM_STR_MICROPHONE_ERROR", nil)
                             message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_MICROPHONE", nil)];
            
            if (completion) {
                
                completion(granted);
            }
        }
    }];
}

//MARK: - Call notifications

- (QBChatMessage *)_callNotificationMessageForSession:(QBRTCSession *)session
                                                state:(QMCallNotificationState)state {
    
    NSUInteger senderID = self.serviceManager.currentProfile.userData.ID;
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = kQMCallNotificationMessage;
    message.senderID = senderID;
    message.markable = YES;
    message.dateSent = [NSDate date];
    message.callNotificationType = session.conferenceType == QBRTCConferenceTypeAudio ? QMCallNotificationTypeAudio : QMCallNotificationTypeVideo;
    message.callNotificationState = state;
    
    NSUInteger initiatorID = session.initiatorID.unsignedIntegerValue;
    NSUInteger opponentID = [session.opponentsIDs.firstObject unsignedIntegerValue];
    NSUInteger calleeID = initiatorID == senderID ? opponentID : initiatorID;
    
    message.callerUserID = initiatorID;
    message.calleeUserIDs = [NSIndexSet indexSetWithIndex:calleeID];
    
    message.recipientID = calleeID;
    
    return message;
}

- (void)_sendNotificationMessage:(QBChatMessage *)message {
    
    QBChatDialog *chatDialog = [self.serviceManager.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:message.recipientID];
    
    if (chatDialog != nil) {
        
        message.dialogID = chatDialog.ID;
        [self.serviceManager.chatService sendMessage:message
                                            toDialog:chatDialog
                                       saveToHistory:YES
                                       saveToStorage:YES];
    }
    else {
        
        [[self.serviceManager.chatService createPrivateChatDialogWithOpponentID:message.recipientID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
            
            message.dialogID = t.result.ID;
            [self.serviceManager.chatService sendMessage:message
                                                toDialog:t.result
                                           saveToHistory:YES
                                           saveToStorage:YES];
            
            return nil;
        }];
    }
}

- (void)sendCallNotificationMessageWithState:(QMCallNotificationState)state duration:(NSTimeInterval)duration {
    
    QBChatMessage *message = [self _callNotificationMessageForSession:self.session state:state];
    
    if (duration > 0) {
        
        message.callDuration = duration;
    }
    
    [self _sendNotificationMessage:message];
}

// MARK: - QMCallKitAdapterUsersStorageProtocol protocol impl

- (void)userWithID:(NSUInteger)userID completion:(void (^)(QBUUser * _Nonnull))completion {
    [[self.serviceManager.usersService getUserWithID:userID] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull t) {
        if (completion != nil) {
            completion(t.result);
        }
        return nil;
    }];
}

//MARK: - Helpers

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_SETTINGS", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                      }]];
    
    UIViewController *viewController = [[[(UISplitViewController *)[UIApplication sharedApplication].keyWindow.rootViewController viewControllers] firstObject] selectedViewController];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

@end
