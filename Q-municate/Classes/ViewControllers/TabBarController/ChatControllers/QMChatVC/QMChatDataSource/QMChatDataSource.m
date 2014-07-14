//

//  QMChatDataSource.m
//  Q-municate
//
//  Created by Andrey on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"
#import "QMDBStorage+Messages.h"
#import "QMMessage.h"
#import "QMApi.h"

@interface QMChatDataSource()

<UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) QBUUser *opponent;
@property (strong, nonatomic) QBChatRoom *chatRoom;

@end

@implementation QMChatDataSource

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView {
    
    self = [super init];
    
    if (self) {
        
        self.chatDialog = dialog;
        self.tableView = tableView;
        tableView.dataSource = self;
        
        [tableView registerClass:[QMTextMessageCell class] forCellReuseIdentifier:QMTextMessageCellID];
        [tableView registerClass:[QMAttachmentMessageCell class] forCellReuseIdentifier:QMAttachmentMessageCellID];
        [tableView registerClass:[QMSystemMessageCell class] forCellReuseIdentifier:QMSystemMessageCellID];
        
        [[QMApi instance] fetchMessageWithDialog:self.chatDialog complete:^(BOOL success) {
            [self.tableView reloadData];
        }];
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

- (NSArray *)messages {
    
    NSArray *messages = [[QMApi instance] messagesWithDialog:self.chatDialog];

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:messages.count];
    
    for (QBChatHistoryMessage *message in messages) {
        QMMessage *qmMessage = [self qmMessageWithQbChatHistoryMessage:message];
        [result addObject:qmMessage];
    }
    
    return messages;
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


- (void)sendMessageWithText:(NSString *)text {
    
    CHECK_OVERRIDE();
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMMessage *message = self.messages[indexPath.row];
    QMChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIDAtQMMessage:message]
                                                       forIndexPath:indexPath];
    cell.hideUserImage = NO;
    cell.message = message;
    
    return cell;
}

#pragma mark - Send actions 

- (void)sendImage:(UIImage *)image {
    
}

- (void)sendMessage:(NSString *)message {
    
//    [QMApi instance] send
    
}


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

@end