//
//  QBChatMessage+QMCallNotifications.h
//  Q-municate
//
//  Created by Injoit on 7/13/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>

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
