//
//  QMApi+Calls.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 16/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMAVCallManager.h"

@implementation QMApi (Calls)

- (void)callToUser:(NSNumber *)userID conferenceType:(enum QBConferenceType)conferenceType
{
    [self callToUser:userID conferenceType:conferenceType sendPushNotificationIfUserIsOffline:YES];
}

- (void)callToUser:(NSNumber *)userID conferenceType:(enum QBConferenceType)conferenceType sendPushNotificationIfUserIsOffline:(BOOL)pushEnabled
{
    [self.avCallManager callToUsers:@[userID] withConferenceType:conferenceType pushEnabled:pushEnabled];
}

- (void)acceptCall
{
    [self.avCallManager acceptCall];
}

- (void)rejectCall
{
    [self.avCallManager rejectCall];
}

- (void)finishCall
{
    [self.avCallManager hangUpCall];
}

@end
