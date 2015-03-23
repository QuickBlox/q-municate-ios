//
//  QMAudioCallController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAudioCallController.h"

@implementation QMAudioCallController

#pragma mark - Overridden methods

- (void)startCall {
    [[QMApi instance] callToUser:@(self.opponent.ID) conferenceType:QBConferenceTypeAudio];
    [QMSoundManager playCallingSound];
}

@end