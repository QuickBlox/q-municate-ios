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
#import "REAlertView.h"
#import "QMChatReceiver.h"
#import "QMContentService.h"
#import "QMTextMessageCell.h"
#import "QMSystemMessageCell.h"
#import "QMAttachmentMessageCell.h"
#import "QMSoundManager.h"
#import "QMChatSection.h"
#import "QMContactRequestCell.h"
#import "QMChatNotificationCell.h"


static NSString *const kQMContactRequestCellID = @"QMContactRequestCell";


@interface QMChatDataSource()

<UITableViewDataSource, QMChatCellDelegate, QMUsersListDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *chatSections;

/**
 *  Specifies whether or not the view controller should automatically scroll to the most recent message
 *  when the view appears and when sending, receiving, and composing a new message.
 *
 *  @discussion The default value is `YES`, which allows the view controller to scroll automatically to the most recent message.
 *  Set to `NO` if you want to manage scrolling yourself.
 */
@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;

@property (strong, nonatomic) QMMessage *contactRequestMessage;

@end

@implementation QMChatDataSource

- (void)dealloc {
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    ILog(@"%@ - %@", NSStringFromSelector(_cmd), self);
}

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView inputBarDelegate:(id <QMChatInputBarLockingProtocol>)inputBarDelegate {
    
    self = [super init];
    
    if (self) {
        
        self.chatDialog = dialog;
        self.tableView = tableView;
        self.inputBarDelegate = inputBarDelegate;
        self.chatSections = [NSMutableArray array];
        
        self.automaticallyScrollsToMostRecentMessage = YES;
        
        tableView.dataSource = self;
        [tableView registerClass:[QMTextMessageCell class] forCellReuseIdentifier:QMTextMessageCellID];
        [tableView registerClass:[QMAttachmentMessageCell class] forCellReuseIdentifier:QMAttachmentMessageCellID];
        [tableView registerNib:[UINib nibWithNibName:@"QMChatNotificationCell" bundle:nil] forCellReuseIdentifier:kChatNotificationCellID];
        [tableView registerNib:[UINib nibWithNibName:@"QMContactRequestCell" bundle:nil] forCellReuseIdentifier:kQMContactRequestCellID];
        
        __weak __typeof(self)weakSelf = self;
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[QMApi instance] fetchMessageWithDialog:self.chatDialog complete:^(BOOL success) {
            
            [weakSelf reloadCachedMessages:NO];
            [SVProgressHUD dismiss];
            
        }];
        
        [[QMChatReceiver instance] addedToGroupUsersWasLoadedWithTarget:self block:^(QBChatMessage *message, BOOL usersWasLoaded) {
            // only for group chat messages:
            [weakSelf insertNewMessage:message];
        }];
        
        [[QMChatReceiver instance] chatRoomDidEnterWithTarget:self block:^(QBChatRoom *room) {
            if ([weakSelf.chatDialog.chatRoom isEqual:room]) {
                if (room.isJoined) {
                    [weakSelf unlockInputBar];
                }
            }
        }];
        
        [[QMChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
            
            if (!message.cParamDialogID) {
                return;
            }
            QBChatDialog *dialogForReceiverMessage = [[QMApi instance] chatDialogWithID:message.cParamDialogID];
            
            if ([weakSelf.chatDialog isEqual:dialogForReceiverMessage] && message.cParamNotificationType != QMMessageNotificationTypeDeliveryMessage) {
                
                if (message.cParamNotificationType == QMMessageNotificationTypeCreateGroupDialog) {
                    if (![dialogForReceiverMessage.chatRoom isJoined]) {
                        [weakSelf lockInputBar];
                    }
                    return;
                }
                else if (message.cParamNotificationType == QMMessageNotificationTypeUpdateGroupDialog) {
                    if (message.cParamDialogOccupantsIDs) {
                        return;
                    }
                    [weakSelf insertNewMessage:message];
                    return;
                }
                else if (message.cParamNotificationType == QMMessageNotificationTypeConfirmContactRequest) {
                    [weakSelf unlockInputBar];
                }
                else if (message.cParamNotificationType == QMMessageNotificationTypeDeleteContactRequest) {
                    [weakSelf unmarkContactRequestNotification];
                    [weakSelf lockInputBar];
                }
                
                if (message.senderID != [QMApi instance].currentUser.ID) {  // for group chats
                    [QMSoundManager playMessageReceivedSound];
                    
                    [weakSelf insertNewMessage:message];
                }
                
            }
        }];
    }
    
    if (!self.chatDialog || self.chatDialog.type == QBChatDialogTypeGroup) {
        return self;
    }
    
    // check for friend. If it's not a friend, lock input bar
    BOOL isFried = [[QMApi instance] isFriendForChatDialog:self.chatDialog];
    if (!isFried) {
        [self lockInputBar];
    }
    
    return self;
}

- (void)markContactRequestNotificationIfNeededForChatSection:(QMChatSection *)chatSection
{
    QMMessage *lastMessage = [chatSection.messages lastObject];
    [self markContactRequestNotificationIfNeeded:lastMessage];
}

- (void)markContactRequestNotificationIfNeeded:(QMMessage *)notificaion
{
    if (self.chatDialog.type != QBChatDialogTypePrivate) {
        return;
    }
    QBUUser *contact = [[QMApi instance] userForContactRequestWithPrivateChatDialog:self.chatDialog];
    
    if (notificaion.cParamNotificationType == QMMessageNotificationTypeSendContactRequest && notificaion.senderID == contact.ID) {
        notificaion.marked = YES;
        self.contactRequestMessage = notificaion;
    }
}

- (void)unmarkContactRequestNotification
{
    if (self.contactRequestMessage) {
        self.contactRequestMessage.marked = NO;
        self.contactRequestMessage = nil;
        
        QMChatSection *lastSection  = [self.chatSections lastObject];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastSection.messages.count-1 inSection:self.chatSections.count-1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (QMChatSection *)chatSectionForDate:(NSDate *)date
{
    NSInteger identifer = [QMChatSection daysBetweenDate:date andDate:[NSDate date]];
    for (QMChatSection *section in self.chatSections) {
        if (identifer == section.identifier) {
            return section;
        }
    }
    QMChatSection *newSection = [[QMChatSection alloc] initWithDate:date];
    [self.chatSections addObject:newSection];
    return newSection;
}

- (void)insertNewMessage:(QBChatMessage *)message {
    
    QMMessage *qmMessage = [self qmMessageWithQbChatHistoryMessage:message];
    [self markContactRequestNotificationIfNeeded:qmMessage];
    
    QMChatSection *chatSection = [self chatSectionForDate:qmMessage.datetime];
    [chatSection addMessage:qmMessage];
    
    [self.tableView beginUpdates];
    if (chatSection.messages.count > 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:chatSection.messages.count-1 inSection:self.chatSections.count-1];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.chatSections.count-1] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self.tableView endUpdates];
    
    [self scrollToBottomAnimated:YES];
}

- (void)reloadCachedMessages:(BOOL)animated {
    
    NSArray *history = [[QMApi instance] messagesHistoryWithDialog:self.chatDialog];
    
    [self.chatSections removeAllObjects];
    self.chatSections = [self sortedChatSectionsFromMessageArray:history];
    
    [self.tableView reloadData];
    [self scrollToBottomAnimated:animated];
}

// ******************************************************************************
- (NSMutableArray *)sortedChatSectionsFromMessageArray:(NSArray *)messagesArray
{
    NSMutableArray *arrayOfSections = [[NSMutableArray alloc] init];
    NSMutableDictionary *sectionsDictionary = [NSMutableDictionary new];
    NSDate *dateNow = [NSDate date];
    
    for (QBChatHistoryMessage *historyMessage in messagesArray) {
        QMMessage *qmMessage = [self qmMessageWithQbChatHistoryMessage:historyMessage];
        NSNumber *key = @([QMChatSection daysBetweenDate:historyMessage.datetime andDate:dateNow]);
        QMChatSection *section = sectionsDictionary[key];
        if (!section) {
            section = [[QMChatSection alloc] initWithDate:qmMessage.datetime];
            sectionsDictionary[key] = section;
            [arrayOfSections addObject:section];
            
        }
        [section addMessage:qmMessage];
        
    }
    // check last message for contact request notification:
    [self markContactRequestNotificationIfNeededForChatSection:arrayOfSections.lastObject];
    
    return arrayOfSections;
}
// *******************************************************************************

- (void)scrollToBottomAnimated:(BOOL)animated {
    
    if (self.chatSections.count > 0) {
        QMChatSection *chatSection = [self.chatSections lastObject];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:chatSection.messages.count-1 inSection:self.chatSections.count-1];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

- (NSString *)cellIDAtQMMessage:(QMMessage *)message {
    
    switch (message.type) {
            
        case QMMessageTypeSystem: return kChatNotificationCellID; break;
        case QMMessageTypePhoto: return QMAttachmentMessageCellID; break;
        case QMMessageTypeText: return QMTextMessageCellID; break;
        default: NSAssert(nil, @"Need update this case"); break;
    }
}

- (QMMessage *)qmMessageWithQbChatHistoryMessage:(QBChatAbstractMessage *)historyMessage {
    
    QMMessage *message = [[QMMessage alloc] initWithChatHistoryMessage:historyMessage];
    BOOL fromMe = ([QMApi instance].currentUser.ID == historyMessage.senderID);
    
    message.minWidth = fromMe || (message.chatDialog.type == QBChatDialogTypePrivate) ? 78 : -1;
    message.align =  fromMe ? QMMessageContentAlignRight : QMMessageContentAlignLeft;
    
    return message;
}

#pragma mark - Abstract methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    QMChatSection *chatSection = self.chatSections[section];
    NSAssert(chatSection, @"Section not found. Check this case");
    return ([chatSection.messages count] > 0) ? chatSection.name : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.chatSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    QMChatSection *chatSection = self.chatSections[section];
    return chatSection.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatSection *chatSection = self.chatSections[indexPath.section];
    QMMessage *message = chatSection.messages[indexPath.row];
    
    if (message.marked) {
        QMContactRequestCell *contactRequestCell = [tableView dequeueReusableCellWithIdentifier:kQMContactRequestCellID];
        contactRequestCell.delegate = self;
        contactRequestCell.notification = message;
        return contactRequestCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self cellIDAtQMMessage:message]];
    if ([cell isKindOfClass:QMChatNotificationCell.class]) {
        QMChatNotificationCell *notificationCell = (QMChatNotificationCell *)cell;
        notificationCell.notification = message;
        return notificationCell;
    }
    QMChatCell *chatCell = (QMChatCell *)cell;
    chatCell.delegate = self;
    
    BOOL isMe = [QMApi instance].currentUser.ID == message.senderID;
    QBUUser *user = [[QMApi instance] userWithID:message.senderID];
    [chatCell setMessage:message user:user isMe:isMe];
    
    return chatCell;
}

#pragma mark - Send actions

- (void)sendImage:(UIImage *)image {
    
    __weak __typeof(self)weakSelf = self;
    
    [SVProgressHUD showProgress:0 status:nil maskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance].contentService uploadJPEGImage:image progress:^(float progress) {
        
        [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
        
    } completion:^(QBCFileUploadTaskResult *result) {
        
        if (result.success) {
            
            [[QMApi instance] sendAttachment:result.uploadedBlob toDialog:weakSelf.chatDialog completion:^(QBChatMessage *message) {
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


#pragma mark - Contact Request Delegate

- (void)contactRequestWasAcceptedForUser:(QBUUser *)user
{
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] confirmAddContactRequest:user completion:^(BOOL success, QBChatMessage *notification) {
        
        [weakSelf unmarkContactRequestNotification];
        [weakSelf insertNewMessage:notification];
        [weakSelf unlockInputBar];
    }];
}

- (void)contactRequestWasRejectedForUser:(QBUUser *)user
{
    __weak __typeof(self)weakSelf = self;
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_REJECT_FRIENDS_REQUEST", @"{User's full name}"),  user.fullName];
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{}];
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_OK", nil) andActionBlock:^{
            //
            [[QMApi instance] rejectAddContactRequest:user completion:^(BOOL success, QBChatMessage *notification) {
                
                [weakSelf unmarkContactRequestNotification];
                [weakSelf insertNewMessage:notification];
            }];
        }];
    }];
}

#pragma mark - Input Bar Locking

- (void)lockInputBar
{   
    if ([self.inputBarDelegate respondsToSelector:@selector(inputBarShouldLock)]) {
        [self.inputBarDelegate inputBarShouldLock];
    }
}

- (void)unlockInputBar
{
    if ([self.inputBarDelegate respondsToSelector:@selector(inputBarShouldUnlock)]) {
        [self.inputBarDelegate inputBarShouldUnlock];
    }
}

@end