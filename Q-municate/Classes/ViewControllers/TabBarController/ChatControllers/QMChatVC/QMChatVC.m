//
//  QMChatVC.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMChatVC.h"
#import "QMMainTabBarController.h"
#import "QMGroupDetailsController.h"
#import "QMBaseCallsController.h"
#import "QMMessageBarStyleSheetFactory.h"
#import "QMApi.h"
#import "QMAlertsFactory.h"
#import "QMOnlineTitle.h"
#import "IDMPhotoBrowser.h"
#import "QMAudioCallController.h"
#import "QMVideoCallController.h"
#import "QMPlaceholderTextView.h"
#import "REAlertView+QMSuccess.h"
#import <SVProgressHUD.h>
#import "QMChatUtils.h"
#import "QMUsersUtils.h"
#import "QMImageView.h"
#import "QMSettingsManager.h"
#import "AGEmojiKeyBoardView.h"
#import "UIImage+fixOrientation.h"

// chat controller
#import "UIImage+QM.h"
#import "UIColor+QM.h"
#import <TTTAttributedLabel.h>
#import "QMChatAttachmentIncomingCell.h"
#import "QMChatAttachmentOutgoingCell.h"
#import "QMChatAttachmentCell.h"
#import "QMCollectionViewFlowLayoutInvalidationContext.h"
#import "QMMessageStatusStringBuilder.h"
#import "QMChatButtonsFactory.h"

static const NSUInteger widthPadding                         = 40.0f;
static const CGFloat kQMEmojiButtonSize                      = 45.0f;
static const NSInteger kQMEmojiButtonTag                     = 100;
static const CGFloat kQMInputToolbarTextContainerInsetRight  = 25.0f;

@interface QMChatVC ()
<
AGEmojiKeyboardViewDataSource,
AGEmojiKeyboardViewDelegate
>

@property (strong, nonatomic) QMOnlineTitle *onlineTitle;

@property (nonatomic, copy) QBUUser* opponentUser;
@property (nonatomic, strong) id<NSObject> observerDidBecomeActive;
@property (nonatomic, strong) QMMessageStatusStringBuilder* stringBuilder;
@property (nonatomic, strong) NSMapTable* attachmentCells;
@property (nonatomic, readonly) UIImagePickerController* pickerController;
@property (nonatomic, assign) BOOL shouldHoldScrollOnCollectionView;
@property (nonatomic, strong) NSTimer* typingTimer;
@property (nonatomic, strong) id observerDidEnterBackground;

@property (nonatomic, strong) NSArray* unreadMessages;

@property (nonatomic, assign) BOOL isSendingAttachment;

@property (nonatomic, strong) UIButton *emojiButton;

@property (nonatomic, assign) BOOL shouldUpdateDialogAfterReturnFromGroupInfo;

@end

@implementation QMChatVC

@synthesize pickerController = _pickerController;

- (UIImagePickerController *)pickerController
{
    if (_pickerController == nil) {
        _pickerController = [UIImagePickerController new];
        _pickerController.delegate = self;
    }
    return _pickerController;
}

- (void)refreshCollectionView
{
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:NO];
}

#pragma mark - Override

- (NSUInteger)senderID
{
    return [QMApi instance].currentUser.ID;
}

- (NSString *)senderDisplayName
{
    return [QMApi instance].currentUser.fullName;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // chat appearance
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.textView.placeHolder = @"Message";
    
    self.stringBuilder = [QMMessageStatusStringBuilder new];
    
    self.showLoadEarlierMessagesHeader = YES;
    
    // emoji button init
    [self configureEmojiButton];

    //
    if (self.dialog.type == QBChatDialogTypePrivate) {
        NSUInteger oponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
        self.opponentUser = [[QMApi instance] userWithID:oponentID];
        [self configureNavigationBarForPrivateChat];
        
        [self updateTitleInfoForPrivateDialog];
    } else {
        if (!self.dialog.isJoined) {
            [self.dialog join];
        }
        
        [self configureNavigationBarForGroupChat];
        self.title = self.dialog.name;
    }
    
    // Retrieving messages from memory storage.
    self.items = [[[QMApi instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
    
    QMCollectionViewFlowLayoutInvalidationContext* context = [QMCollectionViewFlowLayoutInvalidationContext context];
    context.invalidateFlowLayoutMessagesCache = YES;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:context];
    
    [self refreshCollectionView];
    
    // Handling 'typing' status.
    if (self.dialog.type == QBChatDialogTypePrivate) {
        __weak typeof(self)weakSelf = self;
        [self.dialog setOnUserIsTyping:^(NSUInteger userID) {
            __typeof(self) strongSelf = weakSelf;
            if ([QBSession currentSession].currentUser.ID == userID) {
                return;
            }
            strongSelf.title = @"typing...";
        }];
        
        // Handling user stopped typing.
        [self.dialog setOnUserStoppedTyping:^(NSUInteger userID) {
            __typeof(self) strongSelf = weakSelf;
            [strongSelf updateTitleInfoForPrivateDialog];
        }];
    }
}

- (void)refreshMessagesShowingProgress:(BOOL)showingProgress {

    if (showingProgress && !self.isSendingAttachment) {
        [SVProgressHUD showWithStatus:@"Refreshing..." maskType:SVProgressHUDMaskTypeClear];
    }
    
    // Retrieving message from Quickblox REST history and cache.
    [[QMApi instance].chatService messagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {
        if (response.success) {

            if (showingProgress && !self.isSendingAttachment) {
                [SVProgressHUD dismiss];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Can not refresh messages"];
            NSLog(@"can not refresh messages: %@", response.error.error);
        }
    }];
}

- (void)updateTitleInfoForPrivateDialog {
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:self.opponentUser.ID];
    NSString *status = NSLocalizedString(item.online ? @"QM_STR_ONLINE": @"QM_STR_OFFLINE", nil);
    
    self.onlineTitle.titleLabel.text = self.opponentUser.fullName;
    self.onlineTitle.statusLabel.text = status;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.shouldUpdateDialogAfterReturnFromGroupInfo) {
        QBChatDialog *updatedDialog = [[QMApi instance].chatService.dialogsMemoryStorage chatDialogWithID:self.dialog.ID];
        if (updatedDialog != nil) {
            self.dialog = updatedDialog;
            self.title = self.dialog.name;
            [[QMApi instance].chatService joinToGroupDialog:self.dialog failed:^(NSError *error) {
                //
                NSLog(@"Failed to join group dialog, because: %@", error.localizedDescription);
            }];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        self.shouldUpdateDialogAfterReturnFromGroupInfo = NO;
    }
    
    [[QMApi instance].settingsManager setDialogWithIDisActive:self.dialog.ID];
    
    [[QMApi instance].chatService addDelegate:self];
    [QMApi instance].chatService.chatAttachmentService.delegate = self;
    [[QMApi instance].contactListService addDelegate:self];
    self.actionsHandler = self; // contact request delegate
    
    __weak __typeof(self) weakSelf = self;
    self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(self) strongSelf = weakSelf;
        
        if ([[QBChat instance] isLoggedIn]) {
            [strongSelf refreshMessagesShowingProgress:NO];
        }
    }];
    
    self.observerDidEnterBackground = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __typeof(self) strongSelf = weakSelf;
        [strongSelf fireStopTypingIfNecessary];
    }];
    
    if ([self.items count] > 0) {
        [self refreshMessagesShowingProgress:NO];
    }
    else {
        [self refreshMessagesShowingProgress:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[QMApi instance].settingsManager setDialogWithIDisActive:nil];
    
    [super viewWillDisappear:animated];
    
    [[QMApi instance].chatService removeDelegate:self];
    [[QMApi instance].contactListService removeDelegate:self];
    self.actionsHandler = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerDidEnterBackground];
    
    // Deletes typing blocks.
    [self.dialog clearTypingStatusBlocks];
}

- (void)configureNavigationBarForPrivateChat {
    
    self.onlineTitle = [[QMOnlineTitle alloc] initWithFrame:CGRectMake(0,
                                                                       0,
                                                                       150,
                                                                       self.navigationController.navigationBar.frame.size.height)];
    self.navigationItem.titleView = self.onlineTitle;
    
#if QM_AUDIO_VIDEO_ENABLED
    UIButton *audioButton = [QMChatButtonsFactory audioCall];
    [audioButton addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoButton = [QMChatButtonsFactory videoCall];
    [videoButton addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *videoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:videoButton];
    UIBarButtonItem *audioCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    
    [self.navigationItem setRightBarButtonItems:@[videoCallBarButtonItem,  audioCallBarButtonItem] animated:YES];
    
#else
    [self.navigationItem setRightBarButtonItem:nil];
#endif
}

- (void)configureNavigationBarForGroupChat {
    
    self.title = self.dialog.name;
    UIButton *groupInfoButton = [QMChatButtonsFactory groupInfo];
    [groupInfoButton addTarget:self action:@selector(groupInfoNavButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *groupInfoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupInfoButton];
    self.navigationItem.rightBarButtonItems = @[groupInfoBarButtonItem];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Nav Buttons Actions

- (BOOL)callsAllowed {
#if QM_AUDIO_VIDEO_ENABLED == 0
    [QMAlertsFactory comingSoonAlert];
    return NO;
#else
    if (![QMApi instance].isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return NO;
    }
    
    if( ![[QMApi instance] isFriend:self.opponentUser] || [[QMApi instance] userIDIsInPendingList:self.opponentUser.ID] ) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO];
        return NO;
    }
    
    BOOL callsAllowed = [[[self.inputToolbar contentView] textView] isEditable];
    if( !callsAllowed ) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO];
        return NO;
    }
    
    return YES;
#endif
}

- (void)audioCallAction {
    if (![self callsAllowed]) return;
    
    NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
    [[QMApi instance] callToUser:@(opponentID) conferenceType:QBRTCConferenceTypeAudio];
}

- (void)videoCallAction {
    if (![self callsAllowed]) return;
    
    NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
    [[QMApi instance] callToUser:@(opponentID) conferenceType:QBRTCConferenceTypeVideo];
}

- (void)groupInfoNavButtonAction {
    
    [self performSegueWithIdentifier:kGroupDetailsSegueIdentifier sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self.view endEditing:YES];
    if ([segue.identifier isEqualToString:kGroupDetailsSegueIdentifier]) {
        
        self.shouldUpdateDialogAfterReturnFromGroupInfo = YES;
        
        QMGroupDetailsController *groupDetailVC = segue.destinationViewController;
        groupDetailVC.chatDialog = self.dialog;
    }
    else {
        
        NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
        QBUUser *opponent = [[QMApi instance] userWithID:opponentID];
        
        QMBaseCallsController *callsController = segue.destinationViewController;
        [callsController setOpponent:opponent];
    }
}

#pragma mark - Utilities

- (void)sendReadStatusForMessage:(QBChatMessage *)message
{
    if (message.senderID != [QBSession currentSession].currentUser.ID && ![message.readIDs containsObject:@(self.senderID)]) {
        [[QMApi instance].chatService readMessage:message completion:^(NSError * _Nullable error) {
            //
            if (error != nil) {
                NSLog(@"Problems while marking message as read! Error: %@", error);
            }
            else {
                if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                    [UIApplication sharedApplication].applicationIconBadgeNumber--;
                }
            }
        }];
    }
}

- (void)readMessages:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([QBChat instance].isLoggedIn) {
        [[QMApi instance].chatService readMessages:messages forDialogID:dialogID completion:nil];
    } else {
        self.unreadMessages = messages;
    }
}

- (void)fireStopTypingIfNecessary
{
    [self.typingTimer invalidate];
    self.typingTimer = nil;
    [self.dialog sendUserStoppedTyping];
}

- (BOOL)messageSendingAllowed {
    if (![QMApi instance].isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return NO;
    }
    
    if (![QBChat instance].isConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) actionSuccess:NO];
        return NO;
    }
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        if (![[QMApi instance] isFriend:self.opponentUser]) {
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_SEND_MESSAGES", nil) actionSuccess:NO];
            return NO;
        }
        if ([[QMApi instance] userIDIsInPendingList:self.opponentUser.ID]) {
            [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_SEND_MESSAGES", nil) actionSuccess:NO];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark Tool bar Actions

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    if (self.typingTimer != nil) {
        [self fireStopTypingIfNecessary];
    }
    
    if (![self messageSendingAllowed]) return;
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    message.markable = YES;
    message.deliveredIDs = @[@(self.senderID)];
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.dialog.ID;
    message.dateSent = date;

    // Sending message
    [[QMApi instance].chatService sendMessage:message type:QMMessageTypeText toDialogID:self.dialog.ID saveToHistory:YES saveToStorage:YES completion:^(NSError * _Nullable error) {
        //
        if (error != nil) {
            [REAlertView showAlertWithMessage:error.localizedRecoverySuggestion actionSuccess:NO];
        }
    }];
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    if (![self messageSendingAllowed]) return;
    
    [super didPressAccessoryButton:sender];
}

#pragma mark - Cell classes

- (Class)viewClassForItem:(QBChatMessage *)item
{
    if (item.isNotificatonMessage) {
        
        if (item.messageType == QMMessageTypeContactRequest && item.senderID != self.senderID && ![[QMApi instance] isFriend:self.opponentUser]) {
            QBChatMessage *latestMessage = [[QMApi instance].chatService.messagesMemoryStorage lastMessageFromDialogID:self.dialog.ID];
            
            if ([item isEqual:latestMessage]) {
                return [QMChatContactRequestCell class];
            }
            
            return [QMChatNotificationCell class];
        }
        else {
            return [QMChatNotificationCell class];
        }
        
    } else {
        if (item.senderID != self.senderID) {
            if ((item.attachments != nil && item.attachments.count > 0) || item.attachmentStatus != QMMessageAttachmentStatusNotLoaded) {
                return [QMChatAttachmentIncomingCell class];
            } else {
                return [QMChatIncomingCell class];
            }
        } else {
            if ((item.attachments != nil && item.attachments.count > 0) || item.attachmentStatus != QMMessageAttachmentStatusNotLoaded) {
                return [QMChatAttachmentOutgoingCell class];
            } else {
                return [QMChatOutgoingCell class];
            }
        }
    }
    return nil;
}

#pragma mark - Strings builder

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {

    if (messageItem.isNotificatonMessage) {
        //
        NSString *dateString = messageItem.dateSent ? [[self timeStampWithDate:messageItem.dateSent] stringByAppendingString:@"\n"] : @"";
        NSString *notificationMessageString = [[NSString alloc] init];
        notificationMessageString = messageItem.messageType == QMMessageTypeUpdateGroupDialog ? messageItem.text : [QMChatUtils messageTextForNotification:messageItem];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[dateString stringByAppendingString:notificationMessageString]];
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:12.0f]
                        range:NSMakeRange(0, dateString.length-1)];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor blackColor]
                        range:NSMakeRange(0, dateString.length-1)];
        
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont boldSystemFontOfSize:14.0f]
                        range:NSMakeRange(dateString.length, notificationMessageString.length)];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor colorWithRed:113.0f/255.0f green:113.0f/255.0f blue:113.0f/255.0f alpha:1.0f]
                        range:NSMakeRange(dateString.length, notificationMessageString.length)];
        
        return attrStr;
    }
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor whiteColor] : [UIColor blackColor];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f] ;
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:messageItem.text ? messageItem.text : @"" attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    if ([messageItem senderID] == self.senderID || self.dialog.type == QBChatDialogTypePrivate) {
        return nil;
    }
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f];
    
    NSString *topLabelText = self.opponentUser.fullName != nil ? self.opponentUser.fullName : self.opponentUser.login;
    
    if (self.dialog.type != QBChatDialogTypePrivate) {
        QBUUser* user = [[QMApi instance] userWithID:messageItem.senderID];
        if (user != nil) {
            topLabelText = user.fullName != nil ? user.fullName : user.login;
        } else {
            topLabelText = [NSString stringWithFormat:@"%lu",(unsigned long)messageItem.senderID];
        }
    }
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:122.0f / 255.0f blue:1.0f alpha:1.000], NSFontAttributeName:font};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:topLabelText attributes:attributes];
    
    return attrStr;
}

- (NSAttributedString *)bottomLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    UIColor *textColor = [messageItem senderID] == self.senderID ? [UIColor colorWithWhite:1 alpha:0.8f] : [UIColor colorWithWhite:0.000 alpha:0.4f];
    UIFont *font = [UIFont systemFontOfSize:12.0f];
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    NSString* text = messageItem.dateSent ? [self timeStampWithDate:messageItem.dateSent] : @"";
    if ([messageItem senderID] == self.senderID) {
        text = [NSString stringWithFormat:@"%@\n%@", text, [self.stringBuilder statusFromMessage:messageItem]];
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text
                                                                                attributes:attributes];
    
    return attrStr;
}

#pragma mark - Collection View Datasource

- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = self.items[indexPath.item];
    Class viewClass = [self viewClassForItem:item];
    CGSize size = CGSizeZero;
    
    if (viewClass == [QMChatAttachmentIncomingCell class]) {
        size = CGSizeMake(MIN(200, maxWidth), 200);
    } else if(viewClass == [QMChatAttachmentOutgoingCell class]) {
        NSAttributedString *attributedString = [self bottomLabelAttributedStringForItem:item];
        
        CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                                  withConstraints:CGSizeMake(MIN(200, maxWidth), CGFLOAT_MAX)
                                                           limitedToNumberOfLines:0];
        size = CGSizeMake(MIN(200, maxWidth), 200 + ceilf(bottomLabelSize.height));
    } else if (viewClass == [QMChatNotificationCell class]) {
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:3];
    } else {
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                         limitedToNumberOfLines:0];
    }
    
    return size;
}

- (CGFloat)collectionView:(QMChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatMessage *item = self.items[indexPath.item];
    
    NSAttributedString *attributedString = [NSAttributedString new];
    if ([item senderID] == self.senderID) {
        attributedString = [self bottomLabelAttributedStringForItem:item];
    } else {
        if (self.dialog.type != QBChatDialogTypePrivate) {
            CGSize topLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:[self topLabelAttributedStringForItem:item]
                                                           withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                    limitedToNumberOfLines:0];
            CGSize bottomLabelSize = [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                                           withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                    limitedToNumberOfLines:0];
            
            return topLabelSize.width > bottomLabelSize.width ? topLabelSize.width : bottomLabelSize.width;
        }
        else {
            attributedString = [self bottomLabelAttributedStringForItem:item];
        }
    }
    
    CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                   withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                            limitedToNumberOfLines:0];
    
    return size.width;
}

- (void)collectionView:(QMChatCollectionView *)collectionView header:(QMLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    self.shouldHoldScrollOnCollectionView = YES;
    __weak typeof(self)weakSelf = self;
    // Getting earlier messages for chat dialog identifier.
    [[QMApi instance].chatService earlierMessagesWithChatDialogID:self.dialog.ID completion:^(QBResponse *response, NSArray *messages) {
        
        weakSelf.shouldHoldScrollOnCollectionView = NO;
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    Class viewClass = [self viewClassForItem:self.items[indexPath.row]];
    if (viewClass == [QMChatAttachmentIncomingCell class] || viewClass == [QMChatAttachmentOutgoingCell class]) return NO;
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    QBChatMessage* message = self.items[indexPath.row];
    
    Class viewClass = [self viewClassForItem:self.items[indexPath.row]];
    
    if (viewClass == [QMChatAttachmentIncomingCell class] || viewClass == [QMChatAttachmentOutgoingCell class]) return;
    
    [UIPasteboard generalPasteboard].string = message.text;
}

#pragma mark - Utility

- (NSString *)timeStampWithDate:(NSDate *)date {
    
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yy HH:mm";
    });
    
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    
    return timeStamp;
}

#pragma mark - ChatCollectionViewDelegate

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    QMChatCellLayoutModel layoutModel = [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        layoutModel.topLabelHeight = 0.0;
    }
    
    
    QBChatMessage* item = self.items[indexPath.row];
    Class class = [self viewClassForItem:item];
    
    if (class == [QMChatOutgoingCell class] ||
        class == [QMChatAttachmentOutgoingCell class]) {
        NSAttributedString* bottomAttributedString = [self bottomLabelAttributedStringForItem:item];
        CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:bottomAttributedString
                                                       withConstraints:CGSizeMake(CGRectGetWidth(self.collectionView.frame) - widthPadding, CGFLOAT_MAX)
                                                limitedToNumberOfLines:0];
        layoutModel.avatarSize = (CGSize){0.0, 0.0};
        layoutModel.bottomLabelHeight = ceilf(size.height);
    } else if (class == [QMChatAttachmentIncomingCell class] ||
               class == [QMChatIncomingCell class]) {
        if (self.dialog.type != QBChatDialogTypePrivate) {
            layoutModel.topLabelHeight = 20.0f;
        }
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
        layoutModel.avatarSize = (CGSize){50.0, 50.0};
    } else if (class == [QMChatNotificationCell class]) {
        
        layoutModel.spaceBetweenTopLabelAndTextView = 5.0f;
    }
    
    layoutModel.spaceBetweenTextViewAndBottomLabel = 5.0f;
    
    return layoutModel;
}

- (void)collectionView:(QMChatCollectionView *)collectionView configureCell:(UICollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    [super collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    
    [(QMChatCell *)cell setDelegate:self];
    
    [(QMChatCell *)cell containerView].highlightColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    
    if ([cell isKindOfClass:[QMChatOutgoingCell class]] || [cell isKindOfClass:[QMChatAttachmentOutgoingCell class]]) {
        [(QMChatOutgoingCell *)cell containerView].bgColor = [UIColor colorWithRed:23.0f / 255.0f green:209.0f / 255.0f blue:75.0f / 255.0f alpha:1.0f];
    } else if ([cell isKindOfClass:[QMChatIncomingCell class]] || [cell isKindOfClass:[QMChatAttachmentIncomingCell class]]) {
        [(QMChatIncomingCell *)cell containerView].bgColor = [UIColor colorWithRed:226.0f / 255.0f green:235.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f];
        
        /**
         *  Setting opponent avatar
         */
        QBChatMessage* message = self.items[indexPath.row];
        QBUUser *sender = [[QMApi instance] userWithID:message.senderID];
        NSURL *userImageUrl = [QMUsersUtils userAvatarURL:sender];
        UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
        
        [[(QMChatCell *)cell avatarView] setImageWithURL:userImageUrl
                                             placeholder:placeholder
                                                 options:SDWebImageHighPriority
                                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                          completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
        [(QMChatCell *)cell avatarView].imageViewType = QMImageViewTypeCircle;
        
    } else if ([cell isKindOfClass:[QMChatNotificationCell class]] || [cell isKindOfClass:[QMChatContactRequestCell class]]) {
        [(QMChatCell *)cell containerView].bgColor = self.collectionView.backgroundColor;
    }
    if ([cell conformsToProtocol:@protocol(QMChatAttachmentCell)]) {
        QBChatMessage* message = self.items[indexPath.row];
        if (message.attachments != nil) {
            QBChatAttachment* attachment = message.attachments.firstObject;
            
            BOOL shouldLoadFile = YES;
            if ([self.attachmentCells objectForKey:attachment.ID] != nil) {
                shouldLoadFile = NO;
            }
            
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
            
            if (!shouldLoadFile) return;
            
            __weak typeof(self)weakSelf = self;
            // Getting image from chat attachment service.
            [[QMApi instance].chatService.chatAttachmentService getImageForChatAttachment:attachment completion:^(NSError *error, UIImage *image) {
                __typeof(self) strongSelf = weakSelf;
                
                if ([(UICollectionViewCell<QMChatAttachmentCell> *)cell attachmentID] != attachment.ID) return;
                
                [strongSelf.attachmentCells removeObjectForKey:attachment.ID];
                
                if (error != nil) {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                } else {
                    if (image != nil) {
                        [(UICollectionViewCell<QMChatAttachmentCell> *)cell setAttachmentImage:image];
                        [cell updateConstraints];
                    }
                }
            }];
        }
    }
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    if ([self.dialog.ID isEqualToString:dialogID]) {
        // Retrieving messages from memory strorage.
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        [self refreshCollectionView];
        
        [self sendReadStatusForMessage:message];
    }
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([self.dialog.ID isEqualToString:dialogID]) {
        [self readMessages:messages forDialogID:dialogID];
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        
        if (self.shouldHoldScrollOnCollectionView) {
            CGFloat bottomOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y;
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            
            [self.collectionView reloadData];
            [self.collectionView performBatchUpdates:nil completion:nil];
            
            self.collectionView.contentOffset = (CGPoint){0, self.collectionView.contentSize.height - bottomOffset};
            
            [CATransaction commit];
        } else {
            [self refreshCollectionView];
        }
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog{
    if( [self.dialog.ID isEqualToString:chatDialog.ID] ) {
        self.dialog = chatDialog;
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID
{
    if ([self.dialog.ID isEqualToString:dialogID]) {
        self.items = [[chatService.messagesMemoryStorage messagesWithDialogID:dialogID] mutableCopy];
        NSUInteger index = [self.items indexOfObject:message];
        if (index != NSNotFound) {
            QMCollectionViewFlowLayoutInvalidationContext* context = [QMCollectionViewFlowLayoutInvalidationContext context];
            context.invalidateFlowLayoutMessagesCache = YES;
            [self.collectionView.collectionViewLayout invalidateLayoutWithContext:context];
            
            if ([self.collectionView numberOfItemsInSection:0] != 0) {
                [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            }
        }
    }
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
}

#pragma mark - QMChatConnectionDelegate

- (void)refreshAndReadMessages;
{
    if (self.dialog.type != QBChatDialogTypePrivate) {
        [self refreshMessagesShowingProgress:NO];
    }

    for (QBChatMessage* message in self.unreadMessages) {
        [self sendReadStatusForMessage:message];
    }
    
    self.unreadMessages = nil;
}

- (void)chatServiceChatDidConnect:(QMChatService *)chatService {
    [self refreshAndReadMessages];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService {
    [self refreshAndReadMessages];
}

#pragma mark - QMChatAttachmentServiceDelegate

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeAttachmentStatus:(QMMessageAttachmentStatus)status forMessage:(QBChatMessage *)message
{
    if (message.dialogID == self.dialog.ID) {
        // Retrieving messages for dialog from memory storage.
        self.items = [[[QMApi instance].chatService.messagesMemoryStorage messagesWithDialogID:self.dialog.ID] mutableCopy];
        [self refreshCollectionView];
    }
}

- (void)chatAttachmentService:(QMChatAttachmentService *)chatAttachmentService didChangeLoadingProgress:(CGFloat)progress forChatAttachment:(QBChatAttachment *)attachment
{
    UICollectionViewCell<QMChatAttachmentCell>* cell = [self.attachmentCells objectForKey:attachment.ID];
    if (cell != nil) {
        [cell updateLoadingProgress:progress];
    }
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.typingTimer) {
        [self.typingTimer invalidate];
        self.typingTimer = nil;
    } else {
        [self.dialog sendUserIsTyping];
    }
    
    self.typingTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(fireStopTypingIfNecessary) userInfo:nil repeats:NO];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [super textViewDidEndEditing:textView];
    
    [self fireStopTypingIfNecessary];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)didPickAttachmentImage:(UIImage *)image
{
    self.isSendingAttachment = YES;
    [SVProgressHUD showWithStatus:@"Uploading attachment" maskType:SVProgressHUDMaskTypeClear];
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __typeof(self) strongSelf = weakSelf;
        UIImage* newImage = image;
        if (strongSelf.pickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            newImage = [newImage fixOrientation];
        }
        
        UIImage* resizedImage = [strongSelf resizedImageFromImage:newImage];
        
        QBChatMessage* message = [QBChatMessage new];
        message.senderID = strongSelf.senderID;
        message.dialogID = strongSelf.dialog.ID;
        message.dateSent = [NSDate date];
        
        // Sending attachment to dialog.
        [[QMApi instance].chatService.chatAttachmentService sendMessage:message
                                                                         toDialog:strongSelf.dialog
                                                                  withChatService:[QMApi instance].chatService
                                                                withAttachedImage:resizedImage completion:^(NSError *error) {
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        if (error != nil) {
                                                                            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                                                        } else {
                                                                            [SVProgressHUD showSuccessWithStatus:@"Completed"];

                                                                        }
                                                                        weakSelf.isSendingAttachment = NO;
                                                                    });
                                                                }];
    });
}

- (UIImage *)resizedImageFromImage:(UIImage *)image
{
    CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
    CGFloat scaleCoefficient = largestSide / 560.0f;
    CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:(CGRect){0, 0, newSize.width, newSize.height}];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

#pragma mark Contact List Serice Delegate

- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    if (self.dialog.type == QBChatDialogTypePrivate) {
        if (self.opponentUser.ID == userID) {
            self.onlineTitle.statusLabel.text = NSLocalizedString(isOnline ? @"QM_STR_ONLINE": @"QM_STR_OFFLINE", nil);
        }
    }
}

#pragma mark QMChatActionsHandler protocol

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    if (accept) {
        [[QMApi instance] confirmAddContactRequest:self.opponentUser completion:^(BOOL success) {
            //
            [SVProgressHUD dismiss];
            [self refreshMessagesShowingProgress:NO];
            [self refreshCollectionView];
        }];
    }
    else {
        __weak __typeof(self)weakSelf = self;
        [[QMApi instance] rejectAddContactRequest:self.opponentUser completion:^(BOOL success) {
            //
            [[QMApi instance] deleteChatDialog:self.dialog completion:^(BOOL succeed) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
                [SVProgressHUD dismiss];
            }];
        }];
    }
}

#pragma mark QMChatCellDelegate

- (void)chatCell:(QMChatCell *)cell didTapAtPosition:(CGPoint)position {
}

- (void)chatCell:(QMChatCell *)cell didPerformAction:(SEL)action withSender:(id)sender {
}

- (void)chatCellDidTapContainer:(QMChatCell *)cell {
    if ([cell isKindOfClass:[QMChatAttachmentIncomingCell class]] || [cell isKindOfClass:[QMChatAttachmentOutgoingCell class]]) {
        UIImage *attachmentImage = [(QMChatAttachmentIncomingCell *)cell attachmentImageView].image;
        if (attachmentImage != nil) {
            IDMPhoto *photo = [IDMPhoto photoWithImage:attachmentImage];
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
            [self presentViewController:browser animated:YES completion:nil];
        }
    }
}

- (void)chatCellDidTapAvatar:(QMChatCell *)cell {
}

#pragma mark - Emoji

- (void)configureEmojiButton {
    // init
    self.emojiButton = [QMChatButtonsFactory emojiButton];
    self.emojiButton.tag = kQMEmojiButtonTag;
    [self.emojiButton addTarget:self action:@selector(showEmojiKeyboard) forControlEvents:UIControlEventTouchUpInside];

    // appearance
    self.emojiButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.inputToolbar.contentView addSubview:self.emojiButton];
    
    CGFloat emojiButtonSpacing = kQMEmojiButtonSize/3.0f;
    
    [self.inputToolbar.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emojiButton(==size)]|"
                                                                                          options:0
                                                                                          metrics:@{@"size" : @(kQMEmojiButtonSize)}
                                                                                            views:@{@"emojiButton" : self.emojiButton}]];
    [self.inputToolbar.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[emojiButton]-spacing-[rightBarButton]"
                                                                                          options:0
                                                                                          metrics:@{@"spacing" : @(emojiButtonSpacing)}
                                                                                            views:@{@"emojiButton"    : self.emojiButton,
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

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage:category];
    
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage:category];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"keyboard_icon"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - Emoji Delegate

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    
    NSString *textViewString = self.inputToolbar.contentView.textView.text;
    self.inputToolbar.contentView.textView.text = [textViewString stringByAppendingString:emoji];
    [self textViewDidChange:self.inputToolbar.contentView.textView];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
    self.inputToolbar.contentView.textView.inputView = nil;
    [self.inputToolbar.contentView.textView reloadInputViews];
    
    UIButton *emojiButton = (UIButton *)[self.inputToolbar.contentView viewWithTag:kQMEmojiButtonTag];
    [emojiButton setImage:[UIImage imageNamed:@"ic_smile"] forState:UIControlStateNormal];
    
    [self scrollToBottomAnimated:YES];
}

@end
