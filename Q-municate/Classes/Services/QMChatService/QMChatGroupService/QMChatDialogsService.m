//
//  QMChatDialogsService.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDialogsService.h"
#import "QBEchoObject.h"
#import "QMChatReceiver.h"
//#import "NSString+occupantsIDsFromMessage.h"

@interface QMChatDialogsService()

@property (strong, nonatomic) NSMutableDictionary *dialogs;
@property (strong, nonatomic) NSMutableDictionary *rooms;

@end

@implementation QMChatDialogsService

- (void)start {
    [super start];
    
    self.dialogs = [NSMutableDictionary dictionary];
    self.rooms = [NSMutableDictionary dictionary];
    
    __weak __typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatRoomDidReceiveMessageWithTarget:self block:^(QBChatMessage *message, NSString *roomJID) {
        [weakSelf updateOrCreateDialogWithMessage:message];
    }];
    
    [[QMChatReceiver instance] chatDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        [weakSelf updateOrCreateDialogWithMessage:message];
    }];
}

- (void)stop {
    [super stop];
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    
    [self.rooms removeAllObjects];
    [self.dialogs removeAllObjects];
}

- (void)fetchAllDialogs:(QBDialogsPagedResultBlock)completion {
    
    QBDialogsPagedResultBlock resultBlock = ^(QBDialogsPagedResult *result) {
        completion(result);
        [[QMChatReceiver instance] postDialogsHistoryUpdated];
    };
    
    [QBChat dialogsWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:resultBlock]];
}

- (void)fetchDialogsWithIDs:(NSArray *)dialogIDs completion:(QBDialogsPagedResultBlock)completion
{
    NSString *IDs = [dialogIDs componentsJoinedByString:@","];
    NSAssert(IDs, @"IDs parsed not correctly from NSArray. Update case");
    
    QBDialogsPagedResultBlock resultBlock = ^(QBDialogsPagedResult *result) {
        
    };
    NSMutableDictionary *extendedRequest = @{@"_id[in]":IDs}.mutableCopy;
    [QBChat dialogsWithExtendedRequest:extendedRequest delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:resultBlock]];
}

- (void)createChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
	[QBChat createDialog:chatDialog delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)updateChatDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest completion:(QBChatDialogResultBlock)completion {
    
    [QBChat updateDialogWithID:dialogID
               extendedRequest:extendedRequest
                      delegate:[QBEchoObject instance]
                       context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)addDialogs:(NSArray *)dialogs {
    
    for (QBChatDialog *chatDialog in dialogs) {
        [self addDialogToHistory:chatDialog];
    }
}

- (QBChatDialog *)chatDialogWithRoomJID:(NSString *)roomJID {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.roomJID == %@", roomJID];
    NSArray *allDialogs = [self dialogHistory];
    
    QBChatDialog *dialog = [allDialogs filteredArrayUsingPredicate:predicate].firstObject;
    return dialog;
}

//- (void)updateChatDialog:(QBChatDialog *)chatDialog
//{
//    self.dialogs[chatDialog.ID] = chatDialog;
//}

- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID {
    return self.dialogs[dialogID];
}

- (void)addDialogToHistory:(QBChatDialog *)chatDialog {
    
    //If dialog type is equal group then need join room
    if (chatDialog.type == QBChatDialogTypeGroup) {
        
        if (!chatDialog.chatRoom.isJoined) {
            
            QBChatRoom *room = chatDialog.chatRoom;
            [room joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
        }
        
    } else if (chatDialog.type == QBChatDialogTypePrivate) {
        
    }
    
    self.dialogs[chatDialog.ID] = chatDialog;
}

- (NSArray *)dialogHistory {
    
    NSArray *dialogs = [self.dialogs allValues];
    return dialogs;
}

- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion
{
    [self createPrivateDialogIfNeededWithOpponentID:opponent.ID completion:completion];
}

- (void)createPrivateDialogIfNeededWithNotification:(QBChatMessage *)notification completion:(void(^)(QBChatDialog *chatDialog))completion
{
    [self createPrivateDialogIfNeededWithOpponentID:notification.senderID completion:completion];
}

- (void)createPrivateDialogIfNeededWithOpponentID:(NSUInteger)opponentID completion:(void(^)(QBChatDialog *chatDialog))completion
{
    QBChatDialog __block *dialog = [self privateDialogWithOpponentID:opponentID];
    
    if (!dialog) {
        
        NSArray *occupantsIDs = @[@(opponentID)];
        
        QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
        chatDialog.type = QBChatDialogTypePrivate;
        chatDialog.occupantIDs = occupantsIDs;
        
        __weak typeof(self) weakSelf = self;
        [self createChatDialog:chatDialog completion:^(QBChatDialogResult *result) {
            dialog = result.dialog;
            [weakSelf addDialogToHistory:dialog];
            completion(dialog);
        }];
        
    } else {
        completion(dialog);
    }
}

- (QBChatDialog *)privateDialogWithOpponentID:(NSUInteger)opponentID {
    
    NSArray *allDialogs = [self dialogHistory];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"SELF.type == %d AND SUBQUERY(SELF.occupantIDs, $userID, $userID == %@).@count > 0", QBChatDialogTypePrivate, @(opponentID)];
    
    NSArray *result = [allDialogs filteredArrayUsingPredicate:predicate];
    QBChatDialog *dialog = result.firstObject;
    
    return dialog;
}


- (void)updateChatDialogWithChatMessage:(QBChatMessage *)chatMessage {
    
    QBChatDialog *dialog = self.dialogs[chatMessage.cParamDialogID];
    if (dialog == nil) {
        NSAssert(dialog, @"Dialog you are looking for not found.");
        return;
    }
    
    dialog.name = chatMessage.cParamDialogName;
    dialog.occupantIDs = chatMessage.cParamDialogOccupantsIDs;
}

- (void)updateOrCreateDialogWithMessage:(QBChatMessage *)message {
    
    NSAssert(message.cParamDialogID, @"Notification without dialog id. Need update this case");
    
    if (message.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
        [self createPrivateDialogIfNeededWithNotification:message completion:^(QBChatDialog *chatDialog) {
            if (chatDialog.unreadMessagesCount == 0) {
                chatDialog.unreadMessagesCount++;
            }
            [[QMChatReceiver instance] postDialogsHistoryUpdated];
        }];
    }
    else if (message.cParamNotificationType == QMMessageNotificationTypeCreateGroupDialog) {
        QBChatDialog *chatDialog = [message chatDialogFromCustomParameters];
        [self addDialogToHistory:chatDialog];
    }
    else if (message.cParamNotificationType == QMMessageNotificationTypeUpdateGroupDialog) {
        [self updateChatDialogWithChatMessage:message];
    }
    else {
        QBChatDialog *dialog = [self chatDialogWithID:message.cParamDialogID];
        [dialog updateLastMessageInfoWithMessage:message];
    }

}

- (void)deleteChatDialog:(QBChatDialog *)dialog completion:(void(^)(BOOL success))completionHanlder
{
    __weak typeof(self)weakSelf = self;
    QBChatDialogResultBlock resultBlock = ^(QBChatDialogResult *result){
        if (result.success) {
            [weakSelf deleteLocalDialog:dialog];
        }
        completionHanlder(result.success);
    };
    [QBChat deleteDialogWithID:dialog.ID delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:resultBlock]];
}

- (void)deleteLocalDialog:(QBChatDialog *)dialog
{
    [self.dialogs removeObjectForKey:dialog.ID];
}


#pragma mark - Chat Room

- (void)leaveFromRooms {
    
    NSArray *allRooms = [self.rooms allValues];
    for (QBChatRoom *room in allRooms) {
       
        if (room.isJoined) {
            [room leaveRoom];
            [self.rooms removeObjectForKey:room.JID];
        }
    }
}

- (void)joinRooms {
    
    NSArray *allDialogs = [self dialogHistory];
    for (QBChatDialog *dialog in allDialogs) {
        
        if (dialog.roomJID) {
            
            QBChatRoom *room = dialog.chatRoom;
            [room joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];

            self.rooms[dialog.roomJID] = room;
        }
    }
}

@end
