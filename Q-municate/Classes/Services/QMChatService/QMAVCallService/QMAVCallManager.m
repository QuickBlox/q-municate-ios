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

@interface QMAVCallManager()
@property (strong, nonatomic, readonly) UIStoryboard *mainStoryboard;

/// active view controller
@property (weak, nonatomic) UIViewController *currentlyPresentedViewController;
@end

const NSTimeInterval kQBAnswerTimeInterval = 20.0f;
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
        if( IS_IPAD ){
            self.speakerEnabled = YES;
        }
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

- (void)callToUsers:(NSArray *)users withConferenceType:(QBConferenceType)conferenceType{
    
    assert(users && users.count);
    
    if (self.session) {
        return;
    }

    QBRTCSession *session = [QBRTCClient.instance createNewSessionWithOpponents:users
                                     withConferenceType:conferenceType];
    
    if (session) {
        
        self.session = session;
        
        QMBaseCallsController *vc = (QMBaseCallsController *)[self.mainStoryboard instantiateViewControllerWithIdentifier:(conferenceType == QBConferenceTypeVideo) ? kVideoCallController : kAudioCallController];
        
        vc.session = self.session;
        vc.opponent = [[QMApi instance] userWithID:[((NSNumber *)users[0]) unsignedIntegerValue]];
        
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
        [navVC setNavigationBarHidden:YES];
        
        [self.rootViewController presentViewController:navVC
                                              animated:YES
                                            completion:nil];
        [self.session startCall:@{kUserIds: users}];
        self.currentlyPresentedViewController = navVC;
    }
    else {
        
        [SVProgressHUD showErrorWithStatus:@"Error creating new session"];
    }
}

#pragma mark - QBWebRTCChatDelegate

- (void)didReceiveNewSession:(QBRTCSession *)session {
    
    if (self.session) {
        [session rejectCall:@{@"reject" : @"busy"}];
        return;
    }
    
    self.session = session;
    [QMSoundManager playRingtoneSound];
    
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
    ILog(@"session will close");
    [SVProgressHUD dismiss];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    if( self.session != session ){
        // may be we rejected someone else call while we are talking with another person
        return;
    }
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
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

@end
