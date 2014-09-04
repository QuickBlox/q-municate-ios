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
#import "QMContentService.h"
#import "QMTextMessageCell.h"
#import "QMSystemMessageCell.h"
#import "QMAttachmentMessageCell.h"
#import "QMSoundManager.h"

@interface QMChatDataSource()

<UITableViewDataSource, QMChatCellDelegate>

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
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    ILog(@"%@ - %@", NSStringFromSelector(_cmd), self);
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
            
            QBChatDialog *dialogForReceiverMessage = [[QMApi instance] chatDialogWithID:message.cParamDialogID];
            
            if ([weakSelf.chatDialog isEqual:dialogForReceiverMessage] && message.cParamNotificationType == QMMessageNotificationTypeNone) {
                
                if (message.senderID != [QMApi instance].currentUser.ID) {
                    [QMSoundManager playMessageReceivedSound];
                    
                    [weakSelf insertNewMessage:message];
                }
                
            }
            else if (message.cParamNotificationType == QMMessageNotificationTypeDeliveryMessage ){
            }
            
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
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (NSString *)cellIDAtQMMessage:(QMMessage *)message {
    
    switch (message.type) {
            
        case QMMessageTypeSystem: return QMSystemMessageCellID; break;
        case QMMessageTypePhoto: return QMAttachmentMessageCellID; break;
        case QMMessageTypeText: return QMTextMessageCellID; break;
        default: NSAssert(nil, @"Need update this case"); break;
    }
}

- (QMMessage *)qmMessageWithQbChatHistoryMessage:(QBChatHistoryMessage *)historyMessage {
    
    QMMessage *message = [[QMMessage alloc] initWithChatHistoryMessage:historyMessage];
    BOOL fromMe = ([QMApi instance].currentUser.ID == historyMessage.senderID);
    
    message.minWidth = fromMe || (message.chatDialog.type == QBChatDialogTypePrivate) ? 78 : -1;
    message.align =  fromMe ? QMMessageContentAlignRight : QMMessageContentAlignLeft;
    
    return message;
}

#pragma mark - Abstract methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMMessage *message = self.messages[indexPath.row];
    QMChatCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIDAtQMMessage:message]];
    
    cell.delegate = self;
    
    BOOL isMe = [QMApi instance].currentUser.ID == message.senderID;
    QBUUser *user = [[QMApi instance] userWithID:message.senderID];
    [cell setMessage:message user:user isMe:isMe];
    
    return cell;
}

#pragma mark - Send actions

- (void)sendImage:(UIImage *)image {
    
    __weak __typeof(self)weakSelf = self;
    
    [SVProgressHUD showProgress:0 status:nil maskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance].contentService uploadJPEGImage:image progress:^(float progress) {
        
        [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
        
    } completion:^(QBCFileUploadTaskResult *result) {
        
        if (result.success) {
            
            [[QMApi instance] sendAttachment:result.uploadedBlob.publicUrl toDialog:weakSelf.chatDialog completion:^(QBChatMessage *message) {
                [weakSelf insertNewMessage:message];
            }];
        }
        
        [SVProgressHUD dismiss];
    }];
}

- (void)sendMessage:(NSString *)text {
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] sendText:text toDialog:self.chatDialog completion:^(QBChatMessage *message) {
        
        [QMSoundManager playMessageSentSound];
        [weakSelf insertNewMessage:message];
    }];
}

#pragma mark - QMChatCellDelegate

#define USE_ATTACHMENT_FROM_CACHE 1

- (void)chatCell:(id)cell didSelectMessage:(QMMessage *)message {
    
    if ([cell isKindOfClass:[QMAttachmentMessageCell class]]) {
#if USE_ATTACHMENT_FROM_CACHE
        QMAttachmentMessageCell *imageCell = cell;
        
        if ([self.delegate respondsToSelector:@selector(chatDatasource:prepareImageAttachement:fromView:)]) {
            
            UIImageView *imageView = (UIImageView *)imageCell.balloonImageView;
            UIImage *image  = imageView.image;
            
            [self.delegate chatDatasource:self prepareImageAttachement:image fromView:imageView];
        }
#else
        if ([self.delegate respondsToSelector:@selector(chatDatasource:prepareImageURLAttachement:)]) {
            
            QBChatAttachment *attachment = [message.attachments firstObject];
            NSURL *url = [NSURL URLWithString:attachment.url];
            [self.delegate chatDatasource:self prepareImageURLAttachement:url];
        }
#endif
    }
}

@end