//
//  QMApi+Calls.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMAVCallManager.h"

@implementation QMApi (Calls)

- (void)callToUser:(NSNumber *)userID conferenceType:(enum QBRTCConferenceType)conferenceType
{
    [self callToUser:userID conferenceType:conferenceType sendPushNotificationIfUserIsOffline:YES];
}

- (void)callToUser:(NSNumber *)userID conferenceType:(enum QBRTCConferenceType)conferenceType sendPushNotificationIfUserIsOffline:(BOOL)pushEnabled
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
