//
//  QMVideoCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMVideoCallController.h"
#import "QMAVCallManager.h"

@implementation QMVideoCallController

NSString *const kGoToDuringVideoCallControllerSegue= @"goToDuringVideoCallSegueIdentifier";

#pragma mark - Overridden methods

- (void)viewDidLoad {
    [super viewDidLoad];

    if( QMApi.instance.avCallManager.localVideoTrack ){
        [self.opponentsView setVideoTrack:QMApi.instance.avCallManager.localVideoTrack];
    }
}

- (IBAction)stopCallTapped:(id)sender {
    [self.opponentsView setHidden:YES];
    [self.opponentsView setVideoTrack:nil];
    
    [super stopCallTapped:sender];
}

- (void)startCall {
    [[QMApi instance] callToUser:@(self.opponent.ID) conferenceType:QBConferenceTypeVideo sendPushNotificationIfUserIsOffline:YES];
    
}

- (void)confirmCall {
    [super confirmCall];
    [self callStartedWithUser];
}

- (void)callStartedWithUser {
    [self.contentView hide];
    [self.opponentsView setVideoTrack:nil];
    [self performSegueWithIdentifier:kGoToDuringVideoCallControllerSegue sender:nil];
}

- (void)callStoppedByOpponentForReason:(NSString *)reason {
    [self.contentView show];
    [self.opponentsView setHidden:YES];
    [super callStoppedByOpponentForReason:reason];
}

#pragma mark QBRTCSession delegate -

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID {
    [super session:session connectedToUser:userID];
    [self callStartedWithUser];
}

- (void)session:(QBRTCSession *)session didReceiveLocalVideoTrack:(QBRTCVideoTrack *)videoTrack {
    [super session:session didReceiveLocalVideoTrack:videoTrack];
    [self.opponentsView setVideoTrack:videoTrack];
}

@end
