//
//  QMCallKitAdapter.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 11/30/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMCallKitAdapter.h"

#import <CallKit/CallKit.h>

#import "QMHelpers.h"
#import "QMLog.h"

static const NSInteger QMDefaultMaximumCallsPerCallGroup = 1;
static const NSInteger QMDefaultMaximumCallGroups = 1;

@interface QMCallKitAdapter () <CXProviderDelegate>
{
    __weak id <QMCallKitAdapterUsersStorageProtocol> _usersStorage;
    
    CXCallController *_callController;
}

@property (strong, nonatomic) CXProvider *provider;
@property (strong, nonatomic) QBRTCSession *session;
@property (assign, nonatomic) BOOL callStarted;

@property (copy, nonatomic) dispatch_block_t actionCompletionBlock;
@property (copy, nonatomic) dispatch_block_t onAcceptActionBlock;

@end

@implementation QMCallKitAdapter

// MARK: - Static

+ (CXProviderConfiguration *)configuration {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc] initWithLocalizedName:appName];
    config.supportsVideo = YES;
    config.maximumCallsPerCallGroup = QMDefaultMaximumCallsPerCallGroup;
    config.maximumCallGroups = QMDefaultMaximumCallGroups;
    config.supportedHandleTypes = [NSSet setWithObjects:@(CXHandleTypeGeneric), @(CXHandleTypePhoneNumber), nil];
    config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"CallKitLogo"]);
    config.ringtoneSound = @"ringtone.wav";
    return config;
}

+ (BOOL)isCallKitAvailable {
    static BOOL callKitAvailable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if TARGET_IPHONE_SIMULATOR
        callKitAvailable = NO;
#else
        callKitAvailable = iosMajorVersion() >= 10;
#endif
    });
    return callKitAvailable;
}

// MARK: - Initialization

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        CXProviderConfiguration *configuration = [[self class] configuration];
        _provider = [[CXProvider alloc] initWithConfiguration:configuration];
        [_provider setDelegate:self queue:nil];
        
        _callController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (instancetype)initWithUsersStorage:(id<QMCallKitAdapterUsersStorageProtocol>)usersStorage {
    self = [self init];
    if (self != nil) {
        _usersStorage = usersStorage;
    }
    return self;
}

// MARK: - Call management

- (void)startCallWithUserID:(NSNumber *)userID session:(QBRTCSession *)session uuid:(NSUUID *)uuid {
    _session = session;
    __weak __typeof(self)weakSelf = self;
    [_usersStorage userWithID:[userID integerValue] completion:^(QBUUser * _Nonnull user) {
        __typeof(weakSelf)strongSelf = weakSelf;
        NSString *contactIdentifier = user.fullName ?: NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil);;
        CXHandle *handle = [strongSelf handleForUserID:[userID integerValue]];
        CXStartCallAction *action = [[CXStartCallAction alloc] initWithCallUUID:uuid handle:handle];
        action.contactIdentifier = contactIdentifier;
        
        CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
        [self requestTransaction:transaction completion:^(__unused BOOL succeed) {
            CXCallUpdate *update = [[CXCallUpdate alloc] init];
            update.remoteHandle = handle;
            update.localizedCallerName = contactIdentifier;
            update.supportsHolding = NO;
            update.supportsGrouping = NO;
            update.supportsUngrouping = NO;
            update.supportsDTMF = NO;
            update.hasVideo = session.conferenceType == QBRTCConferenceTypeVideo;
            
            [strongSelf.provider reportCallWithUUID:uuid updated:update];
        }];
    }];
}

- (void)endCallWithUUID:(NSUUID *)uuid completion:(dispatch_block_t)completion {
    if (_session == nil) {
        return;
    }
    
    CXEndCallAction *action = [[CXEndCallAction alloc] initWithCallUUID:uuid];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:action];
    
    dispatchOnMainThread(^{
        [self requestTransaction:transaction completion:nil];
    });
    
    if (completion != nil) {
        self.actionCompletionBlock = completion;
    }
}

- (void)reportIncomingCallWithUserID:(NSNumber *)userID session:(QBRTCSession *)session uuid:(NSUUID *)uuid onAcceptAction:(dispatch_block_t)onAcceptAction completion:(void (^)(BOOL))completion {
    QMLog(@"[QMCallKitAdapter] Report incoming call %@", uuid);
    
    if (_session != nil) {
        // session in progress
        return;
    }
    
    _session = session;
    self.onAcceptActionBlock = onAcceptAction;
    
    __weak __typeof(self)weakSelf = self;
    [_usersStorage userWithID:[userID integerValue] completion:^(QBUUser * _Nonnull user) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSString *callerName = user.fullName ?: NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil);
        
        CXCallUpdate *update = [[CXCallUpdate alloc] init];
        update.remoteHandle = [strongSelf handleForUserID:[userID integerValue]];
        update.localizedCallerName = callerName;
        update.supportsHolding = NO;
        update.supportsGrouping = NO;
        update.supportsUngrouping = NO;
        update.supportsDTMF = NO;
        update.hasVideo = session.conferenceType == QBRTCConferenceTypeVideo;
        
        QMLog(@"[QMCallKitAdapter] Activating audio session.");
        QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
        audioSession.useManualAudio = YES;
        if (!audioSession.isInitialized) {
            [audioSession initializeWithConfigurationBlock:^(QBRTCAudioSessionConfiguration *configuration) {
                // adding blutetooth support
                configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth;
                configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP;
                
                // adding airplay support
                configuration.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay;
            }];
        }
        
        [strongSelf.provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
            BOOL silent = ([error.domain isEqualToString:CXErrorDomainIncomingCall] && error.code == CXErrorCodeIncomingCallErrorFilteredByDoNotDisturb);
            dispatchOnMainThread(^{
                if (completion != nil) {
                    completion(silent);
                }
            });
        }];
    }];
}

- (void)updateCallWithUUID:(NSUUID *)uuid connectingAtDate:(NSDate *)date {
    [_provider reportOutgoingCallWithUUID:uuid startedConnectingAtDate:date];
}

- (void)updateCallWithUUID:(NSUUID *)uuid connectedAtDate:(NSDate *)date {
    [_provider reportOutgoingCallWithUUID:uuid connectedAtDate:date];
}

// MARK: - CXProviderDelegate protocol

- (void)providerDidReset:(CXProvider *)__unused provider {
}

- (void)provider:(CXProvider *)__unused provider performStartCallAction:(CXStartCallAction *)action {
    if (_session == nil) {
        [action fail];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatchOnMainThread(^{
        [weakSelf.session startCall:nil];
        weakSelf.callStarted = YES;
        [action fulfill];
    });
}

- (void)provider:(CXProvider *)__unused provider performAnswerCallAction:(CXAnswerCallAction *)action {
    if (_session == nil) {
        [action fail];
        return;
    }
    
    if (iosMajorVersion() == 10) {
        // Workaround for webrtc on ios 10, because first incoming call does not have audio
        // due to incorrect category: AVAudioSessionCategorySoloAmbient
        // webrtc need AVAudioSessionCategoryPlayAndRecord
        NSError *err = nil;
        if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&err]) {
            QMLog(@"[QMCallKitAdapter] Error setting category for webrtc workaround.");
        }
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatchOnMainThread(^{
        [weakSelf.session acceptCall:nil];
        weakSelf.callStarted = YES;
        [action fulfill];
        
        if (weakSelf.onAcceptActionBlock != nil) {
            weakSelf.onAcceptActionBlock();
            weakSelf.onAcceptActionBlock = nil;
        }
    });
}

- (void)provider:(CXProvider *)__unused provider performEndCallAction:(CXEndCallAction *)action {
    if (_session == nil) {
        [action fail];
        return;
    }
    
    QBRTCSession *session = _session;
    _session = nil;
    
    __weak __typeof(self)weakSelf = self;
    dispatchOnMainThread(^{
        QBRTCAudioSession *audioSession = [QBRTCAudioSession instance];
        audioSession.audioEnabled = NO;
        audioSession.useManualAudio = NO;
        
        if (session.state != QBRTCSessionStateClosed) {
            if (weakSelf.callStarted) {
                [session hangUp:nil];
            }
            else {
                [session rejectCall:nil];
            }
            
            if (weakSelf.onCallEndedByCallKitAction != nil) {
                weakSelf.onCallEndedByCallKitAction();
            }
        }
        
        weakSelf.callStarted = NO;
        
        [action fulfillWithDateEnded:[NSDate date]];
        
        if (weakSelf.actionCompletionBlock != nil) {
            weakSelf.actionCompletionBlock();
            weakSelf.actionCompletionBlock = nil;
        }
    });
}

- (void)provider:(CXProvider *)__unused provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    if (_session == nil) {
        [action fail];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatchOnMainThread(^{
        weakSelf.session.localMediaStream.audioTrack.enabled = !action.isMuted;
        [action fulfill];
        
        if (weakSelf.onMicrophoneMuteAction != nil) {
            weakSelf.onMicrophoneMuteAction();
        }
    });
}

- (void)provider:(CXProvider *)__unused provider didActivateAudioSession:(AVAudioSession *)audioSession {
    QMLog(@"[QMCallKitAdapter] Activated audio session.");
    QBRTCAudioSession *rtcAudioSession = [QBRTCAudioSession instance];
    [rtcAudioSession audioSessionDidActivate:audioSession];
    // enabling audio now
    rtcAudioSession.audioEnabled = YES;
}

- (void)provider:(CXProvider *)__unused provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    QMLog(@"[QMCallKitAdapter] Dectivated audio session.");
    [[QBRTCAudioSession instance] audioSessionDidDeactivate:audioSession];
    // deinitializing audio session after iOS deactivated it for us
    QBRTCAudioSession *session = [QBRTCAudioSession instance];
    if (session.isInitialized) {
        QMLog(@"[QMCallKitAdapter] Deinitializing session in CallKit callback.");
        [session deinitialize];
    }
}

// MARK: - Helpers

- (CXHandle *)handleForUserID:(NSUInteger)userID {
    return [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:[NSString stringWithFormat:@"%tu", userID]];
}

static inline void dispatchOnMainThread(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (void)requestTransaction:(CXTransaction *)transaction completion:(void (^)(BOOL))completion {
    [_callController requestTransaction:transaction completion:^(NSError *error) {
        if (error != nil) {
            QMLog(@"[QMCallKitAdapter] Error: %@", error);
        }
        if (completion != nil) {
            completion(error == nil);
        }
    }];
}

@end
