//
//  QMApi+Calls.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 16/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMAVCallService.h"

@implementation QMApi (Calls)

- (void)callUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView conferenceType:(enum QBVideoChatConferenceType)conferenceType
{
    [self.avCallService callToUser:userID opponentView:opponentView conferenceType:conferenceType];
}

- (void)acceptCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView
{
    [self.avCallService acceptCallFromUser:userID andOpponentView:opponentView];
}

- (void)rejectCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView
{
    [self.avCallService rejectCallFromUser:userID andOpponentView:opponentView];
}

- (void)finishCall
{
    [self.avCallService finishCallFromOpponent];
}

@end
