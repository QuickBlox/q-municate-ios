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
        
        NSString *roomJID = chatDialog.roomJID;
        NSAssert(roomJID, @"Need update this case");
        
        QBChatRoom *room = chatDialog.chatRoom;
        [room joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
        self.rooms[chatDialog.roomJID] = room;
        
    } else if (chatDialog.type == QBChatDialogTypePrivate) {
        
    }
    
    self.dialogs[chatDialog.ID] = chatDialog;
}

- (NSArray *)dialogHistory {
    
    NSArray *dialogs = [self.dialogs allValues];
    return dialogs;
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
        NSAssert(!dialog, @"Dialog you are looking for not found.");
        return;
    }
    
    dialog.name = chatMessage.cParamDialogName;
    dialog.occupantIDs = [chatMessage.cParamDialogOccupantsIDs componentsSeparatedByString:@","];
}

- (void)updateOrCreateDialogWithMessage:(QBChatMessage *)message {
    
    NSAssert(message.cParamDialogID, @"Need update this case");
    
    if (message.cParamNotificationType == QMMessageNotificationTypeCreateDialog) {
        
        QBChatDialog *chatDialog = [message chatDialogFromCustomParameters];
        [self addDialogToHistory:chatDialog];
    }
    else if (message.cParamNotificationType == QMMessageNotificationTypeUpdateDialog) {
        
        [self updateChatDialogWithChatMessage:message];
    }
    else {
        
        QBChatDialog *dialog = [self chatDialogWithID:message.cParamDialogID];
        dialog.lastMessageText = message.text;
        dialog.lastMessageDate = [NSDate dateWithTimeIntervalSince1970:message.cParamDateSent.doubleValue];
        dialog.unreadMessagesCount++;
    }
}



#pragma mark - Chat Room

- (QBChatRoom *)chatRoomWithRoomJID:(NSString *)roomJID {
    
    QBChatRoom *room = self.rooms[roomJID];
    NSAssert(room, @"Need update this case");

    return room;
}

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
