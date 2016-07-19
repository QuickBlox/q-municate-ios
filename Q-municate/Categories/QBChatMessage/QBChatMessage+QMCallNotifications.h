//
//  QBChatMessage+QMCallNotifications.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QMCallNotificationType) {
    
    QMCallNotificationTypeNone,
    QMCallNotificationTypeAudio,
    QMCallNotificationTypeVideo
};

typedef NS_ENUM(NSUInteger, QMCallNotificationState) {
    
    QMCallNotificationStateNone,
    QMCallNotificationStateHangUp,
    QMCallNotificationStateMissedNoAnswer
};

@interface QBChatMessage (QMCallNotifications)

@property (assign, nonatomic) QMCallNotificationType callNotificationType;
@property (assign, nonatomic) QMCallNotificationState callNotificationState;

@property (assign, nonatomic) NSUInteger callerUserID;
@property (strong, nonatomic) NSIndexSet *calleeUserIDs;

@property (assign, nonatomic) NSTimeInterval callDuration;

- (BOOL)isCallNotificationMessage;

@end
