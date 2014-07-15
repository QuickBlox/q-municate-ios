//
//  QMApi+ChatDialogs.m
//  Qmunicate
//
//  Created by Andrey on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMChatDialogsService.h"
#import "QMMessagesService.h"

@interface QMApi()

@property (strong, nonatomic) NSMutableArray *dialogs;
@property (strong, nonatomic) NSMutableDictionary *chatRooms;
@property (strong, nonatomic) NSMutableDictionary *privateDialogs;

@end

@implementation QMApi (ChatDialogs)

- (void)fetchAllDialogs:(void(^)(void))completion {

    __weak __typeof(self)weakSelf = self;
    [self.chatDialogsService fetchAllDialogs:^(QBDialogsPagedResult *result) {
        
        if ([weakSelf checkResult:result]) {
            [self addDialogs:result.dialogs];
            completion();
        }
    }];
}

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[@"name"] = dialogName;
    
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:completion];
}

- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion; {
    
    NSString *usersIDsAsString;//=[ids componentsJoinedByString:@","];
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[@"push[occupants_ids][]"] = usersIDsAsString;
    [self sendNotificationWithType:2 toRecipients:occupants chatDialog:chatDialog];
    
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:completion];
}

- (void)leaveWithUserId:(NSUInteger)userID fromChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion {
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[@"pull_all[occupants_ids][]"] = [NSString stringWithFormat:@"%d", userID];
    
    [self.chatDialogsService updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:completion];
}

#pragma mark - Create Chat Dialogs

- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent completion:(QBChatDialogResultBlock)completion {
    
    NSString *opponentID = [NSString stringWithFormat:@"%d", opponent.ID];
    NSArray *occupantsIDs = @[opponentID];
    
    // creating private chat dialog:
    QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
    
    chatDialog.type = QBChatDialogTypePrivate;
    chatDialog.occupantIDs = occupantsIDs;
    
	[self.chatDialogsService createChatDialog:chatDialog completion:completion];
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
        [weakSelf addDialog:result.dialog];
        [weakSelf sendNotificationWithType:1 toRecipients:ocupants chatDialog:result.dialog];
        completion(result);
    }];
}

- (QBChatMessage *)notification:(NSUInteger)type recipient:(QBUUser *)recipient text:(NSString *)text chatDialog:(QBChatDialog *)chatDialog {
    
    QBChatMessage *msg = [QBChatMessage message];
    
    msg.recipientID = recipient.ID;
    msg.text = text;
    
    NSMutableDictionary *customParams = [NSMutableDictionary new];
    customParams[@"xmpp_room_jid"] = chatDialog.roomJID;
    customParams[@"name"] = chatDialog.name;
    customParams[@"_id"] = chatDialog.ID;
    customParams[@"type"] = @(chatDialog.type);
    customParams[@"occupants_ids"] = chatDialog.occupantIDs;
    
    NSTimeInterval timestamp = (unsigned long)[[NSDate date] timeIntervalSince1970];
    customParams[@"date_sent"] = @(timestamp);
    customParams[@"notification_type"] = [NSString stringWithFormat:@"%d", type];
    
    msg.customParameters = customParams;
    
    return msg;
}

- (void)sendNotificationWithType:(NSUInteger)type toRecipients:(NSArray *)recipients chatDialog:(QBChatDialog *)chatDialog {

    NSString *text = [NSString stringWithFormat:@"%@ created a group conversation", self.currentUser.fullName];
    
    for (QBUUser *recipient in recipients) {
        QBChatMessage *notification = [self notification:type recipient:recipient text:text chatDialog:chatDialog];
        [self.messagesService sendMessage:notification saveToHistory:NO];
    }
}

#pragma mark - Join to room


- (void)addDialogs:(NSArray *)dialogs {
    
    for (QBChatDialog *chatDialog in dialogs) {
        [self addDialog:chatDialog];
    }
}

- (void)addDialog:(QBChatDialog *)chatDialog {
    
    if (chatDialog.type == QBChatDialogTypeGroup) {

        NSString *roomJID = chatDialog.roomJID;
        NSAssert(roomJID, @"Need update this case");
        
        QBChatRoom *existRoom = self.chatRooms[roomJID];
        
        if (!existRoom) {
            QBChatRoom *chatRoom = [[QBChatRoom alloc] initWithRoomJID:roomJID];
            [chatRoom joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
            self.chatRooms[roomJID] = chatRoom;
        }
        
        [self.dialogs addObject:chatDialog];
        
    } else if (chatDialog.type == QBChatDialogTypePrivate) {
    
        NSAssert(chatDialog.occupantIDs.count == 2, @"Array of user ids in chat. For private chat count = 2");
        
        NSString *myID = [NSString stringWithFormat:@"%d", self.currentUser.ID];
        for (NSString *strID in chatDialog.occupantIDs) {
            
            if (![strID isEqualToString:myID]) {
                self.privateDialogs[strID] = chatDialog;
                return;
            }
        }
        
        NSAssert(nil, @"Need update this logic");
    }
}

- (QBChatRoom *)roomWithRoomJID:(NSString *)roomJID {
    return self.chatRooms[roomJID];
}

- (QBChatDialog *)privateDialogWithOpponentID:(NSUInteger)opponentID {
    NSString *key = [NSString stringWithFormat:@"%d", opponentID];
    QBChatDialog *privateDialog = self.privateDialogs[key];
    
    return privateDialog;
}

- (void)updateChatDialogForChatMessage:(QBChatMessage *)chatMessage {
    
    NSString *kRoomJID = chatMessage.customParameters[@"xmpp_room_jid"];
    
    QBChatDialog *dialog = nil;//self.allDialogsAsDictionary[kRoomJID];
    if (dialog == nil) {
        NSAssert(!dialog, @"Dialog you are looking for not found.");
        return;
    }
    
    dialog.name = chatMessage.customParameters[@"name"];
    
    NSString *occupantsIDs = chatMessage.customParameters[@"occupants_ids"];
    dialog.occupantIDs = [occupantsIDs componentsSeparatedByString:@","];
}

//- (void)createOrUpdateChatDialogFromChatMessage:(QBChatMessage *)message {
//    
//    NSInteger notificationType = [message.customParameters[@"notification_type"] intValue];
//    
//    NSString *occupantsIDs = message.customParameters[@"occupants_ids"];
//    // if notification type = update dialog:
//    if (notificationType == 2) {
//        [self updateChatDialogForChatMessage:message];
//        return;
//    }
//    
//    // if notification type = create dialog:
//    QBChatDialog *newDialog = [self createChatDialogForChatMessage:message];
//    
//    // save to history:
//    if (newDialog.type == QBChatDialogTypePrivate) {
//        NSString *kSenderID = [NSString stringWithFormat:@"%lu",(unsigned long)message.senderID];
//#warning updae alldialogsasdictiononary
//        //        self.allDialogsAsDictionary[kSenderID] = newDialog;
//        return;
//    }
//    // if dialog type = group:
//#warning updae alldialogsasdictiononary
//    //self.allDialogsAsDictionary[newDialog.roomJID] = newDialog;
//    
//    // if user is not joined to room, join:
//    
//}

//- (QBChatDialog *)createChatDialogForChatMessage:(QBChatMessage *)chatMessage
//{
//    QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
//    
//    chatDialog.ID = chatMessage.customParameters[@"_id"];
//    chatDialog.roomJID = chatMessage.customParameters[@"xmpp_room_jid"];
//    chatDialog.name = chatMessage.customParameters[@"name"];
//    chatDialog.type = [chatMessage.customParameters[@"type"] intValue];
//    
//    NSString *occupantsIDs = chatMessage.customParameters[@"occupants_ids"];
//    chatDialog.occupantIDs = [occupantsIDs componentsSeparatedByString:@","];
//    
//    return chatDialog;
//}

/** Only for Group dialogs */

//- (void)updateDialogsLastMessageFields:(QBChatDialog *)dialog forLastMessage:(QBChatMessage *)message
//{
//#warning me.iD
//#warning QMContactList shared
//    //    dialog.lastMessageDate = message.datetime;
//    //    dialog.lastMessageText = message.text;
//    //    dialog.lastMessageUserID = message.senderID;
//    //    if (message.senderID != [QMContactList shared].me.ID) {
//    //        dialog.unreadMessageCount +=1;
//    //    }
//}

//- (QBChatDialog *)createPrivateDialogWithOpponentID:(NSString *)opponentID message:(QBChatMessage *)message
//{
//    QBChatDialog *newDialog = [QBChatDialog new];
//    newDialog.type = QBChatDialogTypePrivate;
//    newDialog.occupantIDs = @[ opponentID];  // occupant ID
//    [self updateDialogsLastMessageFields:newDialog forLastMessage:message];
//
//    return newDialog;
//}


//- (NSMutableDictionary *)dialogsAsDictionaryFromDialogsArray:(NSArray *)array
//{
//    NSMutableDictionary *dictionaryOfDialogs = [NSMutableDictionary new];
//    for (QBChatDialog *dialog in array) {
//        
//        if (dialog.type != QBChatDialogTypePrivate) {
//            
//            // save group dialogs by roomJID:
//            dictionaryOfDialogs[dialog.roomJID] = dialog;
//            continue;
//        }
//#warning me.iD
//#warning QMContactList shared
//        //        for (NSString *ID in dialog.occupantIDs) {
//        //            NSString *meID = [NSString stringWithFormat:@"%lu", (unsigned long)[QMContactList shared].me.ID];
//        //
//        //            // if my ID
//        //            if (![meID isEqualToString:ID]) {
//        //                dictionaryOfDialogs[ID] = dialog;
//        //                break;
//        //            }
//        //        }
//    }
//    return dictionaryOfDialogs;
//}

@end
