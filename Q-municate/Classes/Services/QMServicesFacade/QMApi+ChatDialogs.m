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
        [weakSelf sendNotificationWithType:QMMessageNotificationTypeCreateGroupDialog toRecipients:occupants chatDialog:result.dialog];
        [weakSelf.chatDialogsService addDialogToHistory:result.dialog];
        completion(result);
    }];
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
    
    NSString *messageText = NSLocalizedString(@"QM_STR_ADD_USERS_TO_GROUP_CONVERSATION_TEXT", @"{Full name}");
    NSString *addedUsersNames = [QMChatUtils fullNamesString:recipients];
    NSString *notifMessage = [NSString stringWithFormat:messageText, self.currentUser.fullName, addedUsersNames];
    
    
    for (QBUUser *recipient in recipients) {
        QBChatMessage *notification = [self notification:type
                                               recipient:recipient
                                                    text:notifMessage
                                              chatDialog:chatDialog];
        
        [self.messagesService sendMessage:notification withDialogID:chatDialog.ID saveToHistory:NO completion:^(NSError *error){}];
    }
}

#pragma mark - Edit dialog methods

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc] init];
    extendedRequest[kQMEditDialogExtendedNameParameter] = dialogName;
    NSArray *opponents = [self usersWithIDs:chatDialog.occupantIDs];
    NSArray *opponentsWithoutMe = [self occupantsWithoutMe:opponents];

    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialogResult *result) {

        if ([weakSelf checkResult:result]) {
            chatDialog.name = dialogName;
            [weakSelf sendNotificationWithType:QMMessageNotificationTypeUpdateGroupDialog toRecipients:opponentsWithoutMe chatDialog:chatDialog];
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
            
            [weakSelf.chatDialogsService addDialogToHistory:result.dialog];
            
            [weakSelf sendNotificationWithType:QMMessageNotificationTypeCreateGroupDialog toRecipients:occupants chatDialog:result.dialog];
            
            [weakSelf sendNotificationWithType:QMMessageNotificationTypeUpdateGroupDialog toRecipients:occupantsToNotify chatDialog:result.dialog];
            
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

- (void)deleteChatDialog:(QBChatDialog *)dialog completion:(void(^)(BOOL success))completionHandler
{
    __weak typeof(self)weakSelf = self;
    [self.chatDialogsService deleteChatDialog:dialog completion:^(BOOL success) {
        
        [weakSelf.messagesService deleteMessageHistoryWithChatDialogID:dialog.ID];
        completionHandler(success);
    }];
    
//    [self.chatDialogsService deleteLocalDialog:dialog];
//    completionHandler(YES);
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

- (NSArray *)occupantsWithoutMe:(NSArray *)opponents
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    for (QBUUser *opponent in opponents) {
        if (![opponent isEqual:self.currentUser]) {
            [newArray addObject:opponent];
        }
    }
    return [newArray copy];
}

@end
