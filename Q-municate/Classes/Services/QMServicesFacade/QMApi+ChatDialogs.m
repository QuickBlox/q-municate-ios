//
//  QMApi+ChatDialogs.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMChatDialogsService.h"
#import "QMApi+Notifications.m"
#import "QMMessagesService.h"
#import "QMContentService.h"
#import "QMChatUtils.h"

NSString const *kQMEditDialogExtendedNameParameter = @"name";
NSString const *kQMEditDialogExtendedPushOccupantsParameter = @"push[occupants_ids][]";
NSString const *kQMEditDialogExtendedPullOccupantsParameter = @"pull_all[occupants_ids][]";

@interface QMApi()

@end

@implementation QMApi (ChatDialogs)

- (void)fetchAllDialogs:(void(^)(void))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService fetchAllDialogs:^(QBDialogsPagedResult *result) {
        
        if ([weakSelf checkResult:result]) {
            [weakSelf.chatDialogsService addDialogs:result.dialogs];
            if (completion) completion();
        }
    }];
}

#pragma mark - Create Chat Dialogs


- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion
{
    [self.chatDialogsService createPrivateChatDialogIfNeededWithOpponent:opponent completion:completion];
}

- (void)createGroupChatDialogWithName:(NSString *)name occupants:(NSArray *)occupants completion:(QBChatDialogResultBlock)completion {
    
    NSArray *occupantIDs = [self idsWithUsers:occupants];
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
    chatDialog.name = name;
    chatDialog.occupantIDs = occupantIDs;
    chatDialog.type = QBChatDialogTypeGroup;
    
    __weak typeof(self)weakSelf = self;
    [self.chatDialogsService createChatDialog:chatDialog completion:^(QBChatDialogResult *result) {
        // send notification from here:
        NSString *messageTypeText = NSLocalizedString(@"QM_STR_ADD_USERS_TO_GROUP_CONVERSATION_TEXT", @"{Full name}");
        NSString *text = [QMChatUtils messageForText:messageTypeText participants:occupants];
        
        // send to private:
        [weakSelf sendGroupChatDialogDidCreateNotificationToUsers:occupants text:text toChatDialog:result.dialog];
        
        // send to group:
        [weakSelf sendGroupChatDialogDidCreateNotificationToAllParticipantsWithText:text occupants:occupants chatDialog:result.dialog];
        
        // add to history:
        [weakSelf.chatDialogsService addDialogToHistory:result.dialog];
        completion(result);
    }];
}


#pragma mark - Edit dialog methods

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    extendedRequest[kQMEditDialogExtendedNameParameter] = dialogName;

    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialogResult *result) {

        if ([weakSelf checkResult:result]) {
            chatDialog.name = dialogName;
            
            NSString *messageTypeText = NSLocalizedString(@"QM_STR_UPDATE_GROUP_NAME_TEXT", @"{Full name}");
            NSString *text = [NSString stringWithFormat:messageTypeText, weakSelf.currentUser.fullName, dialogName];
            [weakSelf sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:chatDialog updateType:@"room_name" content:dialogName];
        }
        completion(result);
    }];
}

- (void)changeAvatar:(UIImage *)avatar forChatDialog:(QBChatDialog *)chatDialog completion:(void (^)(BOOL success))completion
{
    __weak typeof(self)weakSelf = self;
    [self.contentService uploadPNGImage:avatar progress:^(float progress) {
        //
    } completion:^(QBCFileUploadTaskResult *result) {
        // update chat dialog:
        if (!result.success) {
            return;
        }
        NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
        extendedRequest[@"photo"] = result.uploadedBlob.publicUrl;
        [weakSelf.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialogResult *dialogResult) {
            if (dialogResult.success) {
                // send notification:
                NSString *messageTypeText = NSLocalizedString(@"QM_STR_UPDATE_GROUP_AVATAR_TEXT", @"{Full name}");
                NSString *text = [NSString stringWithFormat:messageTypeText, weakSelf.currentUser.fullName];
                chatDialog.photo = dialogResult.dialog.photo;
                [weakSelf sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:chatDialog updateType:@"room_photo" content:dialogResult.dialog.photo];
                completion(YES);
            }
        }];
    }];
}

- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSArray *occupantsToJoinIDs = [self idsWithUsers:occupants];
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    extendedRequest[kQMEditDialogExtendedPushOccupantsParameter] = occupantsToJoinIDs;
    
    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialogResult *result) {
        
        if ([weakSelf checkResult:result]) {
            [weakSelf.chatDialogsService addDialogToHistory:result.dialog];
            
            NSString *messageTypeText = NSLocalizedString(@"QM_STR_ADD_USERS_TO_GROUP_CONVERSATION_TEXT", @"{Full name}");
            NSString *text = [QMChatUtils messageForText:messageTypeText participants:occupants];
            
            [weakSelf sendGroupChatDialogDidCreateNotificationToUsers:occupants text:text toChatDialog:chatDialog];
            [weakSelf sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:chatDialog updateType:@"occupants_ids" content:[QMChatUtils fullNamesStringWithoutSpaces:occupants]];
            
        }
        completion(result);
    }];
}

- (void)leaveWithUserId:(NSUInteger)userID fromChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSString *messageTypeText = NSLocalizedString(@"QM_STR_LEAVE_GROUP_CONVERSATION_TEXT", @"{Full name}");
    NSString *text = [NSString stringWithFormat:messageTypeText, self.currentUser.fullName];
    NSString *myID = [NSString stringWithFormat:@"%lu", (unsigned long)self.currentUser.ID];
    [self sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:chatDialog updateType:@"deleted_id" content:myID];
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    extendedRequest[kQMEditDialogExtendedPullOccupantsParameter] = [NSString stringWithFormat:@"%d", userID];
    
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialogResult *result) {
        if (result.success) {
            [chatDialog.chatRoom leaveRoom];
            completion(result);
        }
    }];
}

- (NSUInteger )occupantIDForPrivateChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(chatDialog.type == QBChatDialogTypePrivate, @"Chat dialog type != QBChatDialogTypePrivate");
    NSAssert(chatDialog.occupantIDs.count == 2, @"Array of user ids in chat. For private chat count = 2");
    
    NSInteger myID = self.currentUser.ID;
    
    for (NSNumber *ID in chatDialog.occupantIDs) {
        
        if (ID.integerValue != myID) {
            return ID.integerValue;
        }
    }
    
    NSAssert(nil, @"Need update this cace");
    return 0;
}

- (void)deleteChatDialog:(QBChatDialog *)dialog completion:(void(^)(BOOL success))completionHandler
{
    __weak typeof(self)weakSelf = self;
    [self.chatDialogsService deleteChatDialog:dialog completion:^(BOOL success) {
        
        [weakSelf.messagesService deleteMessageHistoryWithChatDialogID:dialog.ID];
        completionHandler(success);
    }];
}


#pragma mark - Notifications

- (void)sendGroupChatDialogDidCreateNotificationToUsers:(NSArray *)users text:(NSString *)text toChatDialog:(QBChatDialog *)chatDialog {
    
    for (QBUUser *recipient in users) {
        QBChatMessage *notification = [self notificationToRecipient:recipient text:text chatDialog:chatDialog];
        [notification setCustomParametersWithChatDialog:chatDialog];
        [self sendGroupChatDialogDidCreateNotification:notification toChatDialog:chatDialog persistent:NO completionBlock:^(QBChatMessage *msg) {}];
    }
}

- (void)sendGroupChatDialogDidCreateNotificationToAllParticipantsWithText:(NSString *)text occupants:(NSArray *)occupants chatDialog:(QBChatDialog *)chatDialog
{
    QBChatMessage *groupNotification = [self notificationToRecipient:nil text:text chatDialog:chatDialog];
    groupNotification.cParamDialogOccupantsIDs = occupants;
    
    // put message to queue and when room will be joined, fire:
    self.messagesService.enqueuedMessages[chatDialog.roomJID] = groupNotification;
}

- (void)sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:(NSString *)text toChatDialog:(QBChatDialog *)chatDialog updateType:(NSString *)updateType content:(NSString *)content
{
    QBChatMessage *groupNotification = [self notificationToRecipient:nil text:text chatDialog:chatDialog];
    if (updateType != nil && content != nil) {
        groupNotification.customParameters[updateType] = content;  // fast fix
    }
    [self sendGroupChatDialogDidUpdateNotification:groupNotification toChatDialog:chatDialog completionBlock:^(QBChatMessage *msg) {}];
}

- (QBChatMessage *)notificationToRecipient:(QBUUser *)recipient text:(NSString *)text chatDialog:(QBChatDialog *)chatDialog {
    
    QBChatMessage *msg = [QBChatMessage message];
    
    msg.recipientID = recipient.ID;
    msg.text = text;
    msg.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    msg.cParamDialogID = chatDialog.ID;
    
    return msg;
}


#pragma mark - Dialogs toos

- (NSArray *)dialogHistory {
    
    return [self.chatDialogsService dialogHistory];
}

- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID {
    
    return [self.chatDialogsService chatDialogWithID:dialogID];
}

- (NSArray *)allOccupantIDsFromDialogsHistory{
    
    NSArray *allDialogs = self.chatDialogsService.dialogHistory;
    NSMutableSet *ids = [NSMutableSet set];
    
    for (QBChatDialog *dialog in allDialogs) {
        [ids addObjectsFromArray:dialog.occupantIDs];
    }
    
    return ids.allObjects;
}

@end
