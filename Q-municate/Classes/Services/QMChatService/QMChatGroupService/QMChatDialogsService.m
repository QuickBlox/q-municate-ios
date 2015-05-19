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
    
    __weak typeof(self)weakSelf = self;
    QBDialogsPagedResultBlock resultBlock = ^(QBDialogsPagedResult *result) {
        [weakSelf addDialogs:result.dialogs];
        completion(result);
    };
    NSMutableDictionary *extendedRequest = @{@"_id[in]":IDs}.mutableCopy;
    [QBChat dialogsWithExtendedRequest:extendedRequest delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:resultBlock]];
}

- (void)fetchDialogWithID:(NSString *)dialogID completion:(void (^)(QBChatDialog *dialog))block
{
    __weak typeof(self)weakSelf = self;
    QBDialogsPagedResultBlock resultBlock = ^(QBDialogsPagedResult *result) {
        if (result.dialogs.count > 0) {
            [weakSelf addDialogs:result.dialogs];
        }
        block(result.dialogs.firstObject);
    };
    NSMutableDictionary *extendedRequest = @{@"_id[in]":dialogID}.mutableCopy;
    [QBChat dialogsWithExtendedRequest:extendedRequest delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:resultBlock]];
}

- (void)fetchDialogsWithLastActivityFromDate:(NSDate *)date completion:(QBDialogsPagedResultBlock)completionBlock
{
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    NSMutableDictionary *extendedRequest = @{@"last_message_date_sent[gt]":@(timeInterval)}.mutableCopy;
    
    __weak typeof(self)weakSelf = self;
    QBDialogsPagedResultBlock resultBlock = ^(QBDialogsPagedResult *result) {
        if (result.success) {
            [weakSelf updateDialogsWithRequested:result.dialogs];
        }
        if (completionBlock) completionBlock(result);
    };
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
        
        QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
        chatDialog.type = QBChatDialogTypePrivate;
        chatDialog.occupantIDs = occupantsIDs;
        
        __weak typeof(self) weakSelf = self;
        [self createChatDialog:chatDialog completion:^(QBChatDialogResult *result) {
            if (result.success) {
                dialog = result.dialog;
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
        
        dialog = [[QBChatDialog alloc] init];
        dialog.ID = notification.cParamDialogID;
        dialog.type = QBChatDialogTypePrivate;
        dialog.occupantIDs = @[@(notification.senderID)];
        [self addDialogToHistory:dialog];
        
        __weak typeof(self) weakSelf = self;
        [self createChatDialog:dialog completion:^(QBChatDialogResult *result) {
            //
			if( result.dialog != nil ) {
				[weakSelf addDialogToHistory:result.dialog];
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
    [self createChatDialog:chatDialog completion:^(QBChatDialogResult *result) {
        if (result.success) {
            QBChatDialog *resultDialog = result.dialog;
            
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
