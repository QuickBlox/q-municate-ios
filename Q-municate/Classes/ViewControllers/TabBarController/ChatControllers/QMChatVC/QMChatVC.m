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
#import <QuartzCore/QuartzCore.h>

// new chat controller
#import "UIImage+QM.h"
#import "UIColor+QM.h"
#import <TTTAttributedLabel.h>
#import "QMChatAttachmentIncomingCell.h"
#import "QMChatAttachmentOutgoingCell.h"
#import "QMChatAttachmentCell.h"
#import "QMCollectionViewFlowLayoutInvalidationContext.h"
#import "QMMessageStatusStringBuilder.h"

// old chat controller
//#import "QMChatToolbarContentView.h"
//#import "QMChatInputToolbar.h"
#import "QMChatButtonsFactory.h"

static const NSUInteger widthPadding = 40.0f;

@interface QMChatVC ()

@property (strong, nonatomic) QMOnlineTitle *onlineTitle;

@property (nonatomic, weak) QBUUser* opponentUser;
@property (nonatomic, strong) id<NSObject> observerDidBecomeActive;
@property (nonatomic, strong) QMMessageStatusStringBuilder* stringBuilder;
@property (nonatomic, strong) NSMapTable* attachmentCells;
@property (nonatomic, readonly) UIImagePickerController* pickerController;
@property (nonatomic, assign) BOOL shouldHoldScrollOnCollectionView;
@property (nonatomic, strong) NSTimer* typingTimer;
@property (nonatomic, strong) id observerDidEnterBackground;

@property (nonatomic, strong) NSArray* unreadMessages;

@property (nonatomic, assign) BOOL isSendingAttachment;


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
//    self.inputToolbar.contentView.backgroundColor = [UIColor whiteColor];
    self.inputToolbar.contentView.textView.placeHolder = @"Message";
    
    self.showLoadEarlierMessagesHeader = YES; // need to check if this label is needed or not
    
    self.stringBuilder = [QMMessageStatusStringBuilder new];

    if (self.dialog.type == QBChatDialogTypePrivate) {
        NSUInteger oponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
        self.opponentUser = [[QMApi instance] userWithID:oponentID];
        [self configureNavigationBarForPrivateChat];
        
        if ([[QBChat instance].contactList pendingApproval].count > 0) {
            self.inputToolbar.hidden = YES;
        }
        
        [self updateTitleInfoForPrivateDialog];
    } else {
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

- (void)refreshMessagesShowingProgress:(BOOL)showingProgress {
    
    if (self.dialog.type != QBChatDialogTypePrivate && !self.dialog.isJoined && [QBChat instance].isLoggedIn) {
        // in order to join/rejoin group dialog it must be up to date with the server one
        [[QMApi instance].chatService loadDialogWithID:self.dialog.ID completion:^(QBChatDialog *loadedDialog) {
            //
            if (loadedDialog != nil) {
                [[QMApi instance].chatService joinToGroupDialog:loadedDialog failed:^(NSError *error) {
                    NSLog(@"Failed to join room with error: %@", error.localizedDescription);
                }];
            }
            else {
                // dialog was not found, let dialogcontroller handle it
                [self.navigationController popViewControllerAnimated:NO];
            }
        }];
    }
    
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
    
    // Saving currently opened dialog.
    //[QMApi instance].currentDialogID = self.dialog.ID;
    
    if ([self.items count] > 0) {
        if (self.dialog.type != QBChatDialogTypePrivate) {
            [self refreshMessagesShowingProgress:YES];
        }
        else {
            [self refreshMessagesShowingProgress:NO];
        }
    }
    else {
        [self refreshMessagesShowingProgress:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setUpTabBarChatDelegate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeTabBarChatDelegate];
    self.dialog.unreadMessagesCount = 0;
    
    [super viewWillDisappear:animated];
    
    [[QMApi instance].chatService removeDelegate:self];
    [[QMApi instance].contactListService removeDelegate:self];
    self.actionsHandler = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerDidEnterBackground];
    
    // Deletes typing blocks.
    [self.dialog clearTypingStatusBlocks];
    
    // Resetting currently opened dialog.
//    [ServicesManager instance].currentDialogID = nil;
}

- (void)setUpTabBarChatDelegate
{
//    if (self.tabBarController != nil && [self.tabBarController isKindOfClass:QMMainTabBarController.class]) {
//        ((QMMainTabBarController *)self.tabBarController).chatDelegate = self;
//    }
}

- (void)removeTabBarChatDelegate
{
//    if (self.tabBarController != nil && [self.tabBarController isKindOfClass:QMMainTabBarController.class]) {
//        ((QMMainTabBarController *)self.tabBarController).chatDelegate = nil;
//    }
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

- (void)audioCallAction {
#if QM_AUDIO_VIDEO_ENABLED == 0
    [QMAlertsFactory comingSoonAlert];
#else
    
    BOOL callsAllowed = [[[self.inputToolbar contentView] textView] isEditable];
    if( !callsAllowed ) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO];
        return;
    }
    NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
    [[QMApi instance] callToUser:@(opponentID) conferenceType:QBConferenceTypeAudio];
    
#endif
}

- (void)videoCallAction {
#if QM_AUDIO_VIDEO_ENABLED == 0
    [QMAlertsFactory comingSoonAlert];
#else
    BOOL callsAllowed = [[[self.inputToolbar contentView] textView] isEditable];
    if( !callsAllowed ) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil) actionSuccess:NO];
        return;
    }
    
    NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
    [[QMApi instance] callToUser:@(opponentID) conferenceType:QBConferenceTypeVideo];
#endif
}

- (void)groupInfoNavButtonAction {
    
    [self performSegueWithIdentifier:kGroupDetailsSegueIdentifier sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [self.view endEditing:YES];
    if ([segue.identifier isEqualToString:kGroupDetailsSegueIdentifier]) {
        
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
        message.markable = YES;
        // Sending read message status.
        if (![[QBChat instance] readMessage:message]) {
            NSLog(@"Problems while marking message as read!");
        }
        else {
            if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                [UIApplication sharedApplication].applicationIconBadgeNumber--;
            }
        }
    }
}

- (void)readMessages:(NSArray *)messages forDialogID:(NSString *)dialogID
{
    if ([QBChat instance].isLoggedIn) {
        for (QBChatMessage* message in messages) {
            [self sendReadStatusForMessage:message];
        }
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
    
    QBChatMessage *message = [QBChatMessage message];
    message.text = text;
    message.senderID = senderId;
    message.markable = YES;
    message.readIDs = @[@(self.senderID)];
    message.dialogID = self.dialog.ID;
    
    // Sending message.
    [[QMApi instance].chatService sendMessage:message toDialogId:self.dialog.ID save:YES completion:nil];
    
    [self finishSendingMessageAnimated:YES];
}

#pragma mark - Cell classes

- (Class)viewClassForItem:(QBChatMessage *)item
{
    if (item.isNotificatonMessage) {
        
        if (item.messageType == QMMessageTypeContactRequest && item.senderID != self.senderID && ![[QMApi instance] isFriend:self.opponentUser]) {
            return [QMChatContactRequestCell class];
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
        NSString *notificationMessageString = [QMChatUtils messageTextForNotification:messageItem];
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
            attributedString = [self topLabelAttributedStringForItem:item];
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
        __typeof(self) strongSelf = weakSelf;
        
        strongSelf.shouldHoldScrollOnCollectionView = NO;
        
        QBChatMessage *oldestMessage = [[QMApi instance].chatService.messagesMemoryStorage oldestMessageForDialogID:self.dialog.ID];
        if ([[messages lastObject] isEqual:oldestMessage] || messages.count == 0) {
            strongSelf.showLoadEarlierMessagesHeader = NO;
        }
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
        dateFormatter.dateFormat = @"HH:mm";
    });
    
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    
    return timeStamp;
}

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
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
        }
    }
}

#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:@"Chat connected!" maskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Logging in to chat..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:@"Chat reconnected!" maskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Logging in to chat..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)chatService
{
    [SVProgressHUD showErrorWithStatus:@"Chat disconnected!"];
}

- (void)chatServiceChatDidLogin
{
    if (self.dialog.type != QBChatDialogTypePrivate) {
        [self refreshMessagesShowingProgress:YES];
    }
    
    [SVProgressHUD showSuccessWithStatus:@"Logged in!"];
    
    for (QBChatMessage* message in self.unreadMessages) {
        [self sendReadStatusForMessage:message];
    }
    
    self.unreadMessages = nil;
}

- (void)chatServiceChatDidNotLoginWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"Unable to login to chat!"];
}

- (void)chatServiceChatDidFailWithStreamError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"Error: No Internet Connection! "];
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
            //newImage = [newImage fixOrientation];
        }
        
        UIImage* resizedImage = [strongSelf resizedImageFromImage:newImage];
        
        QBChatMessage* message = [QBChatMessage new];
        message.senderID = strongSelf.senderID;
        message.dialogID = strongSelf.dialog.ID;
        
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

- (void)contactListService:(QMContactListService *)contactListService didUpdateUser:(QBUUser *)user {
    
    if (self.dialog.type == QBChatDialogTypePrivate) {
        if([[QMApi instance] isFriend:self.opponentUser] || [[QBChat instance].contactList pendingApproval].count == 0) {
            self.inputToolbar.hidden = NO;
        }
        [self updateTitleInfoForPrivateDialog];
    }
}

#pragma mark QMChatActionsHandler protocol

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender {
    if (accept) {
        [[QMApi instance] confirmAddContactRequest:self.opponentUser completion:^(BOOL success) {
            //
            self.inputToolbar.hidden = NO;
            [self refreshCollectionView];
        }];
    }
    else {
        [[QMApi instance] rejectAddContactRequest:self.opponentUser completion:^(BOOL success) {
            //
            [self refreshCollectionView];
        }];
    }
}

#pragma mark - QMChatDataSourceDelegate

//- (void)chatDatasource:(QMChatDataSource *)chatDatasource prepareImageURLAttachement:(NSURL *)imageUrl {
//    
//    IDMPhoto *photo = [IDMPhoto photoWithURL:imageUrl];
//    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo]];
//    browser.displayToolbar = NO;
//    [self presentViewController:browser animated:YES completion:nil];
//}
//
//- (void)chatDatasource:(QMChatDataSource *)chatDatasource prepareImageAttachement:(UIImage *)image fromView:(UIView *)fromView {
//    
//    IDMPhoto *photo = [IDMPhoto photoWithImage:image];
//    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:fromView];
//    [self presentViewController:browser animated:YES completion:nil];
//}


#pragma mark - Chat Input Toolbar Lock Delegate

//- (void)inputBarShouldLock
//{
//    [self.inputToolbar lock];
//}
//
//- (void)inputBarShouldUnlock
//{
//    [self.inputToolbar unlock];
//}

@end
