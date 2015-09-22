//
//  QMChatDialogsService.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDialogsService.h"
#import "QMChatReceiver.h"


@interface QMChatDialogsService()

@property (strong, nonatomic) NSMutableDictionary *dialogs;

/**
 * Dictionary of completion blocks when joining chatRoom.
 */
@property (strong, nonatomic) NSMutableDictionary *joinRoomCompletionBlockList;

@end

@implementation QMChatDialogsService

- (void)start {
    [super start];
    
    self.dialogs = [NSMutableDictionary dictionary];
    self.joinRoomCompletionBlockList = [[NSMutableDictionary alloc] init];
    
    __weak typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatRoomDidEnterWithTarget:self block:^(QBChatRoom *room) {
        
        QBChatRoomResultBlock block = weakSelf.joinRoomCompletionBlockList[room.JID];
        if (block) {
            [weakSelf.joinRoomCompletionBlockList removeObjectForKey:room.JID];
            block(room, nil);
        }
    }];
    
//    [[QMChatReceiver instance] chatRoomDidNotEnterWithTarget:self block:^(NSString *roomName, NSError *error) {
//        //
//    }];
}

- (void)stop {
    [super stop];
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    [self.dialogs removeAllObjects];
    [self.joinRoomCompletionBlockList removeAllObjects];
}

- (void)fetchAllDialogs:(QBDialogsPagedResponseBlock)completion {
    
    [QBRequest dialogsWithSuccessBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs) {
        //
        completion(response,dialogObjects,dialogsUsersIDs,nil);
        [[QMChatReceiver instance] postDialogsHistoryUpdated];
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil,nil,nil);
    }];
}

- (void)fetchDialogsWithIDs:(NSArray *)dialogIDs completion:(QBDialogsPagedResponseBlock)completion
{
    NSString *IDs = [dialogIDs componentsJoinedByString:@","];
    NSAssert(IDs, @"IDs parsed not correctly from NSArray. Update case");
    
    __weak typeof(self)weakSelf = self;
    NSMutableDictionary *extendedRequest = @{@"_id[in]":IDs}.mutableCopy;
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:100];
    [QBRequest dialogsForPage:page extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *responsePage) {
        //
        [weakSelf addDialogs:dialogObjects];
        completion(response,dialogObjects,dialogsUsersIDs,responsePage);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil,nil,nil);
    }];
}

- (void)fetchDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))block
{
    __weak typeof(self)weakSelf = self;
    NSMutableDictionary *extendedRequest = @{@"_id[in]":dialogID}.mutableCopy;
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:100];
    [QBRequest dialogsForPage:page extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *responsePage) {
        //
        if (dialogObjects.count > 0) {
            [weakSelf addDialogs:dialogObjects];
        }
        block(dialogObjects.firstObject);
    } errorBlock:^(QBResponse *response) {
        //
        block(nil);
    }];
}

- (void)fetchDialogsWithLastActivityFromDate:(NSDate *)date completion:(QBDialogsPagedResponseBlock)completionBlock
{
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    NSMutableDictionary *extendedRequest = @{@"last_message_date_sent[gt]":@(timeInterval)}.mutableCopy;
    
    __weak typeof(self)weakSelf = self;
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:100];
    [QBRequest dialogsForPage:page extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *responsePage) {
        //
        if (response.success) {
            [weakSelf updateDialogsWithRequested:dialogObjects];
        }
        if (completionBlock) completionBlock(response,dialogObjects,dialogsUsersIDs,responsePage);
    } errorBlock:^(QBResponse *response) {
        //
        completionBlock(response,nil,nil,nil);
    }];
}

- (void)createChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion {
    
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        //
        completion(response,createdDialog);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil);
    }];
}

- (void)updateChatDialog:(QBChatDialog *)dialog completion:(QBChatDialogResponseBlock)completion {
    
    [QBRequest updateDialog:dialog successBlock:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        completion(response,updatedDialog);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil);
    }];
}

- (void)addDialogs:(NSArray *)dialogs {
    
    for (QBChatDialog *chatDialog in dialogs) {
        if (chatDialog.type != QBChatDialogTypePublicGroup) {
            [self addDialogToHistory:chatDialog];
        }
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

        if (!chatDialog.chatRoom.isJoined && [QBChat instance].isLoggedIn) {
            
            QBChatRoom *room = chatDialog.chatRoom;
            [room joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
        }
    }
    self.dialogs[chatDialog.ID] = chatDialog;
}

- (void)updateDialogsWithRequested:(NSArray *)requestedDialogs
{
    if (requestedDialogs.count == 0) {
        return;
    }
    for (QBChatDialog *dialog in requestedDialogs) {
        QBChatDialog *existedDialog = self.dialogs[dialog.ID];
        if (!existedDialog) {
            self.dialogs[dialog.ID] = dialog;
            continue;
        }
        if (existedDialog.type == QBChatDialogTypeGroup) {
            existedDialog.occupantIDs = dialog.occupantIDs;
            existedDialog.name = dialog.name;
            existedDialog.photo = dialog.photo;
        }
        existedDialog.lastMessageDate = dialog.lastMessageDate;
        existedDialog.lastMessageText = dialog.lastMessageText;
        existedDialog.lastMessageUserID = dialog.lastMessageUserID;
        existedDialog.unreadMessagesCount = dialog.unreadMessagesCount;
    }
}

- (NSArray *)dialogHistory {
    
    NSArray *dialogs = [self.dialogs allValues];
    return dialogs;
}

- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion
{
    QBChatDialog __block *dialog = [self privateDialogWithOpponentID:opponent.ID];
    
    if (!dialog) {
        
        NSArray *occupantsIDs = @[@(opponent.ID)];
        
        QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil type:QBChatDialogTypePrivate];
        chatDialog.occupantIDs = occupantsIDs;
        
        __weak typeof(self) weakSelf = self;
        [self createChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *createdDialog) {
            if (response.success) {
                dialog = createdDialog;
                [weakSelf addDialogToHistory:dialog];
            }
            completion(dialog);
        }];
        
    } else {
        completion(dialog);
    }
}

- (void)createPrivateDialogIfNeededWithNotification:(QBChatMessage *)notification completion:(void(^)(QBChatDialog *chatDialog))completion
{
    QBChatDialog *dialog = [self privateDialogWithOpponentID:notification.senderID];
    
    if (!dialog) {
        NSAssert(notification, @"Notification for receiving contact request is empty. Update this case");
        
        dialog = [[QBChatDialog alloc] initWithDialogID:notification.cParamDialogID type:QBChatDialogTypePrivate];
        dialog.occupantIDs = @[@(notification.senderID)];
        [self addDialogToHistory:dialog];
        
        __weak typeof(self) weakSelf = self;
        [self createChatDialog:dialog completion:^(QBResponse *response, QBChatDialog *createdDialog) {
            //
            if( createdDialog != nil ) {
                [weakSelf addDialogToHistory:createdDialog];
            }
            else{
                [weakSelf addDialogToHistory:dialog];
            }
            completion(dialog);
        }];
        
    } else {
        completion(dialog);
    }
}

- (void)createGroupChatDialog:(QBChatDialog *)chatDialog completion:(void(^)(QBChatDialog *chatDialog))block
{
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Creating group dialog with invalid group type(QBChatDialogTypeGroup needed). Update case.");
    
    __weak typeof(self)weakSelf = self;
    [self createChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        //
        if (response.success) {
            QBChatDialog *resultDialog = createdDialog;
            
            QBChatRoomResultBlock joinRoomBlock = ^(QBChatRoom *chatRoom, NSError *error) {
                if (block) block(resultDialog);
            };
            
            weakSelf.joinRoomCompletionBlockList[resultDialog.roomJID] = joinRoomBlock;
            [resultDialog.chatRoom joinRoomWithHistoryAttribute:@{@"maxstanzas":@"0"}];
        }
    }];
    
}

- (QBChatDialog *)privateDialogWithOpponentID:(NSUInteger)opponentID {
    
    NSArray *allDialogs = [self dialogHistory];
    
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"SELF.type == %d AND SUBQUERY(SELF.occupantIDs, $userID, $userID == %@).@count > 0", QBChatDialogTypePrivate, @(opponentID)];
    
    NSArray *result = [allDialogs filteredArrayUsingPredicate:predicate];
    QBChatDialog *dialog = result.firstObject;
    
    return dialog;
}

- (void)updateChatDialog:(QBChatDialog *)dialog withChatMessage:(QBChatMessage *)chatMessage {
    
    if (dialog == nil) {
        NSAssert(dialog, @"Dialog you are looking for not found.");
        return;
    }
    if (chatMessage.cParamDialogRoomPhoto) {
        dialog.photo = chatMessage.cParamDialogRoomPhoto;
        
    } else if (chatMessage.cParamDialogRoomName) {
        dialog.name = chatMessage.cParamDialogRoomName;
        
    } else if (chatMessage.cParamDialogOccupantsIDs.count > 0) {
        NSArray *occupantsIDs = [dialog.occupantIDs arrayByAddingObjectsFromArray:chatMessage.cParamDialogOccupantsIDs];
        dialog.occupantIDs = occupantsIDs;
        
    } else if (chatMessage.cParamDialogDeletedID) {
        
        dialog.occupantIDs = [self occupantsArray:dialog.occupantIDs withoutDeletedOccupantID:chatMessage.cParamDialogDeletedID];
    }
}

- (void)updateOrCreateDialogWithMessage:(QBChatMessage *)message isMine:(BOOL)isMine {
    
    NSAssert(message.cParamDialogID, @"Notification without dialog id. Need update this case");
    
    if (message.cParamNotificationType == QMMessageNotificationTypeSendContactRequest) {
        [self createPrivateDialogIfNeededWithNotification:message completion:^(QBChatDialog *chatDialog) {
            if (!isMine) {
                chatDialog.unreadMessagesCount++;
            }
            [[QMChatReceiver instance] postDialogsHistoryUpdated];
        }];
        return;
    }
    
    QBChatDialog *dialog = [self chatDialogWithID:message.cParamDialogID];
    
     if (!isMine) {
        if (message.cParamNotificationType == QMMessageNotificationTypeCreateGroupDialog) {
            if (dialog == nil) {
                dialog = [message chatDialogFromCustomParameters];
                [self addDialogToHistory:dialog];
            } else {
                return;  // to avoid update 2 times last message + badge information
            }
        }
        else if (message.cParamNotificationType == QMMessageNotificationTypeUpdateGroupDialog) {
            [self updateChatDialog:dialog withChatMessage:message];
        }
    }
    // to all messages:
    [dialog updateLastMessageInfoWithMessage:message isMine:isMine];
}

- (void)deleteChatDialog:(QBChatDialog *)dialog completion:(void(^)(BOOL success))completionHanlder
{
    __weak typeof(self)weakSelf = self;
    [QBRequest deleteDialogWithID:dialog.ID successBlock:^(QBResponse *response) {
        //
        [weakSelf deleteLocalDialog:dialog];
        completionHanlder(response.success);
    } errorBlock:^(QBResponse *response) {
        //
        completionHanlder(response.success);
    }];
}

- (void)deleteLocalDialog:(QBChatDialog *)dialog
{
    [self.dialogs removeObjectForKey:dialog.ID];
}

- (NSArray *)occupantsArray:(NSArray *)occupantsIDs withoutDeletedOccupantID:(NSNumber *)deletedOccupantID
{
     NSMutableArray *array = [[NSMutableArray alloc] initWithArray:occupantsIDs];
    NSNumber *delNumb = @(deletedOccupantID.integerValue);
    for (NSNumber *ID in occupantsIDs) {
        if ([ID isEqualToNumber:delNumb]) {
            [array removeObject:ID];
            return array;
        }
    }
    return occupantsIDs;
}


#pragma mark - Chat Room

- (void)leaveFromRooms {
    
    NSArray *dialogs = [self.dialogs allValues];
    for (QBChatDialog *dialog in dialogs) {
       
        if (dialog.chatRoom.isJoined) {
            [dialog.chatRoom leaveRoom];
        }
    }
}

- (void)joinRooms {
    
    NSArray *allDialogs = [self dialogHistory];
    for (QBChatDialog *dialog in allDialogs) {
        
        if (dialog.roomJID && !dialog.chatRoom.isJoined) {
            [dialog.chatRoom joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
        }
    }
}

@end
