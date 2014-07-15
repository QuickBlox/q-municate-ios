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
#import "SVProgressHUD.h"

@interface QMChatDataSource()

<UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) QBUUser *opponent;
@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation QMChatDataSource

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView {
    
    self = [super init];
    
    if (self) {
        
        self.chatDialog = dialog;
        self.tableView = tableView;
        self.messages = [NSMutableArray array];
        
        tableView.dataSource = self;
        
        [tableView registerClass:[QMTextMessageCell class] forCellReuseIdentifier:QMTextMessageCellID];
        [tableView registerClass:[QMAttachmentMessageCell class] forCellReuseIdentifier:QMAttachmentMessageCellID];
        [tableView registerClass:[QMSystemMessageCell class] forCellReuseIdentifier:QMSystemMessageCellID];
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[QMApi instance] fetchMessageWithDialog:self.chatDialog complete:^(BOOL success) {
            
            NSArray *history = [[QMApi instance] messagesWithDialog:self.chatDialog];
            
            for (QBChatHistoryMessage *historyMessage in history) {
                QMMessage *qmMessage = [self qmMessageWithQbChatHistoryMessage:historyMessage];
                [self.messages addObject:qmMessage];
            }
        
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
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

- (QMMessage *)qmMessageWithQbChatHistoryMessage:(QBChatHistoryMessage *)historyMessage {
    
    QMMessage *message = [[QMMessage alloc] initWithChatHistoryMessage:historyMessage];
    message.align = ([QMApi instance].currentUser.ID == historyMessage.senderID) ? QMMessageContentAlignRight : QMMessageContentAlignLeft;
    
    return message;
}

#pragma mark - Abstract methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMMessage *message = self.messages[indexPath.row];
    QMChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIDAtQMMessage:message]
                                                       forIndexPath:indexPath];
    cell.hideUserImage = [QMApi instance].currentUser.ID == message.senderID;
    cell.message = message;
    
    return cell;
}

#pragma mark - Send actions

- (void)sendImage:(UIImage *)image {
    
}

- (void)sendMessage:(NSString *)message {
    
    [[QMApi instance] sendText:message toDialog:self.chatDialog];
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


//		if (self.chatDialog.type == QBChatDialogTypePrivate) { // private chat
//            chatMessage.recipientID = self.opponent.ID;
//            chatMessage.senderID = [QMContactList shared].me.ID;
//			[[QMChatService shared] sendMessage:chatMessage];




@end