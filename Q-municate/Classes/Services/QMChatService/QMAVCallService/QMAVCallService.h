//
//  QMAVCallService.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

@interface QMAVCallService : QMBaseService

- (void)callToUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView conferenceType:(enum QBVideoChatConferenceType)conferenceType;

- (void)acceptCallFromUser:(NSUInteger)userID andOpponentView:(QBVideoView *)opponentView;
- (void)rejectCallFromUser:(NSUInteger)userID andOpponentView:(QBVideoView *)opponentView;

- (void)finishCallFromOpponent;

@end
