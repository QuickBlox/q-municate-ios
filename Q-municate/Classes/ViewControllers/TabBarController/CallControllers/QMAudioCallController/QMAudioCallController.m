//
//  QMAudioCallController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAudioCallController.h"
#import "QMAVCallManager.h"

@implementation QMAudioCallController
{
    BOOL isFirstRun;
}

#pragma mark - Overridden methods

- (void)startCall {
    [[QMApi instance] callToUser:@(self.opponent.ID) conferenceType:QBConferenceTypeAudio];
    [QMSoundManager playCallingSound];
    isFirstRun = YES;
}

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID{
    [super session:session connectedToUser:userID];
    
    if( isFirstRun ){
        isFirstRun = NO;
        // Me is not a caller
    
        if( [QMApi instance].currentUser.ID != [userID unsignedIntegerValue] ){
            [[QBSoundRouter instance] setCurrentSoundRoute:QBSoundRouteReceiver];
        }
        [self updateButtonsState];
    }
}
@end