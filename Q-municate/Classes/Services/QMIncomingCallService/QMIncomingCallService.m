//
//  Utilities.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMIncomingCallService.h"
#import "QMChatReceiver.h"

@interface QMIncomingCallService ()

@property (strong, nonatomic) QMIncomingCallController *incomingCallController;
@property (strong, nonatomic) UIView *activityView;

@end

@implementation QMIncomingCallService


- (id)init
{
    if (self= [super init]) {

        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setLocale:[NSLocale currentLocale]];
        [self.dateFormatter setDateFormat:@"HH':'mm"];
        [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        self.incomingCallController = nil;
        
        [self subscribeToNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showIncomingCallControllerWithOpponentID:(NSUInteger)opponentID conferenceType:(QBVideoChatConferenceType)conferenceType
{
    if (!self.incomingCallController) {
        
        self.incomingCallController =
        [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kIncomingCallIdentifier];
        
        self.incomingCallController.opponentID = opponentID;
        
        self.incomingCallController.callType = conferenceType;
        
        [self.root presentViewController:self.incomingCallController
                                                     animated:NO completion:nil];
    }
}

- (void)subscribeToNotifications
{
    [[QMChatReceiver instance]chatAfrerDidReceiveCallRequestCustomParametesrWithTarget:self block:^(NSUInteger userID, NSString *sessionID, QBVideoChatConferenceType conferenceType, NSDictionary *customParameters) {
        [self showIncomingCallControllerWithOpponentID:userID conferenceType:conferenceType];
    }];
    
    [[QMChatReceiver instance] chatAfterCallDidRejectByUserWithTarget:self block:^(NSUInteger userID) {
        [self hideIncomingCallControllerWithStatus:nil];
    }];
    
    [[QMChatReceiver instance] chatAfterCallDidStopWithTarget:self block:^(NSUInteger userID, NSString *status) {
        [self hideIncomingCallControllerWithStatus:nil];
    }];
}

- (UIViewController *)root {
    return [[UIApplication sharedApplication].delegate.window rootViewController];
}

- (void)dismissIncomingCallController {
    
    if (self.incomingCallController) {
        [self.root dismissViewControllerAnimated:NO completion:^{
            self.incomingCallController = nil;
        }];
    }
}

- (void)hideIncomingCallControllerWithStatus:(NSString *)status
{
    [self performSelector:@selector(dismissIncomingCallController) withObject:self afterDelay:2.0f];
}

@end
