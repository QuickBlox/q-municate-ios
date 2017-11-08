//
//  QMChatVC.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/9/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatVC.h"
#import "QMCore.h"
#import "QMNavigationController.h"
#import "QMStatusStringBuilder.h"
#import "QMSoundManager.h"
#import "QMImagePicker.h"
#import "QMOnlineTitleView.h"
#import "QMColors.h"
#import "QMUserInfoViewController.h"
#import "QMGroupInfoViewController.h"
#import "QMLocationViewController.h"
#import "QMAlert.h"
#import "QMPhoto.h"
#import "QMCallNotificationItem.h"
#import "QMHelpers.h"
#import "QMSplitViewController.h"
#import "QMMessagesHelper.h"

// helpers
#import "QMChatButtonsFactory.h"
#import "UIImage+fixOrientation.h"
#import "QBChatDialog+OpponentID.h"
#import <QMDateUtils.h>
#import <UIImageView+QMLocationSnapshot.h>
#import "QBChatMessage+QMCallNotifications.h"
#import "QMAudioRecorder.h"
#import "QMMediaController.h"
#import "QMAudioPlayer.h"
#import "QMPermissions.h"
#import "UIScreen+QMLock.h"
#import "QMImageBarButtonItem.h"

// external
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVKit/AVKit.h>

@import SafariServices;

static const float kQMAttachmentCellSize = 180.0f;
static const NSTimeInterval kQMMaxAttachmentDuration = 30.0f;

static const CGFloat kQMWidthPadding = 40.0f;
static const CGFloat kQMAvatarSize = 28.0f;

static NSString * const kQMTextAttachmentSpacing = @"  ";

@interface UIView(QMShake)

- (void)qm_shake;

@end

@implementation UIView(QMShake)

- (void)qm_shake {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.3f;
    animation.values = @[@(-10), @(10), @(-5), @(5), @(0)];
    [self.layer addAnimation:animation forKey:@"shake"];
}

@end

@interface QMChatVC ()
<
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMContactListServiceDelegate,
QMDeferredQueueManagerDelegate,
QMChatActionsHandler,
QMChatCellDelegate,
QMImagePickerResultHandler,
QMMediaControllerDelegate,
QMCallManagerDelegate,
QMOpenGraphServiceDelegate,
QMUsersServiceDelegate
>
/**
 *  Detailed cells set.
 */
@property (strong, nonatomic) NSMutableSet *detailedCells;

/**
 *  Navigation bar online title.
 */
@property (weak, nonatomic) IBOutlet QMOnlineTitleView *onlineTitleView;

/**
 *  Determines whether opponent is typing now.
 */
@property (assign, nonatomic) BOOL isOpponentTyping;

/**
 *  Stored messages in memory storage.
 */
@property (strong, nonatomic) NSArray *storedMessages;


/**
 *  Deferred queue manager for message sending.
 */
@property (strong, nonatomic) QMDeferredQueueManager *deferredQueueManager;

/**
 *  Observer for UIApplicationWillResignActiveNotification.
 */
@property (strong, nonatomic) id observerWillResignActive;

/**
 *  Timer for typing status.
 */
@property (strong, nonatomic) NSTimer *typingTimer;

/**
 *  Message status text builder.
 */
@property (strong, nonatomic) QMStatusStringBuilder *statusStringBuilder;

/**
 *  Contact request task.
 */
@property (weak, nonatomic) BFTask *contactRequestTask;

@property (strong, nonatomic) QMMediaController *mediaController;
@property (strong, nonatomic) QMAudioRecorder *currentAudioRecorder;

@property (strong, nonatomic) NSMutableSet *messagesToRead;
/**
 *  Group avatar bar button item. Is used for right bar button item.
 */
@property (strong, nonatomic)  QMImageBarButtonItem *imageBarButtonItem;

@end

@implementation QMChatVC

@dynamic storedMessages;
@dynamic deferredQueueManager;

//MARK: - Static methods

+ (instancetype)chatViewControllerWithChatDialog:(QBChatDialog *)chatDialog {
    
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:kQMMainStoryboard bundle:nil];
    
    QMChatVC *chatVC =
    [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    
    chatVC.chatDialog = chatDialog;
    
    return chatVC;
}

//MARK: - QMChatViewController data source overrides

- (NSUInteger)senderID {
    return QMCore.instance.currentProfile.userData.ID;
}

- (NSString *)senderDisplayName {
    
    QBUUser *currentUser = QMCore.instance.currentProfile.userData;
    
    return currentUser.fullName ?: [NSString stringWithFormat:@"%tu", currentUser.ID];
}

- (CGFloat)heightForSectionHeader {
    
    return 40.0f;
}

//MARK: - Life cycle

- (void)dealloc {
    
    [QMCore.instance.openGraphService cancelAllloads];
    // -dealloc
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    
    // removing left bar button item that is responsible for split view
    // display mode managing. Not removing it will cause item update
    // for deallocated navigation item
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [QMChatCell registerMenuAction:@selector(share)];
    UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"QM_STR_SHARE", nil)
                                                       action:@selector(share)];
    [UIMenuController sharedMenuController].menuItems = @[shareItem];
    
    self.navigationItem.titleView = self.onlineTitleView;
    
    if (iosMajorVersion() >= 10) {
        self.collectionView.prefetchingEnabled = NO;
    }
    
#ifdef __IPHONE_11_0
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
#endif
    
    self.collectionView.collectionViewLayout.minimumLineSpacing = 8.0f;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    // setting up chat controller
    if (self.splitViewController.isCollapsed &&
        [self.navigationController isKindOfClass:[QMNavigationController class]]) {
        
        QMNavigationController *navController = (QMNavigationController *)self.navigationController;
        if (navController.currentAdditionalNavigationBarHeight > 0) {
            _additionalNavigationBarHeight = navController.currentAdditionalNavigationBarHeight;
        }
    }
    
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"QM_STR_INPUTTOOLBAR_PLACEHOLDER", nil);
    self.view.backgroundColor = QMChatBackgroundColor();
    
    // setting up properties
    self.detailedCells = [NSMutableSet set];
    self.statusStringBuilder = [[QMStatusStringBuilder alloc] init];
    
    self.mediaController = [[QMMediaController alloc] initWithViewController:self];
    
    @weakify(self);
    
    [self.mediaController setOnError:^(QBChatMessage *__unused message, NSError *error) {
        
        @strongify(self);
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:error.localizedRecoverySuggestion duration:kQMDefaultNotificationDismissTime];
    }];
    
    // subscribing to delegates
    [QMCore.instance.chatService addDelegate:self];
    [QMCore.instance.contactListService addDelegate:self];
    [QMCore.instance.chatService.chatAttachmentService addDelegate:self.mediaController];
    [QMCore.instance.openGraphService addDelegate:self];
    [QMCore.instance.callManager addDelegate:self];
    [QMCore.instance.usersService addDelegate:self];
    
    [self.deferredQueueManager addDelegate:self];
    
    self.actionsHandler = self;
    // text checking types for cells
    self.enableTextCheckingTypes = (NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber);
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        // set up opponent full name
        [self.onlineTitleView setTitle:[QMCore.instance.contactManager fullNameForUserID:[self.chatDialog opponentID]]];
        [self updateOpponentOnlineStatus];
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
            [self updateOpponentOnlineStatus];
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
    if (self.storedMessages.count > 0 && self.chatDataSource.messagesCount == 0) {
        
        [self.chatDataSource addMessages:self.storedMessages];
    }
    
    // load messages from cache if needed and from REST
    [self refreshMessages];
    
    self.inputToolbar.audioRecordingEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigationBarHeightChanged)
                                                 name:kQMNavigationBarHeightChangeNotification
                                               object:nil];
    
    self.topContentAdditionalInset = _additionalNavigationBarHeight;
    
    self.messagesToRead = [NSMutableSet set];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    QMCore.instance.activeDialogID = self.chatDialog.ID;
    
    @weakify(self);
    self.observerWillResignActive =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull __unused note)
     {
         @strongify(self);
         
         [[QMAudioPlayer audioPlayer] pause];
         [self stopTyping];
         [self destroyAudioRecorder];
         [self.inputToolbar cancelAudioRecording];
         
         if (self.chatDialog.type == QBChatDialogTypePrivate) {
             [self setOpponentOnlineStatus:NO];
         }
     }];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.chatDialog == nil) {
        return;
    }
    
    QMCore.instance.activeDialogID = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerWillResignActive];
    // Delete blocks.
    [self.chatDialog clearTypingStatusBlocks];
    [self.chatDialog clearDialogOccupantsStatusBlock];
    //Cancel audio recording
    [self finishAudioRecording];
    [self.inputToolbar cancelAudioRecording];
    //Stop player
    [[QMAudioPlayer audioPlayer] stop];
}

// MARK: - Notification

- (void)navigationBarHeightChanged {
    self.additionalNavigationBarHeight = [(QMNavigationController *)self.navigationController currentAdditionalNavigationBarHeight];
}

//MARK: - Deferred queue management

- (void)deferredQueueManager:(QMDeferredQueueManager *)__unused queueManager
        didAddMessageLocally:(QBChatMessage *)addedMessage {
    
    if ([addedMessage.dialogID isEqualToString:self.chatDialog.ID]) {
        
        [self.chatDataSource addMessage:addedMessage];
    }
}

- (void)deferredQueueManager:(QMDeferredQueueManager *)__unused queueManager
     didUpdateMessageLocally:(QBChatMessage *)updatedMessage {
    
    [self.chatDataSource updateMessage:updatedMessage];
}

- (id<QMMediaViewDelegate>)viewForMessage:(QBChatMessage *)message {
    
    NSIndexPath *indexPath = [self.chatDataSource indexPathForMessage:message];
    NSArray *visibleIndexPathes = [self.collectionView indexPathsForVisibleItems];
    BOOL hasPath = [visibleIndexPathes containsObject:indexPath];
    id cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell && hasPath) {
        NSParameterAssert(NO);
    }
    
    return cell;
}

- (NSString *)dialogID {
    
    return self.chatDialog.ID;
}

- (void)didUpdateMessage:(QBChatMessage *)message {
    
    if ([self.chatDialog.ID isEqualToString:message.dialogID]) {
        [self.chatDataSource updateMessage:message];
    }
}

//MARK: - Helpers & Utility

- (void)updateOpponentOnlineStatus {
    
    BOOL isOnline = [QMCore.instance.contactManager isUserOnlineWithID:[self.chatDialog opponentID]];
    [self setOpponentOnlineStatus:isOnline];
}

- (NSArray *)storedMessages {
    
    return [QMCore.instance.chatService.messagesMemoryStorage messagesWithDialogID:self.chatDialog.ID];
}

- (QMDeferredQueueManager *)deferredQueueManager {
    
    return QMCore.instance.chatService.deferredQueueManager;
}

- (void)refreshMessages {
    
    @weakify(self);
    // Retrieving message from Quickblox REST history and cache.
    [QMCore.instance.chatService messagesWithChatDialogID:self.chatDialog.ID
                                           iterationBlock:^(QBResponse * __unused response,
                                                            NSArray *messages,
                                                            BOOL * __unused stop)
     {
         @strongify(self);
         if (messages.count > 0) {
             [self.chatDataSource addMessages:messages];
         }
     }];
}

- (void)readMessage:(QBChatMessage *)message {
    
    if (message.senderID != self.senderID && ![message.readIDs containsObject:@(self.senderID)]) {
        
        //Message could be read only if the chat is connected
        if (QBChat.instance.isConnected) {
            
            [[QMCore.instance.chatService readMessage:message] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                
                if (task.isFaulted) {
                    ILog(@"Problems while marking message as read! Error: %@", task.error);
                }
                else if (task.isCompleted) {
                    
                    [self.messagesToRead removeObject:message];
                    
                    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
                        [UIApplication sharedApplication].applicationIconBadgeNumber--;
                    }
                }
                return nil;
            }];
        }
        else {
            [self.messagesToRead addObject:message];
        }
    }
}

- (BOOL)connectionExists {
    
    if (![QMCore.instance isInternetConnected]) {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning
                                                                              message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil)
                                                                             duration:kQMDefaultNotificationDismissTime];
        return NO;
    }
    
    if (![QBChat instance].isConnected) {
        
        if (QBChat.instance.isConnecting) {
            
            [(QMNavigationController *)self.navigationController shake];
        }
        else {
            
            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil)
                            actionSuccess:NO
                         inViewController:self];
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL)messageSendingAllowed {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        if (![QMCore.instance.contactManager isFriendWithUserID:[self.chatDialog opponentID]]) {
            
            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_SEND_MESSAGES", nil)
                            actionSuccess:NO
                         inViewController:self];
            return NO;
        }
    }
    
    
    return [self.deferredQueueManager shouldSendMessagesInDialogWithID:self.chatDialog.ID];
}

- (BOOL)callsAllowed {
    
    if (![self connectionExists]) {
        
        return NO;
    }
    
    if (![QMCore.instance.contactManager isFriendWithUserID:[self.chatDialog opponentID]]) {
        
        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil)
                        actionSuccess:NO
                     inViewController:self];
        return NO;
    }
    
    return YES;
}

//MARK:- Toolbar actions

//MARK: QMInputToolbarDelegate

- (BOOL)messagesInputToolbarAudioRecordingShouldStart:(QMInputToolbar *)__unused toolbar {
    
    BOOL recordingIsEnabled = NO;
    
    if ([self messageSendingAllowed]) {
        
        if ([[AVAudioSession sharedInstance] recordPermission] == AVAudioSessionRecordPermissionGranted) {
            recordingIsEnabled = YES;
        }
        else {
            [self requestForRecordPermissions];
        }
    }
    
    return recordingIsEnabled;
}

- (void)requestForRecordPermissions {
    
    [QMPermissions requestPermissionToMicrophoneWithCompletion:^(BOOL granted) {
        // showing error alert with a suggestion
        // to go to the settings
        if (!granted) {
            [self showAlertWithTitle:NSLocalizedString(@"QM_STR_MICROPHONE_ERROR", nil)
                             message:NSLocalizedString(@"QM_STR_NO_PERMISSIONS_TO_MICROPHONE", nil)];
        }
    }];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_SETTINGS", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)messagesInputToolbarAudioRecordingStart:(QMInputToolbar *)__unused toolbar {
    
    [self startAudioRecording];
}

- (void)messagesInputToolbarAudioRecordingCancel:(QMInputToolbar *)__unused toolbar {
    
    [self cancellAudioRecording];
}

- (void)messagesInputToolbarAudioRecordingComplete:(QMInputToolbar *)__unused toolbar {
    
    [self finishAudioRecording];
}

- (void)messagesInputToolbarAudioRecordingPausedByTimeOut:(QMInputToolbar *)__unused toolbar {
    
    if (self.currentAudioRecorder != nil) {
        [self.currentAudioRecorder pauseRecording];
    }
}

- (NSTimeInterval)inputPanelAudioRecordingMaximumDuration:(QMInputToolbar *)__unused toolbar {
    
    return self.currentAudioRecorder.maximumDuration;
}

- (NSTimeInterval)inputPanelAudioRecordingDuration:(QMInputToolbar *)__unused toolbar {
    
    if (self.currentAudioRecorder != nil) {
        return [self.currentAudioRecorder currentTime];
    }
    
    return 0.0;
}

- (void)startAudioRecording {
    
    NSParameterAssert(!self.currentAudioRecorder);
    
    [[QMAudioPlayer audioPlayer] pause];
    
    self.currentAudioRecorder = [[QMAudioRecorder alloc] init];
    [self.currentAudioRecorder startRecordingForDuration:kQMMaxAttachmentDuration];
    
    @weakify(self);
    
    self.currentAudioRecorder.cancellBlock = ^{
        @strongify(self);
        [self destroyAudioRecorder];
    };
    
    self.currentAudioRecorder.completionBlock = ^(NSURL *fileURL, NSTimeInterval duration, NSError *error) {
        @strongify(self);
        
        if (fileURL && !error) {
            QBChatAttachment *attachment = [QBChatAttachment audioAttachmentWithFileURL:fileURL];
            attachment.duration = lround(duration);
            [self sendMessageWithAttachment:attachment];
        }
        else {
            [self.inputToolbar shakeControls];
        }
        
        [self destroyAudioRecorder];
    };
    
    [[UIScreen mainScreen] qm_lockCurrentOrientation];
}

- (void)cancellAudioRecording {
    
    if (self.currentAudioRecorder != nil) {
        
        [[UIScreen mainScreen] qm_unlockCurrentOrientation];
        [self.currentAudioRecorder cancelRecording];
    }
}

- (void)finishAudioRecording {
    
    if (self.currentAudioRecorder != nil) {
        
        [[UIScreen mainScreen] qm_unlockCurrentOrientation];
        [self.currentAudioRecorder stopRecording];
    }
}

- (void)destroyAudioRecorder {
    
    if (self.currentAudioRecorder != nil) {
        
        [[UIScreen mainScreen] qm_unlockCurrentOrientation];
        self.currentAudioRecorder = nil;
    }
}

- (NSUInteger)inputToolBarStartPos {
    return 0;
}

- (void)didPressSendButton:(UIButton *)__unused button
       withTextAttachments:(NSArray *)textAttachments
                  senderId:(NSUInteger)__unused senderId
         senderDisplayName:(NSString *)__unused senderDisplayName
                      date:(NSDate *)__unused date {
    
    UIImage *attachmentImage = [(NSTextAttachment *)textAttachments.firstObject image];
    
    if (attachmentImage) {
        
        [self sendAttachmentMessageWithImage:attachmentImage];
        [self finishSendingMessageAnimated:YES];
    }
    
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)__unused senderDisplayName
                      date:(NSDate *)date {
    
    if (self.typingTimer != nil) {
        [self stopTyping];
    }
    
    if (![self messageSendingAllowed]) {
        [button qm_shake];
        return;
    }
    
    QBChatMessage *message = [QMMessagesHelper chatMessageWithText:text
                                                          senderID:senderId
                                                      chatDialogID:self.chatDialog.ID
                                                          dateSent:date];
    // Sending message
    [self _sendMessage:message];
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    
    if (![self messageSendingAllowed]) {
        [sender qm_shake];
        return;
    }
    
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_MEDIA", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    
                                    [QMImagePicker takePhotoOrVideoInViewController:self
                                                                        maxDuration:kQMMaxAttachmentDuration
                                                                            quality:UIImagePickerControllerQualityTypeMedium
                                                                      resultHandler:self
                                                                      allowsEditing:NO];
                                }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_MEDIA", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    
                                    [QMImagePicker chooseFromGaleryInViewController:self
                                                                        maxDuration:kQMMaxAttachmentDuration
                                                                      resultHandler:self
                                                                      allowsEditing:NO];
                                }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOCATION", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    
                                    QMLocationViewController *locationVC =
                                    [[QMLocationViewController alloc] initWithState:QMLocationVCStateSend];
                                    
                                    [locationVC setSendButtonPressed:^(CLLocationCoordinate2D centerCoordinate) {
                                        [self _sendLocationMessage:centerCoordinate];
                                    }];
                                    
                                    UINavigationController *navController =
                                    [[UINavigationController alloc] initWithRootViewController:locationVC];
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

//MARK: - Cells view classes

- (Class)viewClassForItem:(QBChatMessage *)message {
    
    if ([message isLocationMessage]) {
        
        return message.senderID == self.senderID ? QMChatLocationOutgoingCell.class : QMChatLocationIncomingCell.class;
    }
    else if ([message isNotificationMessage] || [message isCallNotificationMessage] || message.isDateDividerMessage) {
        
        NSUInteger opponentID = [self.chatDialog opponentID];
        BOOL isFriend = [QMCore.instance.contactManager isFriendWithUserID:opponentID];
        
        if (message.messageType == QMMessageTypeContactRequest && message.senderID != self.senderID && !isFriend) {
            
            QBChatMessage *lastMessage = [QMCore.instance.chatService.messagesMemoryStorage lastMessageFromDialogID:self.chatDialog.ID];
            
            if ([lastMessage isEqual:message]) {
                
                return QMChatContactRequestCell.class;
            }
        }
        
        return QMChatNotificationCell.class;
    }
    else {
        
        BOOL isIncomingMessage = message.senderID != self.senderID;
        
        if ([message isMediaMessage]) {
            
            if ([message isVideoAttachment]) {
                return  isIncomingMessage ? QMVideoIncomingCell.class : QMVideoOutgoingCell.class;
            }
            else if ([message isAudioAttachment]) {
                return  isIncomingMessage ? QMAudioIncomingCell.class : QMAudioOutgoingCell.class;
                
            }
            else if ([message isImageAttachment]) {
                return  isIncomingMessage ? QMImageIncomingCell.class : QMImageOutgoingCell.class;
            }
            else {
                return isIncomingMessage ? QMChatAttachmentIncomingCell.class : QMChatAttachmentOutgoingCell.class;
            }
        }
        else {
            if (QMCore.instance.openGraphService.memoryStorage[message.ID] != nil) {
                return isIncomingMessage ? QMChatIncomingLinkPreviewCell.class :  QMChatOutgoingLinkPreviewCell.class;
            }
            return isIncomingMessage ? QMChatIncomingCell.class : QMChatOutgoingCell.class;
        }
    }
    
    NSAssert(nil, @"Unexpected cell class");
    return nil;
}

//MARK: - Attributed strings

- (NSAttributedString *)attributedStringForItem:(QBChatMessage *)messageItem {
    
    NSString *message = nil;
    UIColor *textColor = nil;
    UIFont *font = nil;
    UIImage *iconImage = nil;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    if ([messageItem isNotificationMessage] || messageItem.isDateDividerMessage) {
        
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        message = [self.statusStringBuilder messageTextForNotification:messageItem];
        
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
            
            textColor = [UIColor colorWithRed:119.f / 255
                                        green:133.f / 255
                                         blue:148.f /255
                                        alpha:1];
            
            font = [UIFont systemFontOfSize:13.0f];
        }
    }
    else if ([messageItem isCallNotificationMessage]) {
        
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        font = [UIFont systemFontOfSize:13.0f];
        
        if (messageItem.callNotificationState == QMCallNotificationStateMissedNoAnswer) {
            textColor = [UIColor whiteColor];
        }
        else {
            textColor = [UIColor colorWithRed:119.f / 255
                                        green:133.f / 255
                                         blue:148.f /255
                                        alpha:1];
        }
        QMCallNotificationItem *callNotificationItem = [[QMCallNotificationItem alloc] initWithCallNotificationMessage:messageItem];
        
        message = callNotificationItem.notificationText;
        iconImage = callNotificationItem.iconImage;
    }
    else {
        
        message = messageItem.text;
        textColor = messageItem.senderID == self.senderID ? [UIColor whiteColor] : [UIColor blackColor];
        font = [UIFont systemFontOfSize:17.0f];
    }
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName:textColor,
                                  NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle };
    
    NSAttributedString *attributedString = nil;
    
    if (iconImage != nil) {
        
        NSString *messageText = message.length > 0 ? [NSString stringWithFormat:@"%@%@", kQMTextAttachmentSpacing, message] : kQMTextAttachmentSpacing;
        NSMutableAttributedString *mutableAttrStr = [[NSMutableAttributedString alloc] initWithString:messageText attributes:attributes];
        
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = iconImage;
        textAttachment.bounds = CGRectOfSize(iconImage.size);
        
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [mutableAttrStr insertAttributedString:attrStringWithImage atIndex:0];
        
        attributedString = [mutableAttrStr copy];
    }
    else {
        
        attributedString = [[NSAttributedString alloc] initWithString:message ?: @"" attributes:attributes];
    }
    
    return attributedString;
}

- (NSAttributedString *)topLabelAttributedStringForItem:(QBChatMessage *)messageItem {
    
    if (messageItem.senderID == self.senderID || self.chatDialog.type == QBChatDialogTypePrivate || [messageItem isAudioAttachment]) {
        
        return nil;
    }
    
    UIFont *font = [UIFont systemFontOfSize:15.0f];
    
    QBUUser *opponentUser = [QMCore.instance.usersService.usersMemoryStorage userWithID:messageItem.senderID];
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
    NSDictionary *attributes = @{NSForegroundColorAttributeName:textColor, NSFontAttributeName:font};
    
    NSString* text = messageItem.dateSent ? [QMDateUtils formatDateForTimeRange:messageItem.dateSent] : @"";
    
    if (messageItem.senderID == self.senderID) {
        text =
        [NSString stringWithFormat:@"%@\n%@", text, [self.statusStringBuilder statusFromMessage:messageItem
                                                                                  forDialogType:self.chatDialog.type]];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text
                                                                                         attributes:attributes];
    
    return attributedString;
}

//MARK: - Collection View Datasource

- (CGSize)collectionView:(QMChatCollectionView *)__unused collectionView
  dynamicSizeAtIndexPath:(NSIndexPath *)indexPath
                maxWidth:(CGFloat)maxWidth {
    
    QBChatMessage *item = [self.chatDataSource messageForIndexPath:indexPath];
    Class viewClass = [self viewClassForItem:item];
    CGSize size = CGSizeZero;
    
    if (viewClass == [QMAudioIncomingCell class]
        || viewClass == [QMAudioOutgoingCell class]) {
        
        size = CGSizeMake(MIN(kQMAttachmentCellSize, maxWidth), 35);
    }
    else if (viewClass == [QMVideoIncomingCell class]
             || viewClass == [QMVideoOutgoingCell class]) {
        
        size = [self videoSizeForMessage:item];
    }
    else if (viewClass == [QMChatAttachmentIncomingCell class]
             || viewClass == [QMChatLocationIncomingCell class]
             || viewClass == [QMImageIncomingCell class]
             || viewClass == [QMChatAttachmentOutgoingCell class]
             || viewClass == [QMChatLocationOutgoingCell class]
             || viewClass == [QMImageOutgoingCell class]) {
        
        size = CGSizeMake(MIN(kQMAttachmentCellSize, maxWidth), kQMAttachmentCellSize);
    }
    else if (viewClass == [QMChatNotificationCell class]) {
        
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        
        if ([attributedString respondsToSelector:@selector(boundingRectWithSize:options:context:)]) {
            
            size =
            [attributedString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           context:nil].size;
        }
    }
    else if ([viewClass isSubclassOfClass:[QMChatBaseLinkPreviewCell class]]) {
        
        QMOpenGraphItem *og = QMCore.instance.openGraphService.memoryStorage[item.ID];
        
        CGFloat linkPreviewHeight = 0;
        
        NSAttributedString *attributedString = [self attributedStringForItem:item];
        CGSize textSize = [TTTAttributedLabel sizeThatFitsAttributedString:attributedString
                                                           withConstraints:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                                    limitedToNumberOfLines:0];
        
        CGSize urlDescriptionSize =
        [og.siteDescription boundingRectWithSize:CGSizeMake(MAX(textSize.width, 200) , CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
                                         context:nil].size;
        
        textSize.width = MAX(textSize.width, urlDescriptionSize.width);
        
        UIImage *image = [QMImageLoader.instance.imageCache imageFromCacheForKey:og.imageURL];
        
        if (image) {
            
            const CGFloat oldWidth = image.size.width;
            const CGFloat scaleFactor = textSize.width / oldWidth;
            
            if (scaleFactor < 1) {
                linkPreviewHeight = MIN(image.size.height * scaleFactor, 200);
            }
            else {
                linkPreviewHeight = MIN(image.size.height, 200);
            }
        }
        
        textSize.height += (urlDescriptionSize.height + linkPreviewHeight + 23) ;
        size = textSize;
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
    
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    CGSize size = CGSizeZero;
    
    if ([self.detailedCells containsObject:message.ID]) {
        
        size =
        [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:message]
                                         withConstraints:CGSizeMake(CGRectGetWidth(collectionView.frame) - kQMWidthPadding,
                                                                    CGFLOAT_MAX)
                                  limitedToNumberOfLines:0];
    }
    
    if (self.chatDialog.type != QBChatDialogTypePrivate) {
        
        CGSize topLabelSize =
        [TTTAttributedLabel sizeThatFitsAttributedString:[self topLabelAttributedStringForItem:message]
                                         withConstraints:CGSizeMake(CGRectGetWidth(collectionView.frame) - kQMWidthPadding,
                                                                    CGFLOAT_MAX)
                                  limitedToNumberOfLines:1];
        
        if (topLabelSize.width > size.width) {
            
            size = topLabelSize;
        }
    }
    
    return size.width;
}

- (CGSize)videoSizeForMessage:(QBChatMessage *)message {
    
    QBChatAttachment *attachment = message.attachments.firstObject;
    
    CGSize size = CGSizeMake(180.0, 95.0); //default video size for cell
    
    if (!CGSizeEqualToSize(CGSizeMake(attachment.width, attachment.height),
                           CGSizeZero)) {
        
        BOOL isVerticalVideo = attachment.width < attachment.height;
        
        size = isVerticalVideo ? CGSizeMake(95.0, 180.0) : size;
    }
    
    return size;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    
    Class viewClass = [self viewClassForItem:[self.chatDataSource messageForIndexPath:indexPath]];
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    //allow action performing only for image attachments
    if (message.isMediaMessage) {
        
        BOOL canPerformAction =
        message.isImageAttachment &&
        (action == @selector(copy:) ||
         action == @selector(share));
        
        return canPerformAction;
    }
    // disabling action performing for specific cells
    if (viewClass == [QMChatLocationIncomingCell class]
        || viewClass == [QMChatLocationOutgoingCell class]
        || viewClass == [QMChatNotificationCell class]
        || viewClass == [QMChatContactRequestCell class]) {
        return NO;
    }
    
    return [super collectionView:collectionView
                canPerformAction:action
              forItemAtIndexPath:indexPath
                      withSender:sender];
}


- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender {
    
    //Prevent showing custom menu items for other views
    for (UIMenuItem *item in UIMenuController.sharedMenuController.menuItems) {
        if (item.action == action) {
            return NO;
        }
    }
    
    return [super canPerformAction:action
                        withSender:sender];
}

- (void)chatCell:(QMChatCell *)cell
didPerformAction:(SEL)action
      withSender:(id)__unused sender {
    
    if (action != @selector(share)) {
        return;
    }
    
    NSIndexPath *indexPath =  [self.collectionView indexPathForCell:cell];
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    
    if ([message isImageAttachment]) {
        
        QBChatAttachment *attachment = message.attachments.firstObject;
        UIImage *image =
        [QMImageLoader.instance originalImageWithURL:[attachment remoteURLWithToken:NO]];
        
        if (image) {
            
            UIActivityViewController *activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:@[image]
                                              applicationActivities:nil];
            
            [self displayActivityViewController:activityViewController
                                     withSender:cell
                                       animated:YES];
        }
    }
}

- (void)displayActivityViewController:(UIActivityViewController *)controller
                           withSender:(UIView *)sender
                             animated:(BOOL)animated {
    
    if (controller.popoverPresentationController) {
        // iPad support
        controller.popoverPresentationController.sourceView = sender;
        controller.popoverPresentationController.sourceRect = sender.bounds;
    }
    
    [self presentViewController:controller animated:animated completion:nil];
    
}



- (void)collectionView:(UICollectionView *)__unused collectionView
         performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)__unused sender {
    
    if (action == @selector(copy:)) {
        
        QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
        
        if ([message isImageAttachment]) {
            QBChatAttachment *attachment = message.attachments.firstObject;
            UIImage *image = [QMImageLoader.instance originalImageWithURL:[attachment remoteURLWithToken:NO]];
            if (image) {
                [[UIPasteboard generalPasteboard] setValue:UIImageJPEGRepresentation(image, 1)
                                         forPasteboardType:(NSString *)kUTTypeJPEG];
            }
        }
        else {
            
            [[UIPasteboard generalPasteboard] setString:message.text];
        }
    }
}

- (BOOL)placeHolderTextView:(QMPlaceHolderTextView *)__unused textView
      shouldPasteWithSender:(id)__unused sender {
    
    if ([UIPasteboard generalPasteboard].image) {
        
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [UIPasteboard generalPasteboard].image;
        textAttachment.bounds = CGRectMake(0, 0, 100, 100);
        
        NSAttributedString *attrStringWithImage =
        [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        [self.inputToolbar.contentView.textView setAttributedText:attrStringWithImage];
        [self textViewDidChange:self.inputToolbar.contentView.textView];
        
        return NO;
    }
    
    return YES;
}

//MARK: - QMChatCollectionViewDelegate

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView
                 layoutModelAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatCellLayoutModel layoutModel =
    [super collectionView:collectionView layoutModelAtIndexPath:indexPath];
    
    layoutModel.topLabelHeight = 0.0f;
    layoutModel.maxWidthMarginSpace = 20.0f;
    layoutModel.spaceBetweenTextViewAndBottomLabel = 0;
    layoutModel.spaceBetweenTopLabelAndTextView = 0;
    
    QBChatMessage *item = [self.chatDataSource messageForIndexPath:indexPath];
    Class class = [self viewClassForItem:item];
    
    if (class == [QMChatOutgoingCell class] ||
        class == [QMChatAttachmentOutgoingCell class] ||
        class == [QMChatLocationOutgoingCell class] ||
        [class isSubclassOfClass:[QMMediaOutgoingCell class]] ||
        class == [QMChatOutgoingLinkPreviewCell class]) {
        
        layoutModel.avatarSize = CGSizeZero;
        
        if (class != [QMChatOutgoingCell class]) {
            
            layoutModel.spaceBetweenTextViewAndBottomLabel = 5;
        }
    }
    else if (class == [QMChatAttachmentIncomingCell class]
             || class == [QMChatLocationIncomingCell class]
             || class == [QMChatIncomingCell class]
             || [class isSubclassOfClass: [QMMediaIncomingCell class]]
             || class == [QMChatIncomingLinkPreviewCell class]) {
        
        BOOL isAudioCell =
        class == QMAudioOutgoingCell.class || class == QMAudioIncomingCell.class;
        
        if (self.chatDialog.type != QBChatDialogTypePrivate && !isAudioCell) {
            
            layoutModel.topLabelHeight = 18;
        }
        
        if (class != [QMChatIncomingCell class]) {
            
            layoutModel.spaceBetweenTextViewAndBottomLabel = 5;
            layoutModel.spaceBetweenTopLabelAndTextView = 5;
        }
        
        layoutModel.avatarSize = CGSizeMake(kQMAvatarSize, kQMAvatarSize);
    }
    
    CGSize size = CGSizeZero;
    
    if ([self.detailedCells containsObject:item.ID]
        || class == [QMChatAttachmentIncomingCell class]
        || class == [QMChatAttachmentOutgoingCell class]
        || class == [QMChatLocationIncomingCell class]
        || class == [QMChatLocationOutgoingCell class]
        || class == [QMVideoIncomingCell class]
        || class == [QMVideoOutgoingCell class]
        || class == [QMImageOutgoingCell class]
        || class == [QMImageIncomingCell class]
        || class == [QMChatIncomingLinkPreviewCell class]
        || class == [QMChatOutgoingLinkPreviewCell class]) {
        
        CGSize constraintsSize =
        CGSizeMake(CGRectGetWidth(self.collectionView.frame) - kQMWidthPadding, CGFLOAT_MAX);
        
        size =
        [TTTAttributedLabel sizeThatFitsAttributedString:[self bottomLabelAttributedStringForItem:item]
                                         withConstraints:constraintsSize
                                  limitedToNumberOfLines:0];
    }
    
    layoutModel.bottomLabelHeight = (CGFloat)ceil(size.height);
    
    return layoutModel;
}

- (void)collectionView:(QMChatCollectionView *)collectionView
         configureCell:(UICollectionViewCell *)cell
          forIndexPath:(NSIndexPath *)indexPath {
    
    [super collectionView:collectionView configureCell:cell forIndexPath:indexPath];
    
    QMChatCell *currentCell = (QMChatCell *)cell;
    
    currentCell.delegate = self;
    currentCell.containerView.highlightColor = QMChatCellHighlightedColor();
    
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    
    if ([cell isKindOfClass:[QMChatOutgoingCell class]]
        || [cell isKindOfClass:[QMChatAttachmentOutgoingCell class]]
        || [cell isKindOfClass:[QMChatLocationOutgoingCell class]]
        || [cell isKindOfClass:[QMMediaOutgoingCell class]]
        || [cell isKindOfClass:[QMChatOutgoingLinkPreviewCell class]]) {
        
        currentCell.containerView.bgColor = QMChatOutgoingCellColor();
        currentCell.containerView.highlightColor = QMChatCellOutgoingHighlightedColor();
        
        QMMessageStatus status = [self.deferredQueueManager statusForMessage:message];
        switch (status) {
                
            case QMMessageStatusSent:
                currentCell.containerView.bgColor = QMChatOutgoingCellColor();
                break;
                
            case QMMessageStatusSending:
                currentCell.containerView.bgColor = QMChatOutgoingCellSendingColor();
                break;
                
            case QMMessageStatusNotSent:
                currentCell.containerView.bgColor = QMChatOutgoingCellFailedColor();
                break;
        }
        
        currentCell.textView.linkAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                NSUnderlineStyleAttributeName : @(YES)};
    }
    else if ([cell isKindOfClass:[QMChatIncomingCell class]]
             || [cell isKindOfClass:[QMChatAttachmentIncomingCell class]]
             || [cell isKindOfClass:[QMChatLocationIncomingCell class]]
             || [cell isKindOfClass:[QMMediaIncomingCell class]]
             || [cell isKindOfClass:[QMChatIncomingLinkPreviewCell class]]) {
        
        currentCell.containerView.highlightColor = QMChatCellIncomingHighlightedColor();
        currentCell.containerView.bgColor = QMChatIncomingCellColor();
        currentCell.textView.linkAttributes = @{NSForegroundColorAttributeName : QMChatIncomingLinkColor(),
                                                NSUnderlineStyleAttributeName : @(YES)};
        //Setting opponent avatar
        QBUUser *sender = [QMCore.instance.usersService.usersMemoryStorage
                           userWithID:message.senderID];
        
        QMImageView *avatarView = [(QMChatCell *)cell avatarView];
        NSURL *userImageUrl = [NSURL URLWithString:sender.avatarUrl];
        
        [avatarView setImageWithURL:userImageUrl
                              title:sender.fullName
                     completedBlock:nil];
    }
    else if ([cell isKindOfClass:[QMChatNotificationCell class]]) {
        
        currentCell.userInteractionEnabled = NO;
        
        if (message.callNotificationState == QMCallNotificationStateMissedNoAnswer) {
            
            currentCell.containerView.bgColor = QMChatRedNotificationCellColor();
        }
        else {
            
            currentCell.containerView.bgColor = QMChatNotificationCellColor();
        }
        
    }
    else if ([cell isKindOfClass:[QMChatContactRequestCell class]]) {
        
        currentCell.containerView.bgColor = [UIColor whiteColor];
        currentCell.layer.cornerRadius = 8;
        currentCell.clipsToBounds = YES;
    }
    
    if ([cell isKindOfClass:[QMChatBaseLinkPreviewCell class]]) {
        
        QMOpenGraphItem *og = QMCore.instance.openGraphService.memoryStorage[message.ID];
        
        QMChatBaseLinkPreviewCell *previewCell = (QMChatBaseLinkPreviewCell *)cell;
        //TODO: add transform
        UIImage *preview = [QMImageLoader.instance.imageCache imageFromCacheForKey:og.imageURL];
        UIImage *favicon = [QMImageLoader.instance.imageCache imageFromCacheForKey:og.faviconUrl];
        
        [previewCell setSiteURL:og.baseUrl
                 urlDescription:og.siteDescription
                   previewImage:preview
                        favicon:favicon];
    }
    
    if ([cell conformsToProtocol:@protocol(QMChatLocationCell)]) {
        
        [[(id<QMChatLocationCell>)cell imageView]
         setSnapshotWithLocationCoordinate:message.locationCoordinate];
    }
    else if ([cell conformsToProtocol:@protocol(QMMediaViewDelegate)]) {
        
        [self.mediaController configureView:(id<QMMediaViewDelegate>)cell
                                withMessage:message];
    }
    
    if ([cell isKindOfClass:[QMChatIncomingCell class]] ||
        [cell isKindOfClass:[QMChatOutgoingCell class]]) {
        
        [QMCore.instance.openGraphService preloadGraphItemForText:message.text ID:message.ID];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)__unused cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == [collectionView numberOfItemsInSection:0] - 1) {
        // first message
        // load more if exists
        // Getting earlier messages for chat dialog identifier.
        [[QMCore.instance.chatService loadEarlierMessagesWithChatDialogID:self.chatDialog.ID]
         continueWithBlock:^id(BFTask<NSArray<QBChatMessage *> *> *task) {
             
             if (task.result.count > 0) {
                 [self.chatDataSource addMessages:task.result];
             }
             
             return nil;
         }];
    }
    
    // marking message as read if needed
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    
    [self readMessage:message];
    
    // getting users if needed
    QBUUser *sender = [QMCore.instance.usersService.usersMemoryStorage userWithID:message.senderID];
    if (sender == nil) {
        
        [[QMCore.instance.usersService getUserWithID:message.senderID]
         continueWithSuccessBlock:^id(BFTask<QBUUser *> * __unused task) {
             
             [self.chatDataSource updateMessage:message];
             
             return nil;
         }];
    }
}

//MARK: - Typing status

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

//MARK: - Actions

- (void)performInfoViewControllerForUserID:(NSUInteger)userID {
    
    QBUUser *opponentUser = [QMCore.instance.usersService.usersMemoryStorage userWithID:userID];
    
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
    //  [self.view endEditing:YES];
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUserInfo]) {
        
        QMUserInfoViewController *userInfoVC = segue.destinationViewController;
        userInfoVC.user = sender;
    }
    else if ([segue.identifier isEqualToString:KQMSceneSegueGroupInfo]) {
        
        QMGroupInfoViewController *groupInfoVC = segue.destinationViewController;
        groupInfoVC.chatDialog = sender;
    }
    
    if (self.inputToolbar.contentView.textView.isFirstResponder) {
        [self.inputToolbar.contentView.textView resignFirstResponder];
    }
}

- (void)audioCallAction {
    
    if (![self callsAllowed]) {
        
        return;
    }
    
    [QMCore.instance.callManager callToUserWithID:[self.chatDialog opponentID]
                                   conferenceType:QBRTCConferenceTypeAudio];
}

- (void)videoCallAction {
    
    if (![self callsAllowed]) {
        
        return;
    }
    
    [QMCore.instance.callManager callToUserWithID:[self.chatDialog opponentID]
                                   conferenceType:QBRTCConferenceTypeVideo];
}

- (void)_sendLocationMessage:(CLLocationCoordinate2D)locationCoordinate {
    
    QBChatMessage *message = [QMMessagesHelper chatMessageWithText:kQMLocationNotificationMessage
                                                          senderID:self.senderID
                                                      chatDialogID:self.chatDialog.ID
                                                          dateSent:[NSDate date]];
    
    message.locationCoordinate = locationCoordinate;
    
    [self _sendMessage:message];
}

- (void)_sendMessage:(QBChatMessage *)message {
    
    [[QMCore.instance.chatService sendMessage:message
                                     toDialog:self.chatDialog
                                saveToHistory:YES
                                saveToStorage:YES]
     continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
         
         [QMSoundManager playMessageSentSound];
         return nil;
     }];
}

- (void)sendMessageWithAttachment:(QBChatAttachment *)attachment {
    
    NSString *messageText =
    [NSString stringWithFormat:@"%@ attachment",
     attachment.type.capitalizedString];
    
    QBChatMessage *message = [QMMessagesHelper chatMessageWithText:messageText
                                                        attachment:attachment
                                                          senderID:self.senderID
                                                      chatDialogID:self.chatDialog.ID
                                                          dateSent:[NSDate date]];
    [self.chatDataSource addMessage:message];
    [QMCore.instance.chatService sendAttachmentMessage:message
                                              toDialog:self.chatDialog
                                        withAttachment:attachment
                                            completion:nil];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didDeleteMessagesFromMemoryStorage:(nonnull NSArray<QBChatMessage *> *)messages forDialogID:(nonnull NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        [self.chatDataSource deleteMessages:messages];
    }
}

- (void)sendAttachmentMessageWithImage:(UIImage *)image {
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        UIImage *resizedImage = [self resizedImageFromImage:image];
        
        // Sending attachment to dialog.
        dispatch_async(dispatch_get_main_queue(), ^{
            QBChatAttachment *attachment = [QBChatAttachment imageAttachmentWithImage:resizedImage];
            [self sendMessageWithAttachment:attachment];
        });
    });
}

- (void)handleNotSentMessage:(QBChatMessage *)notSentMessage {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"QM_STR_MESSAGE_DIDNT_SEND", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TRY_AGAIN", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [self.deferredQueueManager perfromDefferedActionForMessage:notSentMessage withCompletion:nil];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [self.chatDataSource deleteMessage:notSentMessage];
                                                          [self.deferredQueueManager removeMessage:notSentMessage];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateGroupAvatarFrameForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    CGFloat defaultSize = 0;
    
    switch (interfaceOrientation) {
            
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            
            defaultSize = 36.0f;
            break;
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            
            defaultSize = 28.0f;
            break;
            
        case UIInterfaceOrientationUnknown:
            break;
    }
    
    self.imageBarButtonItem.size = CGSizeMake(defaultSize, defaultSize);
}

//MARK: - Configuring

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
    
    self.imageBarButtonItem = [[QMImageBarButtonItem alloc] init];
    
    __weak typeof(self) weakSelf = self;
    void(^onTapBlock)(QMImageView *) = ^(QMImageView __unused *imageView) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf performSegueWithIdentifier:KQMSceneSegueGroupInfo sender:strongSelf.chatDialog];
    };
    
    self.imageBarButtonItem.onTapHandler = onTapBlock;
    
    self.navigationItem.rightBarButtonItem = self.imageBarButtonItem;
    
    [self updateGroupAvatarFrameForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    [self updateGroupAvatarImage];
}

- (void)updateGroupAvatarImage {
    
    NSURL *avatarURL = [NSURL URLWithString:self.chatDialog.photo];
    [self.imageBarButtonItem setImageWithURL:avatarURL
                                       title:self.chatDialog.name];
}

- (void)updateGroupChatOnlineStatus {
    // chat status string
    @weakify(self);
    [self.chatDialog requestOnlineUsersWithCompletionBlock:^(NSMutableArray<NSNumber *> *onlineUsers, NSError *error) {
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
        
        QBUUser *opponentUser = [QMCore.instance.usersService.usersMemoryStorage userWithID:[self.chatDialog opponentID]];
        
        if (opponentUser) {
            status = [QMCore.instance.contactManager onlineStatusForUser:opponentUser];
        }
    }
    
    [self.onlineTitleView setStatus:status];
}

// MARK: - Overrides

- (void)setAdditionalNavigationBarHeight:(CGFloat)additionalNavigationBarHeight {
    _additionalNavigationBarHeight = additionalNavigationBarHeight;
    self.topContentAdditionalInset = additionalNavigationBarHeight;
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didLoadMessagesFromCache:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        for (QBChatMessage *message in messages) {
            [QMCore.instance.openGraphService preloadGraphItemForText:message.text ID:message.ID];
        }
        [self.chatDataSource addMessages:messages];
    }
}

- (void)chatService:(QMChatService *)__unused chatService
didAddMessageToMemoryStorage:(QBChatMessage *)message
        forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        if (self.chatDialog.type == QBChatDialogTypePrivate
            && [QMMessagesHelper isContactRequestMessage:message]) {
            // check whether contact request message was sent previously
            // in order to reload it and remove buttons for accept and deny
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            QBChatMessage *lastMessage = [self.chatDataSource messageForIndexPath:indexPath];
            if (lastMessage.messageType == QMMessageTypeContactRequest) {
                
                [self.chatDataSource updateMessage:lastMessage];
            }
        }
        
        // Inserting or updating message received from XMPP or sent by self
        if ([self.chatDataSource messageExists:message]) {
            
            [self.chatDataSource updateMessage:message];
        }
        else {
            [self.chatDataSource addMessage:message];
        }
    }
}

- (void)chatService:(QMChatService *)__unused chatService
didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if (self.chatDialog.type != QBChatDialogTypePrivate && [self.chatDialog.ID isEqualToString:chatDialog.ID]) {
        
        [self.onlineTitleView setTitle:self.chatDialog.name];
        [self updateGroupChatOnlineStatus];
        [self updateGroupAvatarImage];
    }
}

- (void)chatService:(QMChatService *)__unused chatService
didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)dialogs {
    
    QBChatDialog *updatedDialog = nil;
    
    for (QBChatDialog *dialog in dialogs) {
        if (self.chatDialog.type != QBChatDialogTypePrivate
            && [self.chatDialog.ID isEqualToString:dialog.ID]) {
            updatedDialog = dialog;
            break;
        }
    }
    
    if (updatedDialog) {
        [self.onlineTitleView setTitle:self.chatDialog.name];
        [self updateGroupChatOnlineStatus];
        [self updateGroupAvatarImage];
    }
}

- (void)chatService:(QMChatService *)__unused chatService
didAddChatDialogsToMemoryStorage:(NSArray<QBChatDialog *> *)chatDialogs {
    
    if (self.chatDialog.type != QBChatDialogTypePrivate && [chatDialogs containsObject:self.chatDialog]) {
        
        [self.onlineTitleView setTitle:self.chatDialog.name];
        [self updateGroupAvatarImage];
    }
}

- (void)chatService:(QMChatService *)__unused chatService
   didUpdateMessage:(QBChatMessage *)message
        forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]
        && message.senderID == self.senderID) {
        
        [self.chatDataSource updateMessage:message];
    }
}

//MARK: - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)__unused chatService {
    
    [self refreshMessages];
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        [self updateOpponentOnlineStatus];
    }
    
    for (QBChatMessage *msg in self.messagesToRead) {
        [self readMessage:msg];
    }
}

- (void)chatServiceChatDidReconnect:(QMChatService *)__unused chatService {
    
    [self refreshMessages];
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        [self updateOpponentOnlineStatus];
    }
    
    for (QBChatMessage *msg in self.messagesToRead) {
        [self readMessage:msg];
    }
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)__unused chatService {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        // chat disconnected, updating title status for user
        
        [self setOpponentOnlineStatus:NO];
    }
}

// MARK: - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)users {
    for (QBUUser *user in users) {
        if (user.ID != [QMCore instance].currentProfile.userData.ID
            && [self.chatDialog.occupantIDs containsObject:@(user.ID)]) {
            [self.collectionView reloadData];
            break;
        }
    }
}

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)users {
    if (self.chatDialog.type != QBChatDialogTypePrivate) {
        return;
    }
    
    for (QBUUser *user in users) {
        if (user.ID == self.chatDialog.opponentID) {
            [self updateOpponentOnlineStatus];
            break;
        }
    }
}

//MARK: - Contact List Service Delegate

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate
        && !self.isOpponentTyping) {
        [self updateOpponentOnlineStatus];
    }
}

//MARK: QMChatActionsHandler protocol

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender {
    
    if (self.contactRequestTask) {
        // task in progress
        return;
    }
    
    QBUUser *opponentUser = [QMCore.instance.usersService.usersMemoryStorage userWithID:[self.chatDialog opponentID]];
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    if (accept) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        QBChatMessage *currentMessage = [self.chatDataSource messageForIndexPath:indexPath];
        
        __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
        
        @weakify(self);
        self.contactRequestTask = [[QMCore.instance.contactManager addUserToContactList:opponentUser]
                                   continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                                       
                                       @strongify(self);
                                       [navigationController dismissNotificationPanel];
                                       
                                       if (!task.isFaulted) {
                                           [self.chatDataSource updateMessage:currentMessage];
                                       }
                                       
                                       return nil;
                                   }];
    }
    else {
        
        __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
        
        @weakify(self);
        self.contactRequestTask = [[[QMCore.instance.contactManager rejectAddContactRequest:opponentUser] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            @strongify(self);
            if (!task.isFaulted) {
                
                return [QMCore.instance.chatService deleteDialogWithID:self.chatDialog.ID];
            }
            
            return [BFTask cancelledTask];
            
        }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            @strongify(self);
            [navigationController dismissNotificationPanel];
            
            if (!task.isCancelled && !task.isFaulted) {
                
                if (self.splitViewController.isCollapsed) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else {
                    
                    [(QMSplitViewController *)self.splitViewController showPlaceholderDetailViewController];
                }
            }
            
            return nil;
        }];
    }
}

//MARK: QMChatCellDelegate

- (void)chatCellDidTapContainer:(QMChatCell *)cell {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
    
    QMMessageStatus status = [self.deferredQueueManager statusForMessage:message];
    
    if (status == QMMessageStatusNotSent && message.senderID == self.senderID) {
        
        [self handleNotSentMessage:message];
        return;
    }
    else if ([cell conformsToProtocol:@protocol(QMChatLocationCell)]) {
        
        QMLocationViewController *locationVC =
        [[QMLocationViewController alloc] initWithState:QMLocationVCStateView
                                     locationCoordinate:[message locationCoordinate]];
        
        [self.view endEditing:YES]; // hiding keyboard
        [self.navigationController pushViewController:locationVC animated:YES];
    }
    
    else if ([cell isKindOfClass:[QMBaseMediaCell class]]) {
        
        CGSize size =  [self.collectionView.collectionViewLayout containerViewSizeForItemAtIndexPath:indexPath];
        QMLog(@"size = %@", NSStringFromCGSize(size));
        QMLog(@"messageID = %@", message.ID);
        
        [self.mediaController didTapContainer:(id<QMMediaViewDelegate>)cell];
    }
    else if ([cell isKindOfClass:[QMChatBaseLinkPreviewCell class]]) {
        
        CGSize cellSize = [self.collectionView.collectionViewLayout containerViewSizeForItemAtIndexPath:indexPath];
        QMLog(@"cell size = %@", NSStringFromCGSize(cellSize));
        
        QMOpenGraphItem *og = QMCore.instance.openGraphService.memoryStorage[message.ID];
        NSParameterAssert(og);
        
        NSURL *linkURL = [NSURL URLWithString:og.baseUrl];
        [self openURL:linkURL];
    }
    else if ([cell isKindOfClass:[QMChatOutgoingCell class]] ||
             [cell isKindOfClass:[QMChatIncomingCell class]]) {
        
        if ([self.detailedCells containsObject:message.ID]) {
            
            [self.detailedCells removeObject:message.ID];
        }
        else {
            
            [self.detailedCells addObject:message.ID];
        }
        
        [self.collectionView.collectionViewLayout removeSizeFromCacheForItemID:message.ID];
        [self.collectionView performBatchUpdates:nil completion:nil];
    }
}

- (void)chatCellDidTapAvatar:(QMChatCell *)cell {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        [self performInfoViewControllerForUserID:[self.chatDialog opponentID]];
    }
    else {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        QBChatMessage *chatMessage = [self.chatDataSource messageForIndexPath:indexPath];
        
        [self performInfoViewControllerForUserID:chatMessage.senderID];
    }
}

- (void)chatCell:(QMChatCell *)__unused cell didTapOnTextCheckingResult:(NSTextCheckingResult *)textCheckingResult {
    
    switch (textCheckingResult.resultType) {
            
        case NSTextCheckingTypeLink: {
            
            [self openURL:textCheckingResult.URL];
            
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

//MARK: - UITextViewDelegate

- (BOOL)textView:(UITextView *)__unused textView shouldChangeTextInRange:(NSRange)__unused range replacementText:(NSString *)__unused text {
    
    [self sendIsTypingStatus];
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [super textViewDidEndEditing:textView];
    
    [self stopTyping];
}

//MARK: - UIImagePickerControllerDelegate

- (void)imagePickerCanBePresented:(QMImagePicker *)imagePicker
                   withCompletion:(void (^)(BOOL))grantBlock {
    
    [QMPermissions requestPermissionToCameraWithCompletion:^(BOOL granted) {
        if (!granted) {
            [self showAlertForAccess:imagePicker];
        }
        grantBlock(granted);
    }];
}

- (void)imagePicker:(QMImagePicker *)__unused imagePicker
didFinishPickingWithError:(NSError *)error {
    
    NSString *errorMessage =
    error.localizedDescription ?: NSLocalizedString(@"QM_STR_UNKNOWN_ERROR", nil);
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning
                                                                          message:errorMessage
                                                                         duration:kQMDefaultNotificationDismissTime];
}

- (void)imagePicker:(QMImagePicker *)__unused imagePicker
didFinishPickingPhoto:(UIImage *)photo {
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImage *newImage = [photo fixOrientation];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendAttachmentMessageWithImage:newImage];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mediaController didFinishPickingPhoto:photo];
            });
        }
    });
}

- (void)imagePicker:(QMImagePicker *)__unused imagePicker
didFinishPickingVideo:(NSURL *)videoUrl {
    
    QBChatAttachment *attachment = [QBChatAttachment videoAttachmentWithFileURL:videoUrl];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
        NSTimeInterval durationSeconds = CMTimeGetSeconds(videoAsset.duration);
        attachment.duration = lround(durationSeconds);
        NSAssert([videoAsset tracksWithMediaType:AVMediaTypeVideo].count, @"Video asset should have video tracks");
        AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        CGSize videoSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
        attachment.width = lround(videoSize.width);
        attachment.height = lround(videoSize.height);
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
        NSError *error;
        CMTime actualTime;
        CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
        
        if (halfWayImage != NULL) {
            attachment.image = [UIImage imageWithCGImage:halfWayImage];
            CGImageRelease(halfWayImage);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendMessageWithAttachment:attachment];
        });
    });
}


//MARK: - Helpers

- (void)showAlertForAccess:(QMImagePicker *)picker {
    
    NSString *title;
    NSString *message;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        title = NSLocalizedString(@"Camera Access Disabled", nil);
        message = NSLocalizedString(@"You can allow access to Camera in Settings", nil);
    }
    else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        title = NSLocalizedString(@"Photos Access Disabled", nil);
        message = NSLocalizedString(@"You can allow access to Photos in Settings", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"SA_STR_CANCEL", nil)
                                          otherButtonTitles:NSLocalizedString(@"Open Settings", nil),nil];
    
    [alert show];
}

- (void)openURL:(NSURL *)url {
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
        if ([SFSafariViewController class] != nil
            // SFSafariViewController supporting only http and https schemes
            && ([url.scheme.lowercaseString isEqualToString:@"http"]
                || [url.scheme.lowercaseString isEqualToString:@"https"])) {
                
                SFSafariViewController *controller =
                [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:false];
                [self presentViewController:controller animated:true completion:nil];
            }
        else {
            
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (UIImage *)resizedImageFromImage:(UIImage *)image {
    
    CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
    CGFloat scaleCoefficient = largestSide / 560.0f;
    CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
    
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (void)openGraphSerivce:(QMOpenGraphService *)__unused openGraphSerivce
        didLoadFromCache:(QMOpenGraphItem *)openGraph {
    
    QBChatMessage *message =
    [QMCore.instance.chatService.messagesMemoryStorage messageWithID:openGraph.ID
                                                        fromDialogID:self.chatDialog.ID];
    if (message) {
        [self.chatDataSource updateMessage:message];
    }
}

- (void)openGraphSerivce:(QMOpenGraphService *) __unused openGraphSerivce
didAddOpenGraphItemToMemoryStorage:(QMOpenGraphItem *)openGraphItem {
    
    QBChatMessage *message =
    [QMCore.instance.chatService.messagesMemoryStorage messageWithID:openGraphItem.ID
                                                        fromDialogID:self.chatDialog.ID];
    if (message) {
        
        [self.chatDataSource updateMessage:message];
    }
}

//MARK: - Transition size

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> __unused context) {
        [self updateGroupAvatarFrameForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    } completion:nil];
}

- (void)share {
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)__unused scrollView {
    
    return NO;
}

//MARK: - QMCallManagerDelegate

- (void)callManager:(QMCallManager *)__unused callManager
willCloseCurrentSession:(QBRTCSession *)__unused session {
    
}

- (void)callManager:(QMCallManager *)__unused callManager
willChangeActiveCallState:(BOOL)willHaveActiveCall {
    
    if (willHaveActiveCall) {
        [[QMAudioPlayer audioPlayer] pause];
        [self cancellAudioRecording];
    }
}

@end
