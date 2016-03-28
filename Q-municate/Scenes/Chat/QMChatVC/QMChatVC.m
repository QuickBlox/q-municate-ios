//
//  QMChatVC.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/9/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatVC.h"
#import "QMCore.h"
#import "QMMessageStatusStringBuilder.h"
#import "QMPlaceholder.h"
#import "REAlertView+QMSuccess.h"
#import "QMSoundManager.h"
#import "QMImagePicker.h"
#import "REActionSheet.h"
#import "QMOnlineTitleView.h"

// helpers
#import "QMChatButtonsFactory.h"
#import "UIImage+fixOrientation.h"
#import <QMDateUtils.h>

// external
#import "AGEmojiKeyBoardView.h"

static const NSInteger kQMEmojiButtonTag = 100;
static const CGFloat kQMEmojiButtonSize = 45.0f;
static const CGFloat kQMInputToolbarTextContainerInsetRight = 25.0f;
static const CGFloat kQMAttachmentCellSize = 200.0f;
static const CGFloat kQMWidthPadding = 40.0f;
static const CGFloat kQMAvatarSize = 28.0f;
static const CGFloat kQMGroupAvatarSize = 36.0f;

@interface QMChatVC ()

<
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMChatAttachmentServiceDelegate,
QMContactListServiceDelegate,

QMChatActionsHandler,
QMChatCellDelegate,

QMImagePickerResultHandler,

AGEmojiKeyboardViewDataSource,
AGEmojiKeyboardViewDelegate
>

/**
 *  Detailed cells set
 */
@property (strong, nonatomic) NSMutableSet *detailedCells;

/**
 *  Attachment Cells
 */
@property (strong, nonatomic) NSMapTable *attachmentCells;

/**
 *  Navigation bar online title
 */
@property (weak, nonatomic) IBOutlet QMOnlineTitleView *onlineTitleView;

/**
 *  Determines whether opponent is typing now
 */
@property (assign, nonatomic) BOOL isOpponentTyping;

/**
 *  Stored messages in memory storage
 */
@property (strong, nonatomic) NSArray *storedMessages;

/**
 *  Observer for UIApplicationWillResignActiveNotification
 */
@property (strong, nonatomic) id observerWillResignActive;

/**
 *  Timer for typing status
 */
@property (strong, nonatomic) NSTimer *typingTimer;

/**
 *  Message status text builder
 */
@property (strong, nonatomic) QMMessageStatusStringBuilder *messageStatusStringBuilder;

/**
 *  Contact request task
 */
@property (weak, nonatomic) BFTask *contactRequestTask;

@end

@implementation QMChatVC

@dynamic storedMessages;

#pragma mark - Static methods

+ (QMChatVC *)chatViewControllerWithChatDialog:(QBChatDialog *)chatDialog {
    
    return [[QMChatVC alloc] initWithChatDialog:chatDialog];
}

#pragma mark - QMChatViewController data source overrides

- (NSUInteger)senderID {
    
    return [QMCore instance].currentProfile.userData.ID;
}

- (NSString *)senderDisplayName {
    
    return [QMCore instance].currentProfile.userData.fullName;
}

- (CGFloat)heightForSectionHeader {
    
    return 40.0f;
}

#pragma mark - Life cycle

- (instancetype)initWithChatDialog:(QBChatDialog *)chatDialog {
    
    self = [super init];
    
    if (self) {
        
        _chatDialog = chatDialog;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // top layout inset for collection view
    self.topContentAdditionalInset = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    // setting up chat controller
    self.collectionView.backgroundColor = [UIColor colorWithRed:237.0f/255.0f green:230.0f/255.0f blue:211.0f/255.0f alpha:1.0f];
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"QM_STR_INPUTTOOLBAR_PLACEHOLDER", nil);
    
    // setting up properties
    self.detailedCells = [NSMutableSet set];
    self.attachmentCells = [NSMapTable strongToWeakObjectsMapTable];
    self.messageStatusStringBuilder = [[QMMessageStatusStringBuilder alloc] init];
    
    // configuring emogji button
    [self configureEmojiButton];
    
    // subscribing to delegates
    [[QMCore instance].chatService addDelegate:self];
    [QMCore instance].chatService.chatAttachmentService.delegate = self;
    [[QMCore instance].contactListService addDelegate:self];
    self.actionsHandler = self;
    
    @weakify(self);
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        // set up opponent full name
        [self.onlineTitleView setTitle:[[QMCore instance] fullNameForUserID:self.chatDialog.recipientID]];
        BOOL isOpponentOnline = [[QMCore instance] isUserOnline:self.chatDialog.recipientID];
        [self setOpponentOnlineStatus:isOpponentOnline];
        
        // configuring call buttons for opponent
        [self configureCallButtons];
        
        // handling typing status
        [self.chatDialog setOnUserIsTyping:^(NSUInteger userID) {
            @strongify(self);
            if (self.senderID == userID) {
                return;
            }
            
            self.isOpponentTyping = YES;
            [self.onlineTitleView setStatus:NSLocalizedString(@"QM_STR_TYPING", nil)];
        }];
        
        // Handling user stopped typing.
        [self.chatDialog setOnUserStoppedTyping:^(NSUInteger userID) {
            @strongify(self);
            if (self.senderID == userID) {
                return;
            }
            
            self.isOpponentTyping = NO;
            BOOL isOnline = [[QMCore instance] isUserOnline:self.chatDialog.recipientID];
            [self setOpponentOnlineStatus:isOnline];
        }];
    }
    else {
        
        // set up dialog name
        [self.onlineTitleView setTitle:self.chatDialog.name];
        [self.onlineTitleView setStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_GROUP_CHAT_STATUS_STRING", nil), self.chatDialog.occupantIDs.count, 0]];
        [self configureGroupChatAvatar];
        [self updateGroupChatOnlineStatus];
        
        [self.chatDialog setOnJoinOccupant:^(NSUInteger __unused userID) {
            @strongify(self);
            [self updateGroupChatOnlineStatus];
        }];
        
        [self.chatDialog setOnLeaveOccupant:^(NSUInteger __unused userID) {
            @strongify(self);
            [self updateGroupChatOnlineStatus];
        }];
    }
    
    // inserting messages
    if (self.storedMessages.count > 0 && self.chatSectionManager.totalMessagesCount == 0) {
        
        [self.chatSectionManager addMessages:self.storedMessages];
    }
    
    // load messages from cache if needed and from REST
    [self refreshMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [QMCore instance].activeDialogID = self.chatDialog.ID;
    
    @weakify(self);
    self.observerWillResignActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                                                      object:nil
                                                                                       queue:nil
                                                                                  usingBlock:^(NSNotification * _Nonnull __unused note) {
                                                                                      
                                                                                      @strongify(self);
                                                                                      [self stopTyping];
                                                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerWillResignActive];
    
    // Delete blocks.
    [self.chatDialog clearTypingStatusBlocks];
    [self.chatDialog clearDialogOccupantsStatusBlock];
}

#pragma mark - Helpers & Utility

- (NSArray *)storedMessages {
    
    return [[QMCore instance].chatService.messagesMemoryStorage messagesWithDialogID:self.chatDialog.ID];
}

- (void)refreshMessages {
    
    @weakify(self);
    // Retrieving message from Quickblox REST history and cache.
    [[[QMCore instance].chatService messagesWithChatDialogID:self.chatDialog.ID] continueWithBlock:^id _Nullable(BFTask<NSArray<QBChatMessage *> *> * _Nonnull task) {
        @strongify(self);
        
        if ([task.result count] > 0) {
            
            [self.chatSectionManager addMessages:task.result];
        }
        
        return nil;
    }];
}

- (void)readMessage:(QBChatMessage *)message {
    
    if (message.senderID != self.senderID && ![message.readIDs containsObject:@(self.senderID)]) {
        
        [[[QMCore instance].chatService readMessage:message] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            if (task.isFaulted) {
                
                NSLog(@"Problems while marking message as read! Error: %@", task.error);
            }
            else if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                
                [UIApplication sharedApplication].applicationIconBadgeNumber--;
            }
            
            return nil;
        }];
    }
}

- (BOOL)messageSendingAllowed {
    
    if (![QBChat instance].isConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) actionSuccess:NO];
        return NO;
    }
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        if (![[QMCore instance] isFriendWithUserID:self.chatDialog.recipientID]) {
            
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_SEND_MESSAGES", nil) actionSuccess:NO];
            return NO;
        }
        
        if ([[QMCore instance] userIDIsInPendingList:self.chatDialog.recipientID]) {
            
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_SEND_MESSAGES", nil) actionSuccess:NO];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Toolbar actions

- (void)didPressSendButton:(UIButton *)__unused button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    if (self.typingTimer != nil) {
        
        [self stopTyping];
    }
    
    if (![self messageSendingAllowed]) {
        
        return;
    }
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    message.senderNick = senderDisplayName;
    message.markable = YES;
    message.deliveredIDs = @[@(self.senderID)];
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.chatDialog.ID;
    message.dateSent = date;
    
    // Sending message
    [[[QMCore instance].chatService sendMessage:message toDialog:self.chatDialog saveToHistory:YES saveToStorage:YES] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (task.isFaulted) {
            
            [REAlertView showAlertWithMessage:task.error.localizedRecoverySuggestion actionSuccess:NO];
        }
        else {
            
            [QMSoundManager playMessageSentSound];
        }
        
        return nil;
    }];
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)__unused sender {
    
    if (![self messageSendingAllowed]) {
        
        return;
    }
    
    @weakify(self);
    [REActionSheet presentActionSheetInView:self.view configuration:^(REActionSheet *actionSheet) {
        
        @strongify(self);
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil) andActionBlock:^{
            [QMImagePicker takePhotoInViewController:self resultHandler:self];
        }];
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_FROM_LIBRARY", nil) andActionBlock:^{
            [QMImagePicker choosePhotoInViewController:self resultHandler:self];
        }];
        
        [actionSheet addCancelButtonWihtTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{
            
        }];
    }];
}

#pragma mark - Cells view classes

- (Class)viewClassForItem:(QBChatMessage *)item {
    
    if (item.isNotificatonMessage) {
        
        NSUInteger opponentID = self.chatDialog.recipientID;
        BOOL isFriend = [[QMCore instance] isFriendWithUserID:opponentID];
        
        if (item.messageType == QMMessageTypeContactRequest && item.senderID != self.senderID && !isFriend) {
            
            QBChatMessage *lastMessage = [[QMCore instance].chatService.messagesMemoryStorage lastMessageFromDialogID:self.chatDialog.ID];
            if ([lastMessage isEqual:item]) {
                
                return [QMChatContactRequestCell class];
            }
        }
        
        return [QMChatNotificationCell class];
    }
    else {
        
        if (item.senderID != self.senderID) {
            
            if (item.isMediaMessage || item.attachmentStatus != QMMessageAttachmentStatusNotLoaded) {
                
                return [QMChatAttachmentIncomingCell class];
            }
            else {
                
                return [QMChatIncomingCell class];
            }
        }
        else {
            
            if (item.isMediaMessage || item.attachmentStatus != QMMessageAttachmentStatusNotLoaded) {
                
                return [QMChatAttachmentOutgoingCell class];
            }
            else {
                
                return [QMChatOutgoingCell class];
            }
        }
    }
    
    NSAssert(nil, @"Unexpected cell class");
    return nil;
}

#pragma mark - Attributed strings

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    
    NSString *message = nil;
    UIColor *textColor = nil;
    UIFont *font = nil;
    
    if (messageItem.isNotificatonMessage) {
        
        message = [self.messageStatusStringBuilder messageTextForNotification:messageItem];
        
        if (message == nil) {
            // old logic support when update info was plain text
            message = messageItem.text;
        }
        
        Class viewClass = [self viewClassForItem:messageItem];
        if (viewClass == [QMChatContactRequestCell class]) {
            
            textColor = [UIColor blackColor];
            font = [UIFont systemFontOfSize:17.0f];
        }
        else {
            
            textColor = [UIColor whiteColor];
            font = [UIFont systemFontOfSize:13.0f];
        }
    }
    else {
        
        message = messageItem.text;
        textColor = messageItem.senderID == self.senderID ? [UIColor whiteColor] : [UIColor blackColor];
        font = [UIFont systemFontOfSize:16.0f];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8.0f;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor,
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:message != nil ? message : @"" attributes:attributes];
    
    return attributedString;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    if (messageItem.senderID == self.senderID || self.chatDialog.type == QBChatDialogTypePrivate) {
        
        return nil;
    }
    
    UIFont *font = [UIFont systemFontOfSize:15.0f];
    
    QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:messageItem.senderID];
    NSString *topLabelText = [NSString stringWithFormat:@"%@", opponentUser.fullName != nil ? opponentUser.fullName : @(messageItem.senderID)];
    
    // setting the paragraph style lineBreakMode to NSLineBreakByTruncatingTail
    // in order to let TTTAttributedLabel cut the line in a correct way
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:122.0f / 255.0f blue:1.0f alpha:1.000],
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:topLabelText attributes:attributes];
    
    return attributedString;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor colorWithWhite:1 alpha:0.8f] : [UIColor colorWithWhite:0.000 alpha:0.4f];
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    
    NSString* text = messageItem.dateSent ? [QMDateUtils formatDateForTimeRange:messageItem.dateSent] : @"";
    
    if ([messageItem senderID] == self.senderID) {
        text = [NSString stringWithFormat:@"%@\n%@", text, [self.messageStatusStringBuilder statusFromMessage:messageItem forDialogType:self.chatDialog
                                                            .type]];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                         attributes:attributes];
    
    return attributedString;
}

#pragma mark - Collection View Datasource

- (CGSize)collectionView:(QMChatCollectionView *)__unused collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = [self.chatSectionManager messageForIndexPath:indexPath];
    Class viewClass = [self viewClassForItem:item];
    CGSize size = CGSizeZero;
    
    if (viewClass == [QMChatAttachmentIncomingCell class]) {
        
        size = CGSizeMake(MIN(kQMAttachmentCellSize, maxWidth), kQMAttachmentCellSize);
    }
    else if(viewClass == [QMChatAttachmentOutgoingCell class]) {
        
        NSAttributedString *attributedString = [self bottomLabelAttributedStringForItem:item];
        
        CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                                  withConstraints:CGSizeMake(MIN(kQMAttachmentCellSize, maxWidth), CGFLOAT_MAX)
                                                           limitedToNumberOfLines:0];
        size = CGSizeMake(MIN(kQMAttachmentCellSize, maxWidth), kQMAttachmentCellSize + ceil(bottomLabelSize.height));
    }
    else if (viewClass == [QMChatNotificationCell class]) {
        
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    else {
        
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    
    return size;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *item = [self.chatSectionManager messageForIndexPath:indexPath];
    
    CGSize size = CGSizeZero;
    if ([self.detailedCells containsObject:item.ID]) {
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                                withConstraints:CGSizeMake(CGRectGetWidth(collectionView.frame) - kQMWidthPadding, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    
    if (self.chatDialog.type != QBChatDialogTypePrivate) {
        
        CGSize topLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:[self topLabelAttributedStringForItem:item]
                                                               withConstraints:CGSizeMake(CGRectGetWidth(collectionView.frame) - kQMWidthPadding, CGFLOAT_MAX)
                                                        limitedToNumberOfLines:1];
        
        if (topLabelSize.width > size.width) {
            
            size = topLabelSize;
        }
    }
    
    return size.width;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    Class viewClass = [self viewClassForItem:[self.chatSectionManager messageForIndexPath:indexPath]];
    
    // disabling action performing for specific cells
    if (viewClass == [QMChatAttachmentIncomingCell class]
        || viewClass == [QMChatAttachmentOutgoingCell class]
        || viewClass == [QMChatNotificationCell class]
        || viewClass == [QMChatContactRequestCell class]){
        
        return NO;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)__unused collectionView performAction:(SEL)__unused action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)__unused sender {
    
    QBChatMessage* message = [self.chatSectionManager messageForIndexPath:indexPath];
    
    [UIPasteboard generalPasteboard].string = message.text;
}

#pragma mark - QMChatCollectionViewDelegate

- (CGFloat)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)__unused section {
    
    return 8.0f;
}

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    QMChatCellLayoutModel layoutModel = [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
    
    layoutModel.topLabelHeight = 0.0f;
    layoutModel.maxWidthMarginSpace = 20.0f;
    layoutModel.spaceBetweenTextViewAndBottomLabel = 5.0f;
    
    QBChatMessage *item = [self.chatSectionManager messageForIndexPath:indexPath];
    Class class = [self viewClassForItem:item];
    
    if (class == [QMChatOutgoingCell class] ||
        class == [QMChatAttachmentOutgoingCell class]) {
        
        layoutModel.avatarSize = CGSizeZero;
    }
    else if (class == [QMChatAttachmentIncomingCell class] ||
             class == [QMChatIncomingCell class]) {
        
        if (self.chatDialog.type != QBChatDialogTypePrivate) {
            
            NSAttributedString *topLabelString = [self topLabelAttributedStringForItem:item];
            CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:topLabelString
                                                           withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - kQMWidthPadding, CGFLOAT_MAX)
                                                    limitedToNumberOfLines:1];
            layoutModel.topLabelHeight = size.height;
        }
        
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
        layoutModel.avatarSize = CGSizeMake(kQMAvatarSize, kQMAvatarSize);
        
    } else if (class == [QMChatNotificationCell class]) {
        
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
    }
    
    CGSize size = CGSizeZero;
    if ([self.detailedCells containsObject:item.ID] || class == [QMChatAttachmentIncomingCell class] || class == [QMChatAttachmentOutgoingCell class]) {
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                                withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - kQMWidthPadding, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    
    layoutModel.bottomLabelHeight = ceil(size.height);
    
    return layoutModel;
}

- (void)collectionView:(QMChatCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    
    QMChatCell *currentCell = (QMChatCell *)cell;
    
    currentCell.delegate = self;
    currentCell.containerView.highlightColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    if ([cell isKindOfClass:[QMChatOutgoingCell class]] || [cell isKindOfClass:[QMChatAttachmentOutgoingCell class]]) {
        
        currentCell.containerView.bgColor = [UIColor colorWithRed:23.0f / 255.0f green:208.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
    }
    else if ([cell isKindOfClass:[QMChatIncomingCell class]] || [cell isKindOfClass:[QMChatAttachmentIncomingCell class]]) {
        
        currentCell.containerView.bgColor = [UIColor whiteColor];
        
        /**
         *  Setting opponent avatar
         */
        QBChatMessage* message = [self.chatSectionManager messageForIndexPath:indexPath];
        QBUUser *sender = [[QMCore instance].usersService.usersMemoryStorage userWithID:message.senderID];
        
        QMImageView *avatarView = [(QMChatCell *)cell avatarView];
        
        NSURL *userImageUrl = [NSURL URLWithString:sender.avatarUrl];
        UIImage *placeholder = [QMPlaceholder placeholderWithFrame:avatarView.bounds title:sender.fullName ID:sender.ID];
        
        [avatarView setImageWithURL:userImageUrl
                        placeholder:placeholder
                            options:SDWebImageHighPriority
                           progress:nil
                     completedBlock:nil];
        avatarView.imageViewType = QMImageViewTypeCircle;
        
    }
    else if ([cell isKindOfClass:[QMChatNotificationCell class]]) {
        
        currentCell.containerView.bgColor = [UIColor colorWithRed:188.0f/255.0f green:185.0f/255.0f blue:168.0f/255.0f alpha:1.0f];
        currentCell.userInteractionEnabled = NO;
    }
    else if ([cell isKindOfClass:[QMChatContactRequestCell class]]) {
        
        currentCell.containerView.bgColor = [UIColor whiteColor];
        currentCell.layer.cornerRadius = 8;
        currentCell.clipsToBounds = YES;
    }
    
    if ([cell conformsToProtocol:@protocol(QMChatAttachmentCell)]) {
        
        QBChatMessage* message = [self.chatSectionManager messageForIndexPath:indexPath];
        
        if (message.attachments != nil) {
            
            QBChatAttachment* attachment = message.attachments.firstObject;
            
            NSMutableArray* keysToRemove = [NSMutableArray array];
            
            NSEnumerator* enumerator = [self.attachmentCells keyEnumerator];
            NSString* existingAttachmentID = nil;
            while (existingAttachmentID = [enumerator nextObject]) {
                UICollectionViewCell* cachedCell = [self.attachmentCells objectForKey:existingAttachmentID];
                if ([cachedCell isEqual:cell]) {
                    [keysToRemove addObject:existingAttachmentID];
                }
            }
            
            for (NSString* key in keysToRemove) {
                [self.attachmentCells removeObjectForKey:key];
            }
            
            [self.attachmentCells setObject:cell forKey:attachment.ID];
            [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentID:attachment.ID];
            
            @weakify(self);
            // Getting image from chat attachment service.
            [[QMCore instance].chatService.chatAttachmentService getImageForAttachmentMessage:message completion:^(NSError *error, UIImage *image) {
                @strongify(self);
                if ([(UICollectionViewCell<QMChatAttachmentCell> *)cell attachmentID] != attachment.ID) return;
                
                [self.attachmentCells removeObjectForKey:attachment.ID];
                
                if (error != nil) {
                    
#warning need to handle error here after some kind of hud implementation
                }
                else if (image != nil) {
                    
                    [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentImage:image];
                    [cell updateConstraints];
                }
            }];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)__unused cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger lastSection = [collectionView numberOfSections] - 1;
    if (indexPath.section == lastSection && indexPath.item == [collectionView numberOfItemsInSection:lastSection] - 1) {
        // the very first message
        // load more if exists
        @weakify(self);
        // Getting earlier messages for chat dialog identifier.
        [[[QMCore instance].chatService loadEarlierMessagesWithChatDialogID:self.chatDialog.ID] continueWithBlock:^id(BFTask<NSArray<QBChatMessage *> *> *task) {
            @strongify(self);
            if (task.result.count > 0) {
                [self.chatSectionManager addMessages:task.result];
            }
            
            return nil;
        }];
    }
    
    // marking message as read if needed
    QBChatMessage *itemMessage = [self.chatSectionManager messageForIndexPath:indexPath];
    [self readMessage:itemMessage];
}

#pragma mark - Typing status

- (void)stopTyping {
    
    [self.typingTimer invalidate];
    self.typingTimer = nil;
    [self.chatDialog sendUserStoppedTyping];
}

- (void)sendIsTypingStatus {
    
    if (![QBChat instance].isConnected) {
        
        return;
    }
    
    if (self.typingTimer) {
        
        [self.typingTimer invalidate];
        self.typingTimer = nil;
    }
    else {
        
        [self.chatDialog sendUserIsTyping];
    }
    
    self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(stopTyping) userInfo:nil repeats:NO];
}

#pragma mark - Calls

- (void)audioCallAction {
    
#warning TODO: audio call
}

- (void)videoCallAction {
    
#warning TODO: video call
}

#pragma mark - Configuring

- (void)configureCallButtons {
    
    UIButton *audioButton = [QMChatButtonsFactory audioCall];
    [audioButton addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoButton = [QMChatButtonsFactory videoCall];
    [videoButton addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *videoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:videoButton];
    UIBarButtonItem *audioCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    
    [self.navigationItem setRightBarButtonItems:@[videoCallBarButtonItem,  audioCallBarButtonItem] animated:YES];
}

- (void)configureGroupChatAvatar {
    
    // chat avatar
    QMImageView *imageView = [[QMImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                           0.0f,
                                                                           kQMGroupAvatarSize,
                                                                           kQMGroupAvatarSize)];
    imageView.imageViewType = QMImageViewTypeCircle;
    
    UIImage *placeholder = [QMPlaceholder placeholderWithFrame:imageView.bounds title:self.chatDialog.name ID:self.chatDialog.ID.hash];
    NSURL *avatarURL = [NSURL URLWithString:self.chatDialog.photo];
    
    [imageView setImageWithURL:avatarURL
                   placeholder:placeholder
                       options:SDWebImageLowPriority
                      progress:nil
                completedBlock:nil];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)updateGroupChatOnlineStatus {
    
    // chat status string
    @weakify(self);
    [self.chatDialog requestOnlineUsersWithCompletionBlock:^(NSMutableArray<NSNumber *> * _Nullable onlineUsers, NSError * _Nullable __unused error) {
        @strongify(self);
        
        if (error == nil) {
            
            [self.onlineTitleView setStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_GROUP_CHAT_STATUS_STRING", nil), self.chatDialog.occupantIDs.count, onlineUsers.count]];
        }
    }];
}

- (void)setOpponentOnlineStatus:(BOOL)isOnline {
    NSAssert(self.chatDialog.type == QBChatDialogTypePrivate, nil);
    
    NSString *status = nil;
    
    if (isOnline) {
        
        status = NSLocalizedString(@"QM_STR_ONLINE", nil);
    }
    else {
        
        QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:self.chatDialog.recipientID];
        if (opponentUser && opponentUser.lastRequestAt) {
            
            status = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"QM_STR_LAST_SEEN", nil), [QMDateUtils formattedLastSeenString:opponentUser.lastRequestAt withTimePrefix:NSLocalizedString(@"QM_STR_TIME_PREFIX", nil)]];
        }
        else {
            
            status = NSLocalizedString(@"QM_STR_OFFLINE", nil);
        }
    }
    
    [self.onlineTitleView setStatus:status];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didLoadMessagesFromCache:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        [self.chatSectionManager addMessages:messages];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        // Inserting message received from XMPP or sent by self
        [self.chatSectionManager addMessage:message];
        
        if (message.dialogUpdateType == QMDialogUpdateTypeOccupants && message.addedOccupantsIDs.count > 0) {
            @weakify(self);
            [[[QMCore instance].usersService getUsersWithIDs:message.addedOccupantsIDs] continueWithBlock:^id(BFTask<NSArray<QBUUser *> *> *__unused task) {
                @strongify(self);
                [self.chatSectionManager updateMessage:message];
                
                return nil;
            }];
        }
    }
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if (self.chatDialog.type != QBChatDialogTypePrivate && [self.chatDialog.ID isEqualToString:chatDialog.ID]) {
        
        [self.onlineTitleView setTitle:self.chatDialog.name];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID
{
    if ([self.chatDialog.ID isEqualToString:dialogID] && message.senderID == self.senderID) {
        // self-sending attachments
        [self.chatSectionManager updateMessage:message];
    }
}

#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)__unused chatService {
    
    [self refreshMessages];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)__unused chatService {
    
    [self refreshMessages];
}

#pragma mark - QMChatAttachmentServiceDelegate

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message {
    
    if (status != QMMessageAttachmentStatusNotLoaded && [message.dialogID isEqualToString:self.chatDialog.ID]) {
        
        [self.chatSectionManager updateMessage:message];
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forChatAttachment:(QBChatAttachment *)attachment {
    
    UICollectionViewCell<QMChatAttachmentCell>* cell = [self.attachmentCells objectForKey:attachment.ID];
    
    if (cell != nil) {
        
        [cell updateLoadingProgress:progress];
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)__unused chatAttachmentService didChangeUploadingProgress:(CGFloat)progress forMessage:(QBChatMessage *)message {
    
    UICollectionViewCell<QMChatAttachmentCell>* cell = [self.attachmentCells objectForKey:message.ID];
    
    if (cell == nil && progress < 1.0f) {
        
        NSIndexPath *indexPath = [self.chatSectionManager indexPathForMessage:message];
        cell = (UICollectionViewCell <QMChatAttachmentCell> *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self.attachmentCells setObject:cell forKey:message.ID];
    }
    
    if (cell != nil) {
        
        [cell updateLoadingProgress:progress];
    }
}

#pragma mark Contact List Serice Delegate

- (void)contactListService:(QMContactListService *)__unused contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)__unused status {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate && self.chatDialog.recipientID == (NSInteger)userID && !self.isOpponentTyping) {
        
        [self setOpponentOnlineStatus:isOnline];
    }
}

#pragma mark QMChatActionsHandler protocol

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender {
#warning implement some kind of notification (not progress hud) for user
    
    if (self.contactRequestTask) {
        // task in progress
        return;
    }
    
    
    QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:self.chatDialog.recipientID];
    
    if (accept) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        QBChatMessage *currentMessage = [self.chatSectionManager messageForIndexPath:indexPath];
        
        @weakify(self);
        self.contactRequestTask = [[[QMCore instance] confirmAddContactRequest:opponentUser] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
            @strongify(self);
            // success block only
            [self.chatSectionManager updateMessage:currentMessage];
            
            return nil;
        }];
    }
    else {
        
        @weakify(self);
        self.contactRequestTask = [[[[QMCore instance] rejectAddContactRequest:opponentUser] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
            
            return [[QMCore instance].chatService deleteDialogWithID:self.chatDialog.ID];
        }] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
            
            return nil;
        }];
    }
}

#pragma mark QMChatCellDelegate

- (void)chatCellDidTapContainer:(QMChatCell *)cell {
    
    if ([cell conformsToProtocol:@protocol(QMChatAttachmentCell)]) {
        
        UIImage *attachmentImage = [(QMChatAttachmentIncomingCell *)cell attachmentImageView].image;
        
        if (attachmentImage != nil) {
#warning need to implement self photo browser
            //            IDMPhoto *photo = [IDMPhoto photoWithImage:attachmentImage];
            //            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
            //            [self presentViewController:browser animated:YES completion:nil];
        }
    }
    else if ([cell isKindOfClass:[QMChatOutgoingCell class]] || [cell isKindOfClass:[QMChatIncomingCell class]]) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        QBChatMessage *currentMessage = [self.chatSectionManager messageForIndexPath:indexPath];
        
        if ([self.detailedCells containsObject:currentMessage.ID]) {
            
            [self.detailedCells removeObject:currentMessage.ID];
        }
        else {
            
            [self.detailedCells addObject:currentMessage.ID];
        }
        
        [self.collectionView.collectionViewLayout removeSizeFromCacheForItemID:currentMessage.ID];
        [self.collectionView performBatchUpdates:nil completion:nil];
    }
}

- (void)__unused chatCellDidTapAvatar:(QMChatCell *)__unused cell {
}

- (void)__unused chatCell:(QMChatCell *)__unused cell didTapAtPosition:(CGPoint)__unused position {
}

- (void)__unused chatCell:(QMChatCell *)__unused cell didPerformAction:(SEL)__unused action withSender:(id)__unused sender {
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)__unused textView shouldChangeTextInRange:(NSRange)__unused range replacementText:(NSString *)__unused text {
    
    [self sendIsTypingStatus];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [super textViewDidEndEditing:textView];
    
    [self stopTyping];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePicker:(QMImagePicker *)imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    QBChatMessage* message = [QBChatMessage new];
    message.senderID = self.senderID;
    message.dialogID = self.chatDialog.ID;
    message.dateSent = [NSDate date];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        UIImage* newImage = photo;
        if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            newImage = [newImage fixOrientation];
        }
        
        UIImage *resizedImage = [self resizedImageFromImage:newImage];
        
        // Sending attachment to dialog.
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[QMCore instance].chatService sendAttachmentMessage:message
                                                         toDialog:self.chatDialog
                                              withAttachmentImage:resizedImage] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                //
                [self.attachmentCells removeObjectForKey:message.ID];
                if (task.isFaulted) {
#warning need to implement error showing
                    
                    // perform local attachment deleting
                    [[QMCore instance].chatService deleteMessageLocally:message];
                    [self.chatSectionManager deleteMessage:message];
                }
                return nil;
            }];
        });
    });
}

- (UIImage *)resizedImageFromImage:(UIImage *)image
{
    CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
    CGFloat scaleCoefficient = largestSide / 560.0f;
    CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

#pragma mark - Emoji

- (void)configureEmojiButton {
    // init
    UIButton *emojiButton = [QMChatButtonsFactory emojiButton];
    emojiButton.tag = kQMEmojiButtonTag;
    [emojiButton addTarget:self action:@selector(showEmojiKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    // appearance
    emojiButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputToolbar.contentView addSubview:emojiButton];
    
    CGFloat emojiButtonSpacing = kQMEmojiButtonSize/3.0f;
    
    [self.inputToolbar.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emojiButton(==size)]|"
                                                                                          options:0
                                                                                          metrics:@{@"size" : @(kQMEmojiButtonSize)}
                                                                                            views:@{@"emojiButton" : emojiButton}]];
    [self.inputToolbar.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[emojiButton]-spacing-[rightBarButton]"
                                                                                          options:0
                                                                                          metrics:@{@"spacing" : @(emojiButtonSpacing)}
                                                                                            views:@{@"emojiButton"    : emojiButton,
                                                                                                    @"rightBarButton" : self.inputToolbar.contentView.rightBarButtonItem}]];
    
    // changing textContainerInset to restrict text entering on emoji button
    self.inputToolbar.contentView.textView.textContainerInset = UIEdgeInsetsMake(self.inputToolbar.contentView.textView.textContainerInset.top,
                                                                                 self.inputToolbar.contentView.textView.textContainerInset.left,
                                                                                 self.inputToolbar.contentView.textView.textContainerInset.bottom,
                                                                                 kQMInputToolbarTextContainerInsetRight);
}

- (void)showEmojiKeyboard {
    
    if ([self.inputToolbar.contentView.textView.inputView isKindOfClass:[AGEmojiKeyboardView class]]) {
        
        UIButton *emojiButton = (UIButton *)[self.inputToolbar.contentView viewWithTag:kQMEmojiButtonTag];
        [emojiButton setImage:[UIImage imageNamed:@"ic_smile"] forState:UIControlStateNormal];
        
        self.inputToolbar.contentView.textView.inputView = nil;
        [self.inputToolbar.contentView.textView reloadInputViews];
        
        [self scrollToBottomAnimated:YES];
        
    } else {
        
        UIButton *emojiButton = (UIButton *)[self.inputToolbar.contentView viewWithTag:kQMEmojiButtonTag];
        [emojiButton setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
        
        AGEmojiKeyboardView *emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
        emojiKeyboardView.tintColor = [UIColor colorWithRed:0.678 green:0.762 blue:0.752 alpha:1.000];
        
        self.inputToolbar.contentView.textView.inputView = emojiKeyboardView;
        [self.inputToolbar.contentView.textView reloadInputViews];
        [self.inputToolbar.contentView.textView becomeFirstResponder];
    }
}

- (NSArray *)sectionsImages {
    return @[@"😊", @"😊", @"🎍", @"🐶", @"🏠", @"🕘", @"Back"];
}

- (UIImage *)randomImage:(NSInteger)categoryImage {
    
    CGSize size = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[UIFont systemFontOfSize:27] forKey:NSFontAttributeName];
    NSString * sectionImage = self.sectionsImages[categoryImage];
    [sectionImage drawInRect:CGRectMake(0, 0, 30, 30) withAttributes:attributes];
    
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


#pragma mark - Emoji Data source

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)__unused emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage:category];
    
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)__unused emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage:category];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)__unused emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"keyboard_icon"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - Emoji Delegate

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)__unused emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    
    NSString *textViewString = self.inputToolbar.contentView.textView.text;
    self.inputToolbar.contentView.textView.text = [textViewString stringByAppendingString:emoji];
    [self textViewDidChange:self.inputToolbar.contentView.textView];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)__unused emojiKeyBoardView {
    
    self.inputToolbar.contentView.textView.inputView = nil;
    [self.inputToolbar.contentView.textView reloadInputViews];
    
    UIButton *emojiButton = (UIButton *)[self.inputToolbar.contentView viewWithTag:kQMEmojiButtonTag];
    [emojiButton setImage:[UIImage imageNamed:@"ic_smile"] forState:UIControlStateNormal];
    
    [self scrollToBottomAnimated:YES];
}

#pragma mark - Transition size

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    [self.onlineTitleView sizeToFit];
}

@end
