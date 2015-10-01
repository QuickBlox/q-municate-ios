//
//  QMApi+Messages.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMSettingsManager.h"
#import "QMApi+Notifications.m"
#import "QMContentService.h"
#import "QMChatUtils.h"

@implementation QMApi (Chat)

/**
 *  Messages
 */

#pragma mark - Messages

- (void)loginChat:(QBChatResultBlock)block {
    [self.chatService logIn:^(NSError *error) {
        //
        if (error != nil) {
            block(YES);
        }
        else {
            block(NO);
        }
    }];
}

- (void)logoutFromChat {
    [self.chatService logoutChat];
    [self.settingsManager setLastActivityDate:[NSDate date]];
}

- (void)fetchMessageWithDialog:(QBChatDialog *)chatDialog complete:(void(^)(BOOL success))complete {
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService messagesWithChatDialogID:chatDialog.ID completion:^(QBResponse *response, NSArray *messages) {
        //
        if (!response.status) {
            [weakSelf handleErrorResponse:response];
        }
        complete(response.status);
    }];
}

- (void)fetchMessagesForActiveChatIfNeededWithCompletion:(void(^)(BOOL fetchWasNeeded))block
{
    if (self.settingsManager.dialogWithIDisActive) {
        [self.chatService messagesWithChatDialogID:self.settingsManager.dialogWithIDisActive completion:^(QBResponse *response, NSArray *messages) {
            //
            if (block) block(YES);
        }];
        return;
    }
    if (block) block(NO);
}

- (void)sendMessage:(QBChatMessage *)message toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion {
    
    [self.chatService sendMessage:message toDialog:dialog save:YES completion:^(NSError *error) {
        //
        completion(message);
    }];
}

- (void)sendText:(NSString *)text toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = text;
    [self sendMessage:message toDialog:dialog completion:completion];
}

- (void)sendAttachment:(QBCBlob *)attachment toDialog:(QBChatDialog *)dialog completion:(void(^)(QBChatMessage * message))completion {
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = @"Attachment";
    QBChatAttachment *attach = [[QBChatAttachment alloc] init];
    attach.url = attachment.publicUrl;
    attach.type = @"image";
    message.attachments = @[attach];
    
    [self sendMessage:message toDialog:dialog completion:completion];
}

- (NSArray *)messagesHistoryWithDialog:(QBChatDialog *)chatDialog {
    return [self.chatService.messagesMemoryStorage messagesWithDialogID:chatDialog.ID];
}

/**
 *  ChatDialog
 */

#pragma mark - ChatDialog

NSString const *kQMEditDialogExtendedNameParameter = @"name";
NSString const *kQMEditDialogExtendedPushOccupantsParameter = @"push[occupants_ids][]";
NSString const *kQMEditDialogExtendedPullOccupantsParameter = @"pull_all[occupants_ids][]";
static const NSUInteger kQMDialogsPageLimit = 10;

- (void)fetchAllDialogs:(void(^)(void))completion {
    
    [self.chatService allDialogsWithPageLimit:kQMDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
        //
    } completion:^(QBResponse *response) {
        //
        if (completion) completion();
    }];
}

- (void)fetchDialogsWithLastActivityFromDate:(NSDate *)date completion:(QBDialogsPagedResponseBlock)completion
{
    [self.chatService fetchDialogsWithLastActivityFromDate:date completion:completion];
}

- (void)fetchChatDialogWithID:(NSString *)dialogID completion:(void(^)(QBChatDialog *chatDialog))completion
{
    
    __weak typeof(self)weakSelf = self;
    
    [self.chatService fetchDialogWithID:dialogID completion:^(QBChatDialog *dialog) {
        //
        if (!dialog) {
            if (completion) completion(dialog);
            return;
        }
        [weakSelf.contactListService retrieveUsersWithIDs:dialog.occupantIDs forceDownload:NO completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            //
            if (completion) completion(dialog);
        }];
    }];
}


#pragma mark - Create Chat Dialogs


- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion
{
    [self.chatService createPrivateChatDialogWithOpponent:opponent completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        //
        completion(createdDialog);
    }];
}

- (void)createGroupChatDialogWithName:(NSString *)name occupants:(NSArray *)occupants completion:(void(^)(QBChatDialog *chatDialog))completion {
    
    __weak typeof(self)weakSelf = self;
    [self.chatService createGroupChatDialogWithName:name photo:nil occupants:occupants completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        
        // send notification from here:
        NSString *notificationText = NSLocalizedString(@"QM_STR_NOTIFICATION_MESSAGE", nil);
        // send to group:
        [weakSelf sendGroupChatDialogDidCreateNotificationToAllParticipantsWithText:notificationText occupants:createdDialog.occupantIDs chatDialog:createdDialog];

        [weakSelf sendGroupChatDialogDidCreateNotificationToUsers:createdDialog.occupantIDs text:notificationText toChatDialog:createdDialog];
//        [weakSelf sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:notificationText toChatDialog:createdDialog updateType:nil content:nil];

        completion(createdDialog);
    }];
}


#pragma mark - Edit dialog methods

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService changeDialogName:dialogName forChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.status) {
            NSString *notificationText = NSLocalizedString(@"QM_STR_UPDATE_GROUP_NAME_TEXT", nil);
            NSString *text = [NSString stringWithFormat:notificationText, self.currentUser.fullName, dialogName];
            
            [weakSelf sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:updatedDialog updateType:@"room_name" content:dialogName];
        }
        else {
            [weakSelf handleErrorResponse:response];
        }
        completion(response,updatedDialog);
    }];
}

- (void)changeAvatar:(UIImage *)avatar forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion
{
    __weak typeof(self)weakSelf = self;
    [self.contentService uploadPNGImage:avatar progress:^(float progress) {
        //
    } completion:^(QBResponse *response, QBCBlob *blob) {
        //
        // update chat dialog:
        if (!response.success) {
            return;
        }
        
        [weakSelf.chatService changeDialogAvatar:blob.publicUrl forChatDialog:chatDialog completion:^(QBResponse *updateResponse, QBChatDialog *updatedDialog) {
            //
            if (updateResponse.success) {
                // send notification:
                NSString *notificationText = NSLocalizedString(@"QM_STR_UPDATE_GROUP_AVATAR_TEXT", @"{Full name}");
                NSString *text = [NSString stringWithFormat:notificationText, self.currentUser.fullName];
                
                chatDialog.photo = updatedDialog.photo;
                [weakSelf sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:chatDialog updateType:@"room_photo" content:updatedDialog.photo];
                completion(updateResponse, updatedDialog);
            }

        }];
    }];
}

- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion {
    
    NSArray *occupantsToJoinIDs = [self idsWithUsers:occupants];
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService joinOccupantsWithIDs:occupantsToJoinIDs toChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.status) {
            NSString *messageTypeText = NSLocalizedString(@"QM_STR_ADD_USERS_TO_GROUP_CONVERSATION_TEXT", @"{Full name}");
            NSString *text = [QMChatUtils messageForText:messageTypeText participants:occupants];
            
            [weakSelf sendGroupChatDialogDidCreateNotificationToUsers:updatedDialog.occupantIDs text:text toChatDialog:chatDialog];
            [weakSelf sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:chatDialog updateType:@"occupants_ids" content:[QMChatUtils idsStringWithoutSpaces:occupants]];
        }
        else {
            [weakSelf handleErrorResponse:response];
        }
        completion(response,updatedDialog);
    }];
}

- (void)joinGroupDialogs {
    NSArray *allDialogs = [self dialogHistory];
    for (QBChatDialog* dialog in allDialogs) {
        if (dialog.type != QBChatDialogTypePrivate) {
            // Joining to group chat dialogs.
            [self.chatService joinToGroupDialog:dialog failed:^(NSError *error) {
                NSLog(@"Failed to join room with error: %@", error.localizedDescription);
            }];
        }
    }
}

- (void)leaveChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion {
    
    NSString *messageTypeText = NSLocalizedString(@"QM_STR_LEAVE_GROUP_CONVERSATION_TEXT", @"{Full name}");
    NSString *text = [NSString stringWithFormat:messageTypeText, self.currentUser.fullName];
    NSString *myID = [NSString stringWithFormat:@"%lu", (unsigned long)self.currentUser.ID];
    
    // remove current user from occupants
    NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
    for (NSNumber *identifier in chatDialog.occupantIDs) {
        if (![identifier isEqualToNumber:@(QMApi.instance.currentUser.ID)]) {
            [occupantsWithoutCurrentUser addObject:identifier];
        }
    }
    chatDialog.occupantIDs = [occupantsWithoutCurrentUser copy];
    
    [self sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:text toChatDialog:chatDialog updateType:@"deleted_id" content:myID];
    
    [chatDialog leave];
    [self.chatService deleteDialogWithID:chatDialog.ID completion:^(QBResponse *response) {
        //
        completion(response,nil);
    }];
}

- (NSUInteger )occupantIDForPrivateChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(chatDialog.type == QBChatDialogTypePrivate, @"Chat dialog type != QBChatDialogTypePrivate");
    
    NSInteger myID = self.currentUser.ID;
    
    for (NSNumber *ID in chatDialog.occupantIDs) {
        
        if (ID.integerValue != myID) {
            return ID.integerValue;
        }
    }
    
    NSAssert(nil, @"Need update this case");
    return 0;
}

- (void)deleteChatDialog:(QBChatDialog *)dialog completion:(void(^)(BOOL success))completionHandler
{
    [self.chatService deleteDialogWithID:dialog.ID completion:^(QBResponse *response) {
        //
        completionHandler(response.success);
    }];
}


#pragma mark - Notifications

- (void)sendGroupChatDialogDidCreateNotificationToUsers:(NSArray *)users text:(NSString *)text toChatDialog:(QBChatDialog *)chatDialog {
    
    [self.chatService notifyUsersWithIDs:users aboutAddingToDialog:chatDialog];
}

- (void)sendGroupChatDialogDidCreateNotificationToAllParticipantsWithText:(NSString *)text occupants:(NSArray *)occupants chatDialog:(QBChatDialog *)chatDialog
{
    
    [self.chatService notifyUsersWithIDs:occupants aboutAddingToDialog:chatDialog];
}

- (void)sendGroupChatDialogDidUpdateNotificationToAllParticipantsWithText:(NSString *)text toChatDialog:(QBChatDialog *)chatDialog updateType:(NSString *)updateType content:(NSString *)content
{
    NSMutableDictionary *customParams = [NSMutableDictionary new];
    if (updateType != nil && content != nil) {
#warning Fast Fix
        [customParams setObject:content forKey:updateType];
    }
    
    [self.chatService notifyAboutUpdateDialog:chatDialog occupantsCustomParameters:customParams notificationText:text completion:^(NSError *error) {
        //
    }];
}

#pragma mark - Dialogs toos

- (NSArray *)dialogHistory {
    return [self.chatService.dialogsMemoryStorage unsortedDialogs];
}

- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID {
    
    return [self.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
}

- (NSArray *)allOccupantIDsFromDialogsHistory{
    
    NSArray *allDialogs = [self.chatService.dialogsMemoryStorage unsortedDialogs];
    NSMutableSet *ids = [NSMutableSet set];
    
    for (QBChatDialog *dialog in allDialogs) {
        [ids addObjectsFromArray:dialog.occupantIDs];
    }
    
    return ids.allObjects;
}

@end
