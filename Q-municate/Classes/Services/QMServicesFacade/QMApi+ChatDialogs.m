//
//  QMApi+ChatDialogs.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMChatDialogsService.h"
#import "QMMessagesService.h"

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

- (void)createChatDialog:(QBChatDialog *)chatDialog occupants:(NSArray *)occupants completion:(QBChatDialogResultBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService createChatDialog:chatDialog completion:^(QBChatDialogResult *result) {
        
        if ([weakSelf checkResult:result]) {
            [weakSelf.chatDialogsService addDialogToHistory:result.dialog];
            [weakSelf sendNotificationWithType:QMMessageNotificationTypeCreateDialog toRecipients:occupants chatDialog:result.dialog];
        }
        completion(result);
    }];
}

- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion {
    
    QBChatDialog *dialog = [self.chatDialogsService privateDialogWithOpponentID:opponent.ID];
    
    if (!dialog) {
        
        NSArray *occupants = @[opponent];
        NSArray *occupantsIDS = [self idsWithUsers:occupants];
        
        QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
        chatDialog.type = QBChatDialogTypePrivate;
        chatDialog.occupantIDs = occupantsIDS;
        
        [self createChatDialog:chatDialog occupants:occupants completion:^(QBChatDialogResult *result) {
            completion(result.dialog);
        }];
        
    } else {
        completion(dialog);
    }
}

- (void)createGroupChatDialogWithName:(NSString *)name occupants:(NSArray *)occupants completion:(QBChatDialogResultBlock)completion {
    
    NSArray *occupantIDs = [self idsWithUsers:occupants];
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
    chatDialog.name = name;
    chatDialog.occupantIDs = occupantIDs;
    chatDialog.type = QBChatDialogTypeGroup;
    
    [self createChatDialog:chatDialog occupants:occupants completion:completion];
}

- (void)updateChatDialog:(QBChatDialog *)chatDialog
{
    [[QMApi instance].chatDialogsService updateChatDialog:chatDialog];
}

- (QBChatMessage *)notification:(QMMessageNotificationType)type recipient:(QBUUser *)recipient text:(NSString *)text chatDialog:(QBChatDialog *)chatDialog {
    
    QBChatMessage *msg = [QBChatMessage message];
    
    msg.recipientID = recipient.ID;
    msg.text = text;
    msg.cParamNotificationType = type;
    msg.cParamDateSent = @((NSInteger)CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    [msg setCustomParametersWithChatDialog:chatDialog];
    
    return msg;
}

- (void)sendNotificationWithType:(QMMessageNotificationType)type toRecipients:(NSArray *)recipients chatDialog:(QBChatDialog *)chatDialog {
    
    NSString *text = [NSString stringWithFormat:@"%@ created a group conversation", self.currentUser.fullName];
    
    for (QBUUser *recipient in recipients) {
        QBChatMessage *notification = [self notification:type recipient:recipient text:text chatDialog:chatDialog];
        [self.messagesService sendMessage:notification withDialogID:chatDialog.ID saveToHistory:NO];
    }
}

#pragma mark - Edit dialog methods

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    extendedRequest[kQMEditDialogExtendedNameParameter] = dialogName;
    NSArray *opponentsIDs = [self usersWithIDs:chatDialog.occupantIDs];

    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialogResult *result) {

        if ([weakSelf checkResult:result]) {
            chatDialog.name = dialogName;
            [weakSelf sendNotificationWithType:QMMessageNotificationTypeUpdateDialog toRecipients:opponentsIDs chatDialog:chatDialog];
        }
        
        completion(result);
    }];
}

- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSArray *occupantsToJoinIDs = [self idsWithUsers:occupants];
    NSArray *occupantsToNotify = [self usersWithIDs:chatDialog.occupantIDs];
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    extendedRequest[kQMEditDialogExtendedPushOccupantsParameter] = occupantsToJoinIDs;
    
    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialogResult *result) {
        
        if ([weakSelf checkResult:result]) {
            [weakSelf updateChatDialog:result.dialog];
            [weakSelf sendNotificationWithType:QMMessageNotificationTypeCreateDialog toRecipients:occupants chatDialog:result.dialog];
            [weakSelf sendNotificationWithType:QMMessageNotificationTypeUpdateDialog toRecipients:occupantsToNotify chatDialog:result.dialog];
        }
        completion(result);
    }];
}

- (void)leaveWithUserId:(NSUInteger)userID fromChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    extendedRequest[kQMEditDialogExtendedPullOccupantsParameter] = [NSString stringWithFormat:@"%d", userID];
    
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:completion];
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

#pragma mark - Dialogs toos

- (NSArray *)dialogHistory {
    return [self.chatDialogsService dialogHistory];
}

- (QBChatRoom *)chatRoomWithRoomJID:(NSString *)roomJID {
    
    return [self.chatDialogsService chatRoomWithRoomJID:roomJID];
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
