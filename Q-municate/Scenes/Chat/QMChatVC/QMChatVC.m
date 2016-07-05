//
//  QMChatVC.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/9/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatVC.h"
#import "QMCore.h"
#import "UINavigationController+QMNotification.h"
#import "QMMessageStatusStringBuilder.h"
#import "QMPlaceholder.h"
#import "QMSoundManager.h"
#import "QMImagePicker.h"
#import "QMOnlineTitleView.h"
#import "QMColors.h"
#import "QMUserInfoViewController.h"
#import "QMGroupInfoViewController.h"
#import "QMAlert.h"
#import "QMPhoto.h"

// helpers
#import "QMChatButtonsFactory.h"
#import "UIImage+fixOrientation.h"
#import "QBChatDialog+OpponentID.h"
#import <QMDateUtils.h>

// Location
#import "QMLocationViewController.h"
#import "QMChatLocationOutgoingCell.h"
#import "QMChatLocationIncomingCell.h"

// external
#import <NYTPhotoViewer/NYTPhotosViewController.h>

@import SafariServices;

static const CGFloat kQMAttachmentCellSize = 200.0f;
static const CGFloat kQMWidthPadding = 40.0f;
static const CGFloat kQMAvatarSize = 28.0f;
static const CGFloat kQMGroupAvatarSize = 30.0f;

@interface QMChatVC ()

<
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMChatAttachmentServiceDelegate,
QMContactListServiceDelegate,

QMChatActionsHandler,
QMChatCellDelegate,

QMImagePickerResultHandler,
QMImageViewDelegate,

NYTPhotosViewControllerDelegate
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

/**
 *  Group avatar image view
 */
@property (strong, nonatomic) QMImageView *groupAvatarImageView;

/**
 *  Reference view for attachment photo.
 */
@property (weak, nonatomic) UIView *photoReferenceView;

@end

@implementation QMChatVC

@dynamic storedMessages;

#pragma mark - Static methods

+ (instancetype)chatViewControllerWithChatDialog:(QBChatDialog *)chatDialog {
    
    QMChatVC *chatVC = [[UIStoryboard storyboardWithName:kQMChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    chatVC.chatDialog = chatDialog;
    
    return chatVC;
}

#pragma mark - QMChatViewController data source overrides

- (NSUInteger)senderID {
    
    return [QMCore instance].currentProfile.userData.ID;
}

- (NSString *)senderDisplayName {
    
    QBUUser *currentUser = [QMCore instance].currentProfile.userData;
    
    return currentUser.fullName ?: [NSString stringWithFormat:@"%tu", currentUser.ID];
}

- (CGFloat)heightForSectionHeader {
    
    return 40.0f;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    
    // setting up chat controller
    self.topContentAdditionalInset = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.collectionView.backgroundColor = QMChatBackgroundColor();
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"QM_STR_INPUTTOOLBAR_PLACEHOLDER", nil);
    
    // setting up properties
    self.detailedCells = [NSMutableSet set];
    self.attachmentCells = [NSMapTable strongToWeakObjectsMapTable];
    self.messageStatusStringBuilder = [[QMMessageStatusStringBuilder alloc] init];
    
    // subscribing to delegates
    [[QMCore instance].chatService addDelegate:self];
    [QMCore instance].chatService.chatAttachmentService.delegate = self;
    [[QMCore instance].contactListService addDelegate:self];
    self.actionsHandler = self;
    
    // text checking types for cells
    self.enableTextCheckingTypes = (NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber);
    
    @weakify(self);
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        // set up opponent full name
        [self.onlineTitleView setTitle:[[QMCore instance].contactManager fullNameForUserID:[self.chatDialog opponentID]]];
        BOOL isOpponentOnline = [[QMCore instance].contactManager isUserOnlineWithID:[self.chatDialog opponentID]];
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
            BOOL isOnline = [[QMCore instance].contactManager isUserOnlineWithID:[self.chatDialog opponentID]];
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
    
    [QMCore instance].activeDialogID = nil;
    
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
    [[[QMCore instance].chatService messagesWithChatDialogID:self.chatDialog.ID] continueWithSuccessBlock:^id _Nullable(BFTask<NSArray<QBChatMessage *> *> * _Nonnull task) {
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
                
                ILog(@"Problems while marking message as read! Error: %@", task.error);
            }
            else if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                
                [UIApplication sharedApplication].applicationIconBadgeNumber--;
            }
            
            return nil;
        }];
    }
}

- (BOOL)connectionExists {
    
    if (![[QMCore instance] isInternetConnected]) {
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
        return NO;
    }
    
    if (![QBChat instance].isConnected) {
        
        if ([QMCore instance].chatService.chatConnectionState == QMChatConnectionStateConnecting) {
            
            [self.navigationController shake];
        }
        else {
            
            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) actionSuccess:NO inViewController:self];
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)messageSendingAllowed {
    
    if (![self connectionExists]) {
        
        return NO;
    }
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        if (![[QMCore instance].contactManager isFriendWithUserID:[self.chatDialog opponentID]]) {
            
            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_SEND_MESSAGES", nil) actionSuccess:NO inViewController:self];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)callsAllowed {
    
    if (![self connectionExists]) {
        
        return NO;
    }
    
    if (![[QMCore instance].contactManager isFriendWithUserID:[self.chatDialog opponentID]]) {
        
        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO inViewController:self];
        return NO;
    }
    
    return YES;
}

#pragma mark - Toolbar actions

- (void)didPressSendButton:(UIButton *)__unused button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)__unused senderDisplayName
                      date:(NSDate *)date {
    
    if (self.typingTimer != nil) {
        
        [self stopTyping];
    }
    
    if (![self messageSendingAllowed]) {
        
        return;
    }
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    message.markable = YES;
    message.deliveredIDs = @[@(self.senderID)];
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.chatDialog.ID;
    message.dateSent = date;
    
    // Sending message
    @weakify(self);
    [[[QMCore instance].chatService sendMessage:message toDialog:self.chatDialog saveToHistory:YES saveToStorage:YES] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        @strongify(self);
        if (task.isFaulted) {
            
            [QMAlert showAlertWithMessage:task.error.localizedRecoverySuggestion actionSuccess:NO inViewController:self];
        }
        else {
            
            [QMSoundManager playMessageSentSound];
        }
        
        return nil;
    }];
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    
    if (![self messageSendingAllowed]) {
        
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker takePhotoInViewController:self resultHandler:self allowsEditing:NO];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker choosePhotoInViewController:self resultHandler:self allowsEditing:NO];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOCATION", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          QMLocationViewController *locationVC = [[QMLocationViewController alloc] initWithState:QMLocationVCStateSend];
                                                          
                                                          [locationVC setSendButtonPressed:^(CLLocationCoordinate2D centerCoordinate) {
                                                              
                                                              [self _sendLocationMessage:centerCoordinate];
                                                          }];
                                                          
                                                          UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:locationVC];
                                                          
                                                          [self presentViewController:navController animated:YES completion:nil];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = sender;
        alertController.popoverPresentationController.sourceRect = sender.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Cells view classes

- (Class)viewClassForItem:(QBChatMessage *)item {
    
    if ([item isNotificatonMessage]) {
        
        NSUInteger opponentID = [self.chatDialog opponentID];
        BOOL isFriend = [[QMCore instance].contactManager isFriendWithUserID:opponentID];
        
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
            
            if ([item isMediaMessage] && item.attachmentStatus != QMMessageAttachmentStatusError) {
                
                return [QMChatAttachmentIncomingCell class];
            }
            else {
                
                return [QMChatIncomingCell class];
            }
        }
        else {
            
            if ([item isMediaMessage] && item.attachmentStatus != QMMessageAttachmentStatusError) {
                
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
    
    if ([messageItem isNotificatonMessage]) {
        
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
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:message ?: @"" attributes:attributes];
    
    return attributedString;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    if (messageItem.senderID == self.senderID || self.chatDialog.type == QBChatDialogTypePrivate) {
        
        return nil;
    }
    
    UIFont *font = [UIFont systemFontOfSize:15.0f];
    
    QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:messageItem.senderID];
    NSString *topLabelText = [NSString stringWithFormat:@"%@", opponentUser.fullName ?: @(messageItem.senderID)];
    
    // setting the paragraph style lineBreakMode to NSLineBreakByTruncatingTail
    // in order to let TTTAttributedLabel cut the line in a correct way
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:QMChatTopLabelColor(),
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:topLabelText attributes:attributes];
    
    return attributedString;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = messageItem.senderID == self.senderID ? QMChatOutgoingBottomLabelColor() : QMChatIncomingBottomLabelColor();
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    
    NSString* text = messageItem.dateSent ? [QMDateUtils formatDateForTimeRange:messageItem.dateSent] : @"";
    
    if (messageItem.senderID == self.senderID) {
        text = [NSString stringWithFormat:@"%@\n%@", text, [self.messageStatusStringBuilder statusFromMessage:messageItem forDialogType:self.chatDialog.type]];
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
    
    if (viewClass == [QMChatAttachmentIncomingCell class]
        || viewClass == [QMChatLocationIncomingCell class]) {
        
        size = CGSizeMake(MIN(kQMAttachmentCellSize, maxWidth), kQMAttachmentCellSize);
    }
    else if (viewClass == [QMChatAttachmentOutgoingCell class]
             || viewClass == [QMChatLocationOutgoingCell class]) {
        
        NSAttributedString *attributedString = [self bottomLabelAttributedStringForItem:item];
        
        CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                                  withConstraints:CGSizeMake(MIN(kQMAttachmentCellSize, maxWidth), CGFLOAT_MAX)
                                                           limitedToNumberOfLines:0];
        size = CGSizeMake(MIN(kQMAttachmentCellSize, maxWidth), kQMAttachmentCellSize + (CGFloat)ceil(bottomLabelSize.height));
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
        || viewClass == [QMChatLocationIncomingCell class]
        || viewClass == [QMChatLocationOutgoingCell class]
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
        class == [QMChatAttachmentOutgoingCell class] ||
        class == [QMChatLocationOutgoingCell class]) {
        
        layoutModel.avatarSize = CGSizeZero;
    }
    else if (class == [QMChatAttachmentIncomingCell class] ||
             class == [QMChatLocationIncomingCell class] ||
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
        
    }
    else if (class == [QMChatNotificationCell class]) {
        
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
    }
    
    CGSize size = CGSizeZero;
    if ([self.detailedCells containsObject:item.ID]
        || class == [QMChatAttachmentIncomingCell class]
        || class == [QMChatAttachmentOutgoingCell class]
        || class == [QMChatLocationIncomingCell class]
        || class == [QMChatLocationOutgoingCell class]) {
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                                withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - kQMWidthPadding, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    
    layoutModel.bottomLabelHeight = ceil(size.height);
    
    return layoutModel;
}

- (void)collectionView:(QMChatCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    [super collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    
    QMChatCell *currentCell = (QMChatCell *)cell;
    
    currentCell.delegate = self;
    currentCell.containerView.highlightColor = QMChatCellHighlightedColor();
    
    if ([cell isKindOfClass:[QMChatOutgoingCell class]]
        || [cell isKindOfClass:[QMChatAttachmentOutgoingCell class]]
        || [cell isKindOfClass:[QMChatLocationOutgoingCell class]]) {
        
        currentCell.containerView.bgColor = QMChatOutgoingCellColor();
        currentCell.textView.linkAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                NSUnderlineStyleAttributeName : @(YES)};
    }
    else if ([cell isKindOfClass:[QMChatIncomingCell class]]
             || [cell isKindOfClass:[QMChatAttachmentIncomingCell class]]
             || [cell isKindOfClass:[QMChatLocationIncomingCell class]]) {
        
        currentCell.containerView.bgColor = [UIColor whiteColor];
        currentCell.textView.linkAttributes = @{NSForegroundColorAttributeName : QMChatIncomingLinkColor(),
                                                NSUnderlineStyleAttributeName : @(YES)};
        
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
        
        currentCell.containerView.bgColor = QMChatNotificationCellColor();
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
                    
                    [self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:error.localizedRecoverySuggestion duration:kQMDefaultNotificationDismissTime];
                }
                else if (image != nil) {
                    
                    [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentImage:image];
                    [cell updateConstraints];
                }
            }];
        }
    }
    else if ([cell conformsToProtocol:@protocol(QMChatLocationCell)]) {
        
        // test data
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
    
    // getting users if needed
    QBUUser *sender = [[QMCore instance].usersService.usersMemoryStorage userWithID:itemMessage.senderID];
    if (sender == nil) {
        
        @weakify(self);
        [[[QMCore instance].usersService getUserWithID:itemMessage.senderID] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
            
            @strongify(self);
            [self.chatSectionManager updateMessage:itemMessage];
            
            return nil;
        }];
    }
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

#pragma mark - Actions

- (void)performInfoViewControllerForUserID:(NSUInteger)userID {
    
    QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:userID];
    
    if (opponentUser == nil) {
        
        opponentUser = [QBUUser user];
        opponentUser.ID = userID;
        opponentUser.fullName = NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil);
    }
    
    [self performSegueWithIdentifier:kQMSceneSegueUserInfo sender:opponentUser];
}

- (IBAction)onlineTitlePressed {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        [self performInfoViewControllerForUserID:[self.chatDialog opponentID]];
    }
    else {
        
        [self performSegueWithIdentifier:KQMSceneSegueGroupInfo sender:self.chatDialog];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // hiding keyboard due to layouting issue for iOS 8
    // if interface orientation would change out of the controller
    [self.view endEditing:YES];
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUserInfo]) {
        
        QMUserInfoViewController *userInfoVC = segue.destinationViewController;
        userInfoVC.user = sender;
    }
    else if ([segue.identifier isEqualToString:KQMSceneSegueGroupInfo]) {
        
        QMGroupInfoViewController *groupInfoVC = segue.destinationViewController;
        groupInfoVC.chatDialog = sender;
    }
}

- (void)audioCallAction {
    
    if (![self callsAllowed]) {
        
        return;
    }
    
    [[QMCore instance].callManager callToUserWithID:[self.chatDialog opponentID] conferenceType:QBRTCConferenceTypeAudio];
}

- (void)videoCallAction {
    
    if (![self callsAllowed]) {
        
        return;
    }
    
    [[QMCore instance].callManager callToUserWithID:[self.chatDialog opponentID] conferenceType:QBRTCConferenceTypeVideo];
}

- (void)_sendLocationMessage:(CLLocationCoordinate2D)__unused locationCoordinate {
    
#warning TODO: send map message with coordinates
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
    self.groupAvatarImageView = [[QMImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                              0.0f,
                                                                              kQMGroupAvatarSize,
                                                                              kQMGroupAvatarSize)];
    self.groupAvatarImageView.imageViewType = QMImageViewTypeCircle;
    self.groupAvatarImageView.delegate = self;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.groupAvatarImageView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self updateGroupAvatarImage];
}

- (void)updateGroupAvatarImage {
    
    UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.groupAvatarImageView.bounds title:self.chatDialog.name ID:self.chatDialog.ID.hash];
    NSURL *avatarURL = [NSURL URLWithString:self.chatDialog.photo];
    
    [self.groupAvatarImageView setImageWithURL:avatarURL
                                   placeholder:placeholder
                                       options:SDWebImageLowPriority
                                      progress:nil
                                completedBlock:nil];
}

- (void)updateGroupChatOnlineStatus {
    
    // chat status string
    @weakify(self);
    [self.chatDialog requestOnlineUsersWithCompletionBlock:^(NSMutableArray<NSNumber *> * _Nullable onlineUsers, NSError * _Nullable error) {
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
        
        QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:[self.chatDialog opponentID]];
        if (opponentUser && opponentUser.lastRequestAt) {
            
            status = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"QM_STR_LAST_SEEN", nil), [QMDateUtils formattedLastSeenString:opponentUser.lastRequestAt withTimePrefix:NSLocalizedString(@"QM_STR_TIME_PREFIX", nil)]];
        }
        else {
            
            status = NSLocalizedString(@"QM_STR_OFFLINE", nil);
        }
    }
    
    [self.onlineTitleView setStatus:status];
}

#pragma mark - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)__unused imageView {
    
    [self performSegueWithIdentifier:KQMSceneSegueGroupInfo sender:self.chatDialog];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didLoadMessagesFromCache:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        [self.chatSectionManager addMessages:messages];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        if (message.messageType == QMMessageTypeDeleteContactRequest) {
            // check whether contact request message was sent previously
            // in order to reload it and remove buttons for accept and deny
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
            QBChatMessage *lastMessage = [self.chatSectionManager messageForIndexPath:indexPath];
            if (lastMessage.messageType == QMMessageTypeContactRequest) {
                
                [self.chatSectionManager updateMessage:lastMessage];
            }
        }
        
        // Inserting message received from XMPP or sent by self
        [self.chatSectionManager addMessage:message];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if (self.chatDialog.type != QBChatDialogTypePrivate && [self.chatDialog.ID isEqualToString:chatDialog.ID]) {
        
        [self.onlineTitleView setTitle:self.chatDialog.name];
        [self updateGroupChatOnlineStatus];
        [self updateGroupAvatarImage];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didAddChatDialogsToMemoryStorage:(NSArray<QBChatDialog *> *)chatDialogs {
    
    if (self.chatDialog.type != QBChatDialogTypePrivate && [chatDialogs containsObject:self.chatDialog]) {
        
        [self.onlineTitleView setTitle:self.chatDialog.name];
        [self updateGroupAvatarImage];
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
    
    if (self.chatDialog.type == QBChatDialogTypePrivate && [self.chatDialog opponentID] == userID && !self.isOpponentTyping) {
        
        [self setOpponentOnlineStatus:isOnline];
    }
}

#pragma mark QMChatActionsHandler protocol

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender {
    
    if (self.contactRequestTask) {
        // task in progress
        return;
    }
    
    QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:[self.chatDialog opponentID]];
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    if (accept) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        QBChatMessage *currentMessage = [self.chatSectionManager messageForIndexPath:indexPath];
        
        __weak UINavigationController *navigationController = self.navigationController;
        
        @weakify(self);
        self.contactRequestTask = [[[QMCore instance].contactManager addUserToContactList:opponentUser] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            @strongify(self);
            [navigationController dismissNotificationPanel];
            
            if (!task.isFaulted) {
                
                [self.chatSectionManager updateMessage:currentMessage];
            }
            
            return nil;
        }];
    }
    else {
        
        __weak UINavigationController *navigationController = self.navigationController;
        
        @weakify(self);
        self.contactRequestTask = [[[[QMCore instance].contactManager rejectAddContactRequest:opponentUser] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            if (!task.isFaulted) {
                
                return [[QMCore instance].chatService deleteDialogWithID:self.chatDialog.ID];
            }
            
            return [BFTask cancelledTask];
            
        }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            @strongify(self);
            [navigationController dismissNotificationPanel];
            
            if (!task.isCancelled && !task.isFaulted) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            return nil;
        }];
    }
}

#pragma mark QMChatCellDelegate

- (void)chatCellDidTapContainer:(QMChatCell *)cell {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    QBChatMessage *currentMessage = [self.chatSectionManager messageForIndexPath:indexPath];
    
    if ([cell conformsToProtocol:@protocol(QMChatAttachmentCell)]) {
        
        UIImage *attachmentImage = [(QMChatAttachmentIncomingCell *)cell attachmentImageView].image;
        
        if (attachmentImage != nil) {
            
            QBUUser *sender = [[QMCore instance].usersService.usersMemoryStorage userWithID:currentMessage.senderID];
            
            QMPhoto *photo = [[QMPhoto alloc] init];
            photo.image = attachmentImage;
            
            NSString *title = sender.fullName ?: [NSString stringWithFormat:@"%tu", sender.ID];
            photo.attributedCaptionTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
            
            photo.attributedCaptionSummary = [[NSAttributedString alloc] initWithString:[QMDateUtils formatDateForTimeRange:currentMessage.dateSent] attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]}];
            
            self.photoReferenceView = [(QMChatAttachmentIncomingCell *)cell attachmentImageView];
            
            NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
            photosViewController.delegate = self;
            
            [self.view endEditing:YES]; // hiding keyboard
            [self presentViewController:photosViewController animated:YES completion:nil];
        }
    }
    else if ([cell conformsToProtocol:@protocol(QMChatLocationCell)]) {
        
        QMLocationViewController *locationVC = [[QMLocationViewController alloc] initWithState:QMLocationVCStateView locationCoordinate:[(id<QMChatLocationCell>)cell locationCoordinate]];
        
        [self.view endEditing:YES]; // hiding keyboard
        [self.navigationController pushViewController:locationVC animated:YES];
    }
    else if ([cell isKindOfClass:[QMChatOutgoingCell class]] || [cell isKindOfClass:[QMChatIncomingCell class]]) {
        
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

- (void)chatCellDidTapAvatar:(QMChatCell *)cell {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        [self performInfoViewControllerForUserID:[self.chatDialog opponentID]];
    }
    else {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        QBChatMessage *chatMessage = [self.chatSectionManager messageForIndexPath:indexPath];
        
        [self performInfoViewControllerForUserID:chatMessage.senderID];
    }
}

- (void)chatCell:(QMChatCell *)__unused cell didTapOnTextCheckingResult:(NSTextCheckingResult *)textCheckingResult {
    
    switch (textCheckingResult.resultType) {
            
        case NSTextCheckingTypeLink: {
            
            if ([SFSafariViewController class] != nil
                // SFSafariViewController supporting only http and https schemes
                && ([textCheckingResult.URL.scheme.lowercaseString isEqualToString:@"http"]
                    || [textCheckingResult.URL.scheme.lowercaseString isEqualToString:@"https"])) {
                    
                    SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:textCheckingResult.URL entersReaderIfAvailable:false];
                    [self presentViewController:controller animated:true completion:nil];
                }
            else {
                
                [[UIApplication sharedApplication] openURL:textCheckingResult.URL];
            }
            
            break;
        }
            
        case NSTextCheckingTypePhoneNumber: {
            
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:nil
                                                  message:textCheckingResult.phoneNumber
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull __unused action) {
                                                              }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CALL", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull __unused action) {
                                                                  
                                                                  NSString *urlString = [NSString stringWithFormat:@"tel:%@", textCheckingResult.phoneNumber];
                                                                  NSURL *url = [NSURL URLWithString:urlString];
                                                                  [[UIApplication sharedApplication] openURL:url];
                                                                  
                                                              }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.photoReferenceView;
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
    
    if (![[QMCore instance] isInternetConnected]) {
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
        return;
    }
    
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
                
                [self.attachmentCells removeObjectForKey:message.ID];
                if (task.isFaulted) {
                    
                    [self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:task.error.localizedRecoverySuggestion duration:kQMDefaultNotificationDismissTime];
                    
                    // perform local attachment deleting
                    [[QMCore instance].chatService deleteMessageLocally:message];
                    [self.chatSectionManager deleteMessage:message];
                }
                return nil;
            }];
        });
    });
}

- (UIImage *)resizedImageFromImage:(UIImage *)image {
    
    CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
    CGFloat scaleCoefficient = largestSide / 560.0f;
    CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

#pragma mark - Transition size

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    @weakify(self);
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull __unused context) {
        
        @strongify(self);
        self.topContentAdditionalInset = 0;
        [self.onlineTitleView sizeToFit];
        
    } completion:nil];
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

#pragma mark - Nibs registration

- (void)registerNibs {
    
    /**
     *  Location outgoing cell
     */
    UINib *locOutgoingNib = [QMChatLocationOutgoingCell nib];
    NSString *locOugoingIdentifier = [QMChatLocationOutgoingCell cellReuseIdentifier];
    [self.collectionView registerNib:locOutgoingNib forCellWithReuseIdentifier:locOugoingIdentifier];
    
    /**
     *  Location incoming cell
     */
    UINib *locIncomingNib = [QMChatLocationIncomingCell nib];
    NSString *locIncomingIdentifier = [QMChatLocationIncomingCell cellReuseIdentifier];
    [self.collectionView registerNib:locIncomingNib forCellWithReuseIdentifier:locIncomingIdentifier];
}

@end
