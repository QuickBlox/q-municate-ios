//
//  QMChatUtils.m
//  Q-municate
//
//  Created by Igor Alefirenko on 17.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatUtils.h"

@implementation QMChatUtils

+ (NSString *)notificationTextForNotificationType:(QMMessageNotificationType)notificationType
{
    NSString *messageText = nil;
    
    switch (notificationType) {
        case QMMessageNotificationTypeSendContactRequest:
        {
            messageText = NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND", @"{FullName}");
        }
            break;
            
        case QMMessageNotificationTypeConfirmContactRequest:
        {
            messageText = NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_CONFIRM_FOR_ME", @"{FullName}");
        }
            break;
            
        case QMMessageNotificationTypeRejectContactRequest:
        {
            messageText = NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_REJECT_FOR_ME", @"{FullName}");
        }
            break;
            
        case QMMessageNotificationTypeDeleteContactRequest:
        {
            messageText = NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_DELETE", @"{FullName}");
        }
            break;
            
        default:
            break;
    }
    return messageText;
}

@end
