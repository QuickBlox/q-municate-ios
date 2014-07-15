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

/**
 *  Specifies whether or not the view controller should automatically scroll to the most recent message
 *  when the view appears and when sending, receiving, and composing a new message.
 *
 *  @discussion The default value is `YES`, which allows the view controller to scroll automatically to the most recent message.
 *  Set to `NO` if you want to manage scrolling yourself.
 */
@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;

@end

@implementation QMChatDataSource

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView {
    
    self = [super init];
    
    if (self) {
        
        self.chatDialog = dialog;
        self.tableView = tableView;
        self.messages = [NSMutableArray array];
        
        self.automaticallyScrollsToMostRecentMessage = YES;
        
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
            [self scrollToBottomAnimated:NO];
            
            [SVProgressHUD dismiss];
        }];
    }
    
    return self;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    
    if (self.messages.count > 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count-1 inSection:0];
        
        if (indexPath > 0) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
        }
    }
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