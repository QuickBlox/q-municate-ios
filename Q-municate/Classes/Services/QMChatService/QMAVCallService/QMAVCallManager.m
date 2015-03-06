//
//  QMAVCallManager.m
//  Q-municate
//
//  Created by Anton Sokolchenko on 3/6/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMAVCallManager.h"
#import "SVProgressHUD.h"

@interface QMAVCallManager()
@property (strong, nonatomic, readonly) UIStoryboard *mainStoryboard;

/// active view controller
@property (weak, nonatomic) UIViewController *currentlyPresentedViewController;
@property (strong, nonatomic) QBRTCSession *session;
@end

NSString *const kAudioCallController = @"AudioCallViewIdentifier";
NSString *const kVideoCallController = @"VideoCallViewIdentifier";
NSString *const kIncomingCallController = @"IncomingCallIdentifier";

@implementation QMAVCallManager

+ (instancetype)instance {
    
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    }
    
    return self;
}

/// @return array of NSNumber instances
- (NSArray *)usersIDsFromQBUUserArray:(NSArray *)users{
    NSMutableArray *arr = [NSMutableArray array];
    for(QBUUser *user in users){
        [arr addObject:@(user.ID)];
    }
    return [arr copy];
}

#pragma mark - RootViewController

- (UIViewController *)rootViewController {
    
    return UIApplication.sharedApplication.delegate.window.rootViewController;
}

#pragma mark - Public methods

- (void)callToUsers:(NSArray *)users withConferenceType:(QBConferenceType)conferenceType {
    
    if (self.session) {
        return;
    }
    
    NSArray *opponentsIDs = [self usersIDsFromQBUUserArray:users];
    
    QBRTCSession *session =
    [QBRTCClient.instance createNewSessionWithOpponents:opponentsIDs
                                     withConferenceType:conferenceType];
    
    if (session) {
        
        self.session = session;
        
        id vc = [self.mainStoryboard instantiateViewControllerWithIdentifier:(conferenceType == QBConferenceTypeVideo) ? kVideoCallController : kAudioCallController];
        
        if( [vc respondsToSelector:@selector(setSession:)] ){
            [vc setSession:self.session];
        }
        
        self.currentlyPresentedViewController = vc;
        [self.rootViewController presentViewController:vc
                                              animated:YES
                                            completion:nil];
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
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            self.session = nil;
            if( [weakSelf currentlyPresentedViewController] ){
                [[weakSelf currentlyPresentedViewController] dismissViewControllerAnimated:YES completion:nil];
            }
        });
    }
}

@end
