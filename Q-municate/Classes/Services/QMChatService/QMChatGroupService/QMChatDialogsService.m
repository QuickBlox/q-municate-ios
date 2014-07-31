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
@property (strong, nonatomic) NSMutableDictionary *chatRooms;

@end

@implementation QMChatDialogsService

- (void)start {
    
    self.dialogs = [NSMutableDictionary dictionary];
    self.chatRooms = [NSMutableDictionary dictionary];

    __weak __typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatRoomDidReceiveMessageWithTarget:self block:^(QBChatMessage *message, NSString *roomJID) {
        [weakSelf updateOrCreateDialogWithMessage:message];
    }];
    
    [[QMChatReceiver instance] chatDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        [weakSelf updateOrCreateDialogWithMessage:message];
    }];
    
    [[QMChatReceiver instance] chatRoomDidCreateWithTarget:self block:^(NSString *roomName) {
        NSLog(@"chatRoomDidCreateWithTarget");
    }];
}

- (void)destroy {
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    
    [self.dialogs removeAllObjects];
    [self.chatRooms removeAllObjects];
}

- (void)fetchAllDialogs:(QBDialogsPagedResultBlock)completion {
    
    [QBChat dialogsWithDelegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
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

- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID {
    return self.dialogs[dialogID];
}

- (void)addDialogToHistory:(QBChatDialog *)chatDialog {
    
    //If dialog type is equal group then need join room
    if (chatDialog.type == QBChatDialogTypeGroup) {
        
        NSString *roomJID = chatDialog.roomJID;
        NSAssert(roomJID, @"Need update this case");
        
        QBChatRoom *existRoom = self.chatRooms[roomJID];
        
        if (!existRoom) {
            QBChatRoom *chatRoom = [[QBChatRoom alloc] initWithRoomJID:roomJID];
            [chatRoom joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
            self.chatRooms[roomJID] = chatRoom;
        }
        
    } else if (chatDialog.type == QBChatDialogTypePrivate) {
        
    }
    
    self.dialogs[chatDialog.ID] = chatDialog;
}

- (NSArray *)dialogHistory {
    
    NSArray *dialogs = [self.dialogs allValues];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastMessageDate" ascending:YES];
    dialogs = [dialogs sortedArrayUsingDescriptors:@[sort]];
   
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

- (QBChatRoom *)chatRoomWithRoomJID:(NSString *)roomJID {
    return self.chatRooms[roomJID];
}

- (void)updateChatDialogWithChatMessage:(QBChatMessage *)chatMessage {
    
    QBChatDialog *dialog = self.dialogs[chatMessage.cParamRoomJID];
    if (dialog == nil) {
        NSAssert(!dialog, @"Dialog you are looking for not found.");
        return;
    }
    
    dialog.name = chatMessage.cParamDialogName;
    dialog.occupantIDs = [chatMessage.cParamDialogOccupantsIDs componentsSeparatedByString:@", "];
}

- (void)updateOrCreateDialogWithMessage:(QBChatMessage *)message {

    NSAssert(message.cParamDialogID, @"Need update this case");
    
    if (message.cParamNotificationType == QMMessageNotificationTypeCreateDialog) {
        
        QBChatDialog *chatDialog = [message chatDialogFromCustomParameters];
        [self addDialogToHistory:chatDialog];
    }
    else if (message.cParamNotificationType == QMMessageNotificationTypeUpdateDialog){
       // lol
    }  else {
        
        QBChatDialog *dialog = [self chatDialogWithID:message.cParamDialogID];
        dialog.lastMessageText = message.text;
        dialog.unreadMessagesCount++;
    }
}

@end
