//

//  QMChatDataSource.m
//  Q-municate
//
//  Created by Andrey on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"
#import "QMChatService.h"
#import "QMDBStorage+Messages.h"
#import "QMMessage.h"
#import "QMUsersService.h"
#import "QMDBStorage+Messages.h"

@interface QMChatDataSource()

<UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) QBUUser *opponent;
@property (strong, nonatomic) QBChatRoom *chatRoom;


@end

@implementation QMChatDataSource

- (void)dealloc {
    
    [self unsubsicribeAlltNotifications];
}

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView {
    
    self = [super init];
    
    if (self) {
        
        [self subscribeToChatNotifications];
        
        self.chatDialog = dialog;
        self.tableView = tableView;
        tableView.dataSource = self;
        
        [tableView registerClass:[QMTextMessageCell class] forCellReuseIdentifier:QMTextMessageCellID];
        [tableView registerClass:[QMAttachmentMessageCell class] forCellReuseIdentifier:QMAttachmentMessageCellID];
        [tableView registerClass:[QMSystemMessageCell class] forCellReuseIdentifier:QMSystemMessageCellID];
    }
    
    return self;
}

- (NSString *)cellIDAtQMMessage:(QMMessage *)message {
    
    switch (message.type) {
            
        case QMMessageTypeSystem: return QMSystemMessageCellID; break;
        case QMMessageTypePhoto: return QMAttachmentMessageCellID; break;
        case QMMessageTypeText: return QMTextMessageCellID; break;
            
        default:
            @throw
            [NSException exceptionWithName:NSInternalInconsistencyException
                                                reason:@"Check it"
                                              userInfo:nil];
            break;
    }
}

- (void)reloadTableViewData {
    
    [self.tableView reloadData];
}

#define MESSAGES_DEBUG 1

- (void)loadHistory:(void(^)(void))finish {
    
#if MESSAGES_DEBUG

    QBChatHistoryMessage *message = [[QBChatHistoryMessage alloc] init];
    
    message.text = @"6) SQLite can be a very, very fast way to cache large data sets. A map application for instance can cache its tiles into SQLite files. The most expensive part is disk I/O. Avoid many small writes by sending BEGIN; and COMMIT; between large blocks. We use a 2 second timer for instance that resets on each new submit. When it expires, we send COMMIT; , which causes all your writes to go in one large chunk. SQLite stores transaction data to disk and doing this Begin/End wrapping avoids creation of many transaction files, grouping all of the transactions into one file.";
    
    QBChatHistoryMessage *m1 = [message copy];
    m1.text = @", which causes all your writes to go in one large chunk. SQLite stores transaction data to disk and doing this Begin/End wrapping avoids creation of many transaction files, grouping all of the transactions into one file.";
    m1.senderID = 1;
    
    QBChatHistoryMessage *m2 = [m1 copy];
    m2.attachments = @[@(1)];

    QBChatHistoryMessage *m3 = [m1 copy];
    m3.text = @"Hi";
    
    QBChatHistoryMessage *m4 = [m3 copy];
    m4.text = @"Hey there. Is anybody here?";
    
    NSArray *messages = @[m2, m3, message, m1, message, m1, m3, message, message, m4, m1, m3, m3];
    
    NSString *identifier = [self messagesIdentifier];
    
    NSAssert(identifier, @"check it");
    
//    [chatService setHistory:messages forIdentifier:identifier];
    
    NSMutableArray *qmChatHistroy = [NSMutableArray arrayWithCapacity:messages.count];
    
    for (QBChatHistoryMessage *qbChatHistoryMessage in messages) {
        
        QMMessage *message = [self qmMessageWithQbChatHistoryMessage:qbChatHistoryMessage];
        [qmChatHistroy addObject:message];
    }
    
    self.qmChatHistory = qmChatHistroy;
    
    return;
#endif
    
//    void(^reloadDataAfterGetMessages) (NSArray *messages) = ^(NSArray *messages) {
//        
//        if (messages.count > 0) {
//            
//            QMChatService *chatService = [QMChatService shared];
//            NSString *identifier = [self messagesIdentifier];
//            
//            NSAssert(identifier, @"check it");
//            
//            [chatService setHistory:messages forIdentifier:identifier];
//            
//            NSMutableArray *qmChatHistroy = [NSMutableArray arrayWithCapacity:messages.count];
//            
//            for (QBChatHistoryMessage *qbChatHistoryMessage in messages) {
//                
//                QMMessage *message = [self qmMessageWithQbChatHistoryMessage:qbChatHistoryMessage];
//                [qmChatHistroy addObject:message];
//            }
//            
//            self.qmChatHistory = qmChatHistroy;
//        }
//        
//        finish();
//    };
//    
//    [[QMChatService shared] getMessageHistoryWithDialogID:self.chatDialog.ID withCompletion:^(NSArray *messages, BOOL success, NSError *error) {
//        reloadDataAfterGetMessages(messages);
//    }];
}

- (QMMessage *)qmMessageWithQbChatHistoryMessage:(QBChatHistoryMessage *)historyMessage {
    
    QMMessage *message = [[QMMessage alloc] init];
    
    message.data = historyMessage;
    
    if (message.type) {

    }
//    message.align = (contactList.me.ID == historyMessage.senderID) ? QMMessageContentAlignRight : QMMessageContentAlignLeft;
    
    return message;
}

#pragma mark - Abstract methods

- (NSArray *)cachedHistory {
    
    CHECK_OVERRIDE();
    return nil;
}

- (void)sendMessageWithText:(NSString *)text {
    
    CHECK_OVERRIDE();
}

- (NSString *)messagesIdentifier {
    
    CHECK_OVERRIDE();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.qmChatHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMMessage *message = self.qmChatHistory[indexPath.row];
    QMChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIDAtQMMessage:message]
                                                       forIndexPath:indexPath];
    cell.hideUserImage = NO;
    cell.message = message;
    
    return cell;
}

#pragma mark - Notifications

- (void)subscribeToChatNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(chatDidReceiveMessageNotification:)
                               name:kChatDidReceiveMessageNotification
                             object:nil];
    
	[notificationCenter addObserver:self
                           selector:@selector(chatRoomListUpdateNotification:)
                               name:kChatRoomListUpdateNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(chatDialogsDidLoadedNotification:)
                               name:kChatDialogsDidLoadedNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(chatRoomDidReceiveMessageNotification:)
                               name:kChatRoomDidReceiveMessageNotification
                             object:nil];
}

- (void)unsubsicribeAlltNotifications {
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self];
}

#pragma mark -

- (void)chatDidReceiveMessageNotification:(NSNotification *)notificaiton {
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)chatRoomListUpdateNotification:(NSNotification *)notification {
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)chatDialogsDidLoadedNotification:(NSNotification *)notification {
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification {
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

#pragma mark - Send actions 

- (void)sendImage:(UIImage *)image {
    
}

- (void)sendMessage:(NSString *)message {
    
}

//
//#pragma mark - Notifications
//
//- (void)localChatDidReceiveMessage:(NSNotification *)notification
//{
//    //    [self updateChatDialog];
//    //    [self resetTableView];
//}
//
// ************************** CHAT ROOM **********************************
//- (void)chatRoomDidEnterNotification
//{
//    self.chatRoom = [QMChatService shared].allChatRoomsAsDictionary[self.chatDialog.roomJID];
//
//    if (self.chatHistory != nil) {
//        [QMUtilities removeIndicatorView];
//        return;
//    }
//
//    // load history:
//    [self loadHistory];
//}
//
//- (void)chatRoomDidReveiveMessage
//{
//    // update unread message count:
//    [self updateChatDialog];
//
//    [self resetTableView];
//}
//
//- (void)updateNavTitleWithNotification:(NSNotification *)notification
//{
//    // update chat dialog:
//    NSString *roomJID = notification.userInfo[@"room_jid"];
//    QBChatDialog *dialog = [QMChatService shared].allDialogsAsDictionary[roomJID];
//    self.chatDialog = dialog;
//    self.title = dialog.name;
//}
//
//
//#pragma mark -
//- (IBAction)sendMessageButtonClicked:(UIButton *)sender
//{
//	if (self.inputMessageTextField.text.length) {
//		QBChatMessage *chatMessage = [QBChatMessage new];
//		chatMessage.text = self.inputMessageTextField.text;
//
//        // additional params:
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        NSTimeInterval timestamp = (unsigned long)[[NSDate date] timeIntervalSince1970];
//        params[@"date_sent"] = @(timestamp);
//        params[@"save_to_history"] = @YES;
//        chatMessage.customParameters = params;
//
//		if (self.chatDialog.type == QBChatDialogTypePrivate) { // private chat
//            chatMessage.recipientID = self.opponent.ID;
//            chatMessage.senderID = [QMContactList shared].me.ID;
//			[[QMChatService shared] sendMessage:chatMessage];
//
//		} else { // group chat
//            [[QMChatService shared] sendMessage:chatMessage toRoom:self.chatRoom];
//		}
//        self.inputMessageTextField.text = @"";
//        [self resetTableView];
//	}
//}
//
//- (BOOL)userIsJoinedRoomForDialog:(QBChatDialog *)dialog
//{
//    QBChatRoom *currentRoom = [QMChatService shared].allChatRoomsAsDictionary[dialog.roomJID];
//    if (currentRoom == nil || !currentRoom.isJoined) {
//        return NO;
//    }
//    return YES;
//}

@end