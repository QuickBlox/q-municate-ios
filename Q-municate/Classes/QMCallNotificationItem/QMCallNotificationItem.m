//
//  QMCallNotificationItem.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/14/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCallNotificationItem.h"
#import "QMCore.h"
#import "QMHelpers.h"

#import "QBChatMessage+QMCallNotifications.h"

static UIImage *missedAudioIcon() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-audio-missing"];
    });
    
    return image;
}

static UIImage *missedVideoIcon() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-video-missing"];
    });
    
    return image;
}

static UIImage *outgoingAudioIcon() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-audio-outgoing"];
    });
    
    return image;
}

static UIImage *incomingAudioIcon() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-audio-incoming"];
    });
    
    return image;
}

static UIImage *outgoingVideoIcon() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-video-outgoing"];
    });
    
    return image;
}

static UIImage *incomingVideoIcon() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-video-incoming"];
    });
    
    return image;
}

@implementation QMCallNotificationItem

- (instancetype)initWithCallNotificationMessage:(QBChatMessage *)message {
    
    self = [super init];
    if (self != nil) {
        
        switch (message.callNotificationState) {
            
            case QMCallNotificationStateHangUp: {
                
                if (message.callerUserID == [QMCore instance].currentProfile.userData.ID) {
                    
                    if (message.callNotificationType == QMCallNotificationTypeAudio) {
                        
                        _notificationText = NSLocalizedString(@"QM_STR_OUTGOING_CALL", nil);
                        _iconImage = outgoingAudioIcon();
                    }
                    else {
                        
                        _notificationText = NSLocalizedString(@"QM_STR_OUTGOING_VIDEO_CALL", nil);
                        _iconImage = outgoingVideoIcon();
                    }
                }
                else {
                    
                    if (message.callNotificationType == QMCallNotificationTypeAudio) {
                        
                        _notificationText = NSLocalizedString(@"QM_STR_INCOMING_CALL", nil);
                        _iconImage = incomingAudioIcon();
                    }
                    else {
                        
                        _notificationText = NSLocalizedString(@"QM_STR_INCOMING_VIDEO_CALL", nil);
                        _iconImage = incomingVideoIcon();
                    }
                }
                
                _notificationText = [NSString stringWithFormat:@"%@, %@", _notificationText, QMStringForTimeInterval(message.callDuration)];
                
                break;
            }
                
            case QMCallNotificationStateMissedNoAnswer: {
                
                if (message.callNotificationType == QMCallNotificationTypeAudio) {
                    
                    _iconImage = missedAudioIcon();
                    
                    _notificationText = message.callerUserID == [QMCore instance].currentProfile.userData.ID ? NSLocalizedString(@"QM_STR_NO_ANSWER", nil) : NSLocalizedString(@"QM_STR_MISSED_CALL", nil);
                }
                else {
                    
                    _iconImage = missedVideoIcon();
                    
                    _notificationText = message.callerUserID == [QMCore instance].currentProfile.userData.ID ? NSLocalizedString(@"QM_STR_NO_ANSWER", nil) : NSLocalizedString(@"QM_STR_MISSED_VIDEO_CALL", nil);
                }
                
                break;
            }
                
            case QMCallNotificationStateNone:
                break;
        }
    }
    
    return self;
}

@end
