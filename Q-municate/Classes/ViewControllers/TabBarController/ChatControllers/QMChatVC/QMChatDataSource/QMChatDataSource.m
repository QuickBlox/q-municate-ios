//

//  QMChatDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"
#import "QMDBStorage+Messages.h"
#import "QMMessage.h"
#import "QMApi.h"
#import "SVProgressHUD.h"
#import "QMChatReceiver.h"

@interface QMChatDataSource()

<UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
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

- (void)dealloc {
    [[QMChatReceiver instance] unsubsribeForTarget:self];
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), self);
}

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
        
        __weak __typeof(self)weakSelf = self;

        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[QMApi instance] fetchMessageWithDialog:self.chatDialog complete:^(BOOL success) {
            [weakSelf reloadCachedMessages:NO];
            [SVProgressHUD dismiss];
        }];
        
        [[QMChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
            [weakSelf reloadCachedMessages:YES];
        }];
        
        [[QMChatReceiver instance] chatDidNotSendMessageWithTarget:self block:^(QBChatMessage *message) {
            NSLog(@"chatDidNotSendMessageWithTarget");
        }];
    }
    
    return self;
}

- (void)insertNewMessage:(QBChatMessage *)message {

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count inSection:0];
    QMMessage *qmMessage = [self qmMessageWithQbChatHistoryMessage:(QBChatHistoryMessage *)message];
    [self.messages addObject:qmMessage];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    [self scrollToBottomAnimated:YES];
}

- (void)reloadCachedMessages:(BOOL)animated {
    
    NSArray *history = [[QMApi instance] messagesHistoryWithDialog:self.chatDialog];
    
    [self.messages removeAllObjects];
    
    for (QBChatHistoryMessage *historyMessage in history) {
        QMMessage *qmMessage = [self qmMessageWithQbChatHistoryMessage:historyMessage];
        [self.messages addObject:qmMessage];
    }
    
    [self.tableView reloadData];
    [self scrollToBottomAnimated:animated];
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
    QMChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIDAtQMMessage:message]];
    
    BOOL myMessage = [QMApi instance].currentUser.ID == message.senderID;
    
    cell.hideUserImage = myMessage;    
    cell.user = [[QMApi instance] userWithID:message.senderID];
    cell.message = message;
    
    return cell;
}

#pragma mark - Send actions

- (void)sendImage:(UIImage *)image {
    
}

- (void)sendMessage:(NSString *)text {
    
    QBChatMessage *message = [[QMApi instance] sendText:text toDialog:self.chatDialog];
    if (message) {
        [self insertNewMessage:message];
    }
}

@end