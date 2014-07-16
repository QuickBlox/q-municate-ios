//
//  QMAVCallService.h
//  Qmunicate
//
//  Created by Andrey on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatService.h"

@interface QMAVCallService : NSObject

- (void)callToUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView conferenceType:(QBVideoChatConferenceType)conferenceType;

- (void)acceptCallFromUser:(NSUInteger)userID andOpponentView:(QBVideoView *)opponentView;
- (void)rejectCallFromUser:(NSUInteger)userID andOpponentView:(QBVideoView *)opponentView;

- (void)finishCallFromOpponent;

@end
