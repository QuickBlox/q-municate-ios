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
@property (strong, nonatomic) QBRTCSession *session;
@end

const NSTimeInterval kQBAnswerTimeInterval = 15.f;
const NSTimeInterval kQBRTCDisconnectTimeInterval = 10.f;

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
    
    if (self.session) {
        return;
    }

    QBRTCSession *session = [QBRTCClient.instance createNewSessionWithOpponents:users
                                     withConferenceType:conferenceType];
    
    if (session) {
        
        self.session = session;
        
        QMBaseCallsController *vc = (QMBaseCallsController *)[self.mainStoryboard instantiateViewControllerWithIdentifier:(conferenceType == QBConferenceTypeVideo) ? kVideoCallController : kAudioCallController];
        
        vc.session = self.session;
        
        self.currentlyPresentedViewController = vc;
        [self.rootViewController presentViewController:vc
                                              animated:YES
                                            completion:nil];
        [self.session startCall:@{kUserIds: users}];
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
    //[QMSoundManager playRingtoneSound];
    
    QMIncomingCallController *incomingVC =
    [self.mainStoryboard instantiateViewControllerWithIdentifier:kIncomingCallController];
    
    incomingVC.session = session;
    incomingVC.opponentID = [session.callerID unsignedIntegerValue];
    incomingVC.callType = session.conferenceType;
    
    [self.rootViewController presentViewController:incomingVC
                                          animated:YES
                                        completion:nil];
    
    self.currentlyPresentedViewController = incomingVC;
}

- (void)sessionWillClose:(QBRTCSession *)session {
    
    NSLog(@"session will close");
}

- (void)sessionDidClose:(QBRTCSession *)session {
    __weak __typeof(self)weakSelf = self;
    if (session == self.session ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            weakSelf.session = nil;
            if( [weakSelf currentlyPresentedViewController] ){
                [[weakSelf currentlyPresentedViewController] dismissViewControllerAnimated:YES completion:nil];
            }
        });
    }
}

@end
