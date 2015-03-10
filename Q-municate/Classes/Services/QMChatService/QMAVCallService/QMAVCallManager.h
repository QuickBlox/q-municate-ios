//
//  QMAVCallManager.h
//  Q-municate
//
//  Created by Anton Sokolchenko on 3/6/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMIncomingCallController.h"
#import "QMBaseService.h"

@interface QMAVCallManager : QMBaseService <QBRTCClientDelegate>

- (void)acceptCall;
- (void)rejectCall;
- (void)hangUpCall;

/**
 *  call to users ids
 *
 *  @param users          array of QBUUser instances
 *  @param conferenceType QBConferenceType
 */
- (void)callToUsers:(NSArray *)users withConferenceType:(QBConferenceType)conferenceType;

@end
