//
//  QMStatusStringBuilder.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/26/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMStatusStringBuilder.h"
#import "QMCore.h"

static const NSUInteger kQMStatusStringNamesLimit = 5;

@implementation QMStatusStringBuilder

- (NSString *)statusFromMessage:(QBChatMessage *)message forDialogType:(QBChatDialogType)dialogType {
    
    NSNumber *currentUserID = @(QMCore.instance.currentProfile.userData.ID);
    
    NSMutableArray *readIDs = [message.readIDs mutableCopy];
    [readIDs removeObject:currentUserID];
    
    NSMutableArray* deliveredIDs = [message.deliveredIDs mutableCopy];
    [deliveredIDs removeObject:currentUserID];
    
    if (dialogType == QBChatDialogTypePrivate) {
        // Private dialogs status
        if (readIDs.count > 0) {
            
            return [message isMediaMessage] ? NSLocalizedString(@"QM_STR_SEEN_STATUS", nil) : NSLocalizedString(@"QM_STR_READ_STATUS", nil);
        }
        
        if (deliveredIDs.count > 0) {
            
            return NSLocalizedString(@"QM_STR_DELIVERED_STATUS", nil);
        }
    }
    else {
        // Group dialogs status
        [deliveredIDs removeObjectsInArray:readIDs];
        NSMutableString *statusString = [NSMutableString string];
        
        if (readIDs.count > 0) {
            // read/seen status text
            if (readIDs.count > kQMStatusStringNamesLimit) {
                
                NSString *localizedString = NSLocalizedString([message isMediaMessage] ? @"QM_STR_SEEN_BY_AMOUNT_PEOPLE_STATUS" : @"QM_STR_READ_BY_AMOUNT_PEOPLE_STATUS", nil);
                [statusString appendFormat:localizedString, readIDs.count];
            }
            else {
                
                NSArray *users = [QMCore.instance.usersService.usersMemoryStorage usersWithIDs:readIDs];
                NSMutableArray *readNames = [users valueForKeyPath:@keypath(QBUUser.new, fullName)];
                
                NSString *localizedString = NSLocalizedString([message isMediaMessage] ? @"QM_STR_SEEN_BY_NAMES_STATUS" : @"QM_STR_READ_BY_NAMES_STATUS", nil);
                [statusString appendFormat:localizedString, [readNames componentsJoinedByString:@", "]];
            }
        }
        
        if (deliveredIDs.count > 0) {
            // delivered status text
            if (readIDs.count > 0) [statusString appendString:@"\n"];
            
            if (deliveredIDs.count > kQMStatusStringNamesLimit) {
                
                [statusString appendFormat:NSLocalizedString(@"QM_STR_DELIVERED_TO_AMOUNT_PEOPLE_STATUS", nil), deliveredIDs.count];
            }
            else {
                
                NSArray *users = [QMCore.instance.usersService.usersMemoryStorage usersWithIDs:deliveredIDs];
                NSMutableArray *deliveredNames = [users valueForKeyPath:@keypath(QBUUser.new, fullName)];
                
                [statusString appendFormat:NSLocalizedString(@"QM_STR_DELIVERED_TO_NAMES_STATUS", nil), [deliveredNames componentsJoinedByString:@", "]];
            }
        }
        
        if (statusString.length > 0) {
            
            return [statusString copy];
        }
    }
    
    QMMessageStatus status = [QMCore.instance.chatService.deferredQueueManager statusForMessage:message];
    NSString *messageStatus = nil;
    
    switch (status) {
            
        case QMMessageStatusSent: {
            
            messageStatus = @"QM_STR_SENT_STATUS";
            break;
        }
            
        case QMMessageStatusSending: {
            
            messageStatus = @"QM_STR_SENDING_STATUS";
            break;
        }
            
        case QMMessageStatusNotSent: {
            
            messageStatus = @"QM_STR_NOT_SENT_STATUS";
            break;
        }
    }
    
    return NSLocalizedString(messageStatus, nil);
}

- (NSString *)messageTextForNotification:(QBChatMessage *)notification {
    
    NSString *messageText = nil;
    QBUUser *sender = [QMCore.instance.usersService.usersMemoryStorage userWithID:notification.senderID];
    QBUUser *recipient = [QMCore.instance.usersService.usersMemoryStorage userWithID:notification.recipientID];
    
    switch (notification.messageType) {
        case QMMessageTypeContactRequest:
        {
            if (notification.senderID == QMCore.instance.currentProfile.userData.ID) {
                
                messageText = NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_ME",nil);
            }
            else {
                
                NSString *stringFormat = [QMCore.instance.contactManager isFriendWithUserID:notification.senderID] ? @"%@ %@" : @"%@\n%@";
                
                messageText = [NSString stringWithFormat:stringFormat, sender.fullName ?: NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil), NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_OPPONENT", nil)];
            }
        }
            break;
            
        case QMMessageTypeAcceptContactRequest:
        {
            messageText = (notification.senderID == QMCore.instance.currentProfile.userData.ID) ? NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_CONFIRM_FOR_ME", nil) : NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_CONFIRM_FOR_OPPONENT", nil);
        }
            break;
            
        case QMMessageTypeRejectContactRequest:
        {
            messageText = (notification.senderID == QMCore.instance.currentProfile.userData.ID) ? NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_REJECT_FOR_ME",nil) : NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_REJECT_FOR_OPPONENT", nil);
        }
            break;
            
        case QMMessageTypeDeleteContactRequest:
        {
            messageText = (notification.senderID == QMCore.instance.currentProfile.userData.ID) ?
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_DELETE_FOR_ME", @"{FullName}"), recipient.fullName] :
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_DELETE_FOR_OPPONENT", @"{FullName}"), sender.fullName];
        }
            break;
            
        case QMMessageTypeUpdateGroupDialog:
        {
            switch (notification.dialogUpdateType) {
                case QMDialogUpdateTypeName:
                    messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_UPDATE_GROUP_NAME_TEXT", nil), sender.fullName ?: NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil), notification.dialogName];
                    break;
                    
                case QMDialogUpdateTypePhoto:
                    messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_UPDATE_GROUP_AVATAR_TEXT", nil), sender.fullName ?: NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil)];
                    break;
                    
                case QMDialogUpdateTypeOccupants:
                {
                    if (notification.addedOccupantsIDs.count > 0) {
                        
                        NSArray *users = [QMCore.instance.usersService.usersMemoryStorage usersWithIDs:notification.addedOccupantsIDs];
                        NSString *fullNameString = [self fullNamesString:users];
                        messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_ADD_USERS_TO_EXIST_GROUP_CONVERSATION_TEXT", nil), sender.fullName ?: NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil), fullNameString];
                    }
                    else if (notification.deletedOccupantsIDs.count > 0) {
                        
                        QBUUser *leavedUser = [QMCore.instance.usersService.usersMemoryStorage userWithID:[[notification.deletedOccupantsIDs firstObject] integerValue]];
                        
                        messageText = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_LEAVE_GROUP_CONVERSATION_TEXT", nil), leavedUser.fullName ?: NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil)];
                    }
                }
                    
                    break;
                
                case QMDialogUpdateTypeNone:
                    break;
            }
        }
            break;

        case QMMessageTypeText:
            break;
            
        case QMMessageTypeCreateGroupDialog:
            break;
    }
    
    return messageText;
}

//MARK: - Helpers

- (NSString *)fullNamesString:(NSArray *)users {
    
    if (users.count == 0) {
        
        return @"Unknown users";
    }
    
    NSMutableString *mutableString = [NSMutableString new];
    
    for (QBUUser *usr in users) {
        
        [mutableString appendString:usr.fullName ?: NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil)];
        [mutableString appendString:@", "];
    }
    
    [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 2, 2)];
    
    return [mutableString copy];
}

@end
