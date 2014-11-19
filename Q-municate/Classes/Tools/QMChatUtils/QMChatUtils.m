//
//  QMChatUtils.m
//  Q-municate
//
//  Created by Igor Alefirenko on 17.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatUtils.h"
#import "QMApi.h"

@implementation QMChatUtils


+ (NSString *)messageTextForNotification:(QBChatAbstractMessage *)notification
{
    NSString *messageText = nil;
    QBUUser *sender = [[QMApi instance] userWithID:notification.senderID];
    QBUUser *recipient = [[QMApi instance] userWithID:notification.recipientID];
    
    switch (notification.cParamNotificationType) {
        case QMMessageNotificationTypeSendContactRequest:
        {
            messageText = (notification.senderID == QMApi.instance.currentUser.ID) ?  NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_ME",nil) : [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_OPPONENT", @"{FullName}"), sender.fullName];
        }
            break;
            
        case QMMessageNotificationTypeConfirmContactRequest:
        {
            messageText = (notification.senderID == QMApi.instance.currentUser.ID) ? NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_CONFIRM_FOR_ME", nil) : NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_CONFIRM_FOR_OPPONENT", nil);
        }
            break;
            
        case QMMessageNotificationTypeRejectContactRequest:
        {
            messageText = (notification.senderID == QMApi.instance.currentUser.ID) ? NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_REJECT_FOR_ME",nil) : NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_REJECT_FOR_OPPONENT", nil);
        }
            break;
            
        case QMMessageNotificationTypeDeleteContactRequest:
        {
            messageText = (notification.senderID == QMApi.instance.currentUser.ID) ?
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_DELETE_FOR_ME", @"{FullName}"), recipient.fullName] :
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_DELETE_FOR_OPPONENT", @"{FullName}"), sender.fullName];
        }
            break;
            
        case QMMessageNotificationTypeCreateGroupDialog:
        {
            NSArray *users = [[QMApi instance] usersWithIDs:notification.cParamDialogOccupantsIDs];
            NSString *fullNameString = [self fullNamesString:users];
            messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_ADD_USERS_TO_GROUP_CONVERSATION_TEXT", nil), sender.fullName, fullNameString];
        }
            break;
            
        case QMMessageNotificationTypeUpdateGroupDialog:
        {
            if (notification.cParamDialogRoomPhoto) {
                messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_UPDATE_GROUP_AVATAR_TEXT", nil), sender.fullName];
            } else if (notification.cParamDialogRoomName) {
                messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_UPDATE_GROUP_NAME_TEXT", nil), sender.fullName, notification.cParamDialogRoomName];
            } else if (notification.cParamDialogOccupantsIDs) {
                
                NSArray *users = [[QMApi instance] usersWithIDs:notification.cParamDialogOccupantsIDs];
                NSString *fullNameString = [self fullNamesString:users];
                messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_ADD_USERS_TO_GROUP_CONVERSATION_TEXT", nil), sender.fullName, fullNameString];
                
            } else if (notification.cParamDialogDeletedID) {
                QBUUser *leavedUser = [[QMApi instance] userWithID:notification.cParamDialogDeletedID.integerValue];
                messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_LEAVE_GROUP_CONVERSATION_TEXT", nil), leavedUser.fullName];
            }
        }
            break;
            
        default:
            break;
    }
    return messageText;
}

+ (NSString *)messageTextForPushWithNotification:(QBChatMessage *)notification
{
    NSString *message = nil;
    QBUUser *sender = [[QMApi instance] userWithID:notification.senderID];
    if (notification.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
        message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_OPPONENT", @"{FullName}"), sender.fullName];
    } else if (notification.cParamNotificationType == QMMessageNotificationTypeConfirmContactRequest) {
        message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_CONFIRM_FOR_PUSH", @"{FullName}"), sender.fullName];
    } else if (notification.cParamNotificationType == QMMessageNotificationTypeRejectContactRequest) {
        message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_REJECT_FOR_PUSH", @"{FullName}"), sender.fullName];
    } else if (notification.cParamNotificationType == QMMessageNotificationTypeDeleteContactRequest) {
        message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_DELETE_FOR_OPPONENT", @"{FullName}"), sender.fullName];
    }
    
    return message;
}

+ (NSString *)fullNamesString:(NSArray *)users
{
    NSMutableString *mutableString = [NSMutableString new];
    for (QBUUser *usr in users) {
        [mutableString appendString:usr.fullName];
        [mutableString appendString:@", "];
    }
    [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 2, 2)];
    return mutableString;
}

+ (NSString *)idsStringWithoutSpaces:(NSArray *)users
{
    NSMutableString *mutableString = [NSMutableString new];
    for (QBUUser *usr in users) {
        [mutableString appendString:[NSString stringWithFormat:@"%lu", (unsigned long)usr.ID]];
        [mutableString appendString:@","];
    }
    [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 1, 1)];
    return mutableString;
}

+ (NSString *)messageForText:(NSString *)text participants:(NSArray *)participants
{
    NSString *addedUsersNames = [self fullNamesString:participants];
    return [NSString stringWithFormat:text, [QMApi instance].currentUser.fullName, addedUsersNames];
}

@end
