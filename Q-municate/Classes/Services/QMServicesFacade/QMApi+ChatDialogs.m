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

NSString const *kQMDialogCustomParameterRoomJID = @"xmpp_room_jid";
NSString const *kQMDialogCustomParameterDialogName = @"name";
NSString const *kQMDialogCustomParameterDialogID = @"dialog_id";
NSString const *kQMDialogCustomParameterDialogType = @"type";
NSString const *kQMDialogCustomParameterDialogOccupantsIDs = @"occupants_ids";
NSString const *kQMDialogCustomParameterDialogDateSent = @"date_sent";
NSString const *kQMDialogCustomParameterNotificationType = @"notification_type";

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

- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent completion:(QBChatDialogResultBlock)completion {

    NSString *opponentID = [NSString stringWithFormat:@"%d", opponent.ID];
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
    chatDialog.type = QBChatDialogTypePrivate;
    chatDialog.occupantIDs =  @[opponentID];
    
	[self.chatDialogsService createChatDialog:chatDialog completion:completion];
}

- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion {
    
    QBChatDialog *dialog = [self.chatDialogsService privateDialogWithOpponentID:opponent.ID];
    if (!dialog) {
        __weak __typeof(self)weakSelf = self;
        [self createPrivateChatDialogWithOpponent:opponent completion:^(QBChatDialogResult *result) {
            [weakSelf.chatDialogsService addDialogToHistory:result.dialog];
            completion(result.dialog);
        }];
    } else {
        completion(dialog);
    }
}

- (void)createGroupChatDialogWithName:(NSString *)name ocupants:(NSArray *)ocupants completion:(QBChatDialogResultBlock)completion {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:ocupants.count];
    
    for (QBUUser *user in ocupants) {
        [array addObject:[NSString stringWithFormat:@"%d", user.ID]];
    }
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
    chatDialog.name = name;
    chatDialog.occupantIDs = array;
    chatDialog.type = QBChatDialogTypeGroup;

    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService createChatDialog:chatDialog completion:^(QBChatDialogResult *result) {
        [weakSelf.chatDialogsService addDialogToHistory:result.dialog];
        [weakSelf sendNotificationWithType:1 toRecipients:ocupants chatDialog:result.dialog];
        completion(result);
    }];
}

- (QBChatMessage *)notification:(NSUInteger)type recipient:(QBUUser *)recipient text:(NSString *)text chatDialog:(QBChatDialog *)chatDialog {
    
    QBChatMessage *msg = [QBChatMessage message];
    
    msg.recipientID = recipient.ID;
    msg.text = text;
    
    NSMutableDictionary *customParams = [NSMutableDictionary new];
    customParams[kQMDialogCustomParameterRoomJID] = chatDialog.roomJID;
    customParams[kQMDialogCustomParameterDialogName] = chatDialog.name;
    customParams[kQMDialogCustomParameterDialogID] = chatDialog.ID;
    customParams[kQMDialogCustomParameterDialogType] = @(chatDialog.type);
    customParams[kQMDialogCustomParameterDialogOccupantsIDs] = chatDialog.occupantIDs;
    customParams[kQMDialogCustomParameterDialogDateSent] = @(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970);
    customParams[kQMDialogCustomParameterNotificationType] = [NSString stringWithFormat:@"%d", type];
    
    msg.customParameters = customParams;
    
    return msg;
}

- (void)sendNotificationWithType:(NSUInteger)type toRecipients:(NSArray *)recipients chatDialog:(QBChatDialog *)chatDialog {
    
    NSString *text = [NSString stringWithFormat:@"%@ created a group conversation", self.currentUser.fullName];
    
    for (QBUUser *recipient in recipients) {
        QBChatMessage *notification = [self notification:type recipient:recipient text:text chatDialog:chatDialog];
        [self.messagesService sendMessage:notification withDialogID:chatDialog.ID saveToHistory:NO];
    }
}

#pragma mark - Edit dialog methods

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[kQMEditDialogExtendedNameParameter] = dialogName;
    
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:completion];
}

- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {

    NSArray *opponentsIDs = [self idsWithUsers:occupants];
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[kQMEditDialogExtendedPushOccupantsParameter] = opponentsIDs;

    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialogResult *result) {
        if (result.success) {
            [weakSelf sendNotificationWithType:2 toRecipients:opponentsIDs chatDialog:chatDialog];
        }
        completion(result);
    }];
}

- (void)leaveWithUserId:(NSUInteger)userID fromChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[kQMEditDialogExtendedPullOccupantsParameter] = [NSString stringWithFormat:@"%d", userID];
    
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:completion];
}

- (NSUInteger )occupantIDForPrivateChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(chatDialog.type == QBChatDialogTypePrivate, @"Chat dialog type != QBChatDialogTypePrivate");
    NSAssert(chatDialog.occupantIDs.count == 2, @"Array of user ids in chat. For private chat count = 2");
    
    NSNumber *myID = @(self.currentUser.ID);
    for (NSNumber *ID in chatDialog.occupantIDs) {
        
        if (ID != myID) {
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
    
    NSArray *allDialogs = self.dialogHistory;
    NSMutableSet *ids = [NSMutableSet set];
    
    for (QBChatDialog *dialog in allDialogs) {
        [ids addObjectsFromArray:dialog.occupantIDs];
    }
    
    return ids.allObjects;
}

@end
