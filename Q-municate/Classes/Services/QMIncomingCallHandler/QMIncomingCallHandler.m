//
//  QMIncomingCallHandler.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMIncomingCallHandler.h"
#import "QMChatReceiver.h"

@interface QMIncomingCallHandler ()

@property (strong, nonatomic) QMIncomingCallController *incomingCallController;
@property (strong, nonatomic) UIView *activityView;

@end

@implementation QMIncomingCallHandler


- (id)init {
    
    if (self = [super init]) {

        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.locale = [NSLocale currentLocale];
        self.dateFormatter.dateFormat = @"HH':'mm";
        self.dateFormatter.timeZone = [NSTimeZone localTimeZone];
        
        [self subscribeToNotifications];
    }
    return self;
}

- (void)dealloc {
    [[QMChatReceiver instance] unsubscribeForTarget:self];
}

- (void)showIncomingCallControllerWithOpponentID:(NSUInteger)opponentID conferenceType:(enum QBVideoChatConferenceType)conferenceType {
    
    if (!self.incomingCallController) {
            self.incomingCallController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kIncomingCallIdentifier];
        self.incomingCallController.callsHandler = self;
        
        self.incomingCallController.opponentID = opponentID;
        self.incomingCallController.callType = conferenceType;
        
        [self.root presentViewController:self.incomingCallController animated:NO completion:nil];
    }
}

- (void)subscribeToNotifications
{
    __weak typeof(self) weakSelf = self;
    
    [[QMChatReceiver instance] chatAfrerDidReceiveCallRequestCustomParametesrWithTarget:self block:^(NSUInteger userID, NSString *sessionID, enum QBVideoChatConferenceType conferenceType, NSDictionary *customParameters) {
        [weakSelf showIncomingCallControllerWithOpponentID:userID conferenceType:conferenceType];
    }];
    
    [[QMChatReceiver instance] chatAfterCallDidRejectByUserWithTarget:self block:^(NSUInteger userID) {
        [weakSelf hideIncomingCallController];
    }];
    
    [[QMChatReceiver instance] chatAfterCallDidStopWithTarget:self block:^(NSUInteger userID, NSString *status) {
        [weakSelf hideIncomingCallController];
    }];
}

- (UIViewController *)root {
    return [[UIApplication sharedApplication].delegate.window rootViewController];
}

- (void)hideIncomingCallController
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.incomingCallController dismissViewControllerAnimated:YES completion:^{
            self.incomingCallController = nil;
        }];
    });
}

@end
