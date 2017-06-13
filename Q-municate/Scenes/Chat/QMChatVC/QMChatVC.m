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
#import "QMStatusStringBuilder.h"
#import "QMPlaceholder.h"
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

// external
#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import <AVKit/AVKit.h>

@import SafariServices;

static const float kQMAttachmentCellSize = 180.0f;
static const NSTimeInterval kQMMaxAttachmentDuration = 30.0;

static const CGFloat kQMWidthPadding = 40.0f;
static const CGFloat kQMAvatarSize = 28.0f;

static NSString * const kQMTextAttachmentSpacing = @"  ";

@interface QMChatVC ()

<
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMContactListServiceDelegate,
QMDeferredQueueManagerDelegate,

QMChatActionsHandler,
QMChatCellDelegate,

QMImagePickerResultHandler,
QMImageViewDelegate,

NYTPhotosViewControllerDelegate,
QMMediaControllerDelegate,
QMCallManagerDelegate
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

/**
 *  Group avatar image view.
 */
@property (strong, nonatomic) QMImageView *groupAvatarImageView;

/**
 *  Reference view for attachment photo.
 */
@property (weak, nonatomic) UIView *photoReferenceView;

@property (strong, nonatomic) QMMediaController *mediaController;


@property (strong, nonatomic) QMAudioRecorder *currentAudioRecorder;


@end

@implementation QMChatVC

@dynamic storedMessages;
@dynamic deferredQueueManager;

//MARK: - Static methods

+ (instancetype)chatViewControllerWithChatDialog:(QBChatDialog *)chatDialog {
    
    QMChatVC *chatVC = [[UIStoryboard storyboardWithName:kQMMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    chatVC.chatDialog = chatDialog;
    
    return chatVC;
}

//MARK: - QMChatViewController data source overrides

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

//MARK: - Life cycle

- (void)dealloc {
    // -dealloc
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    
    // removing left bar button item that is responsible for split view
    // display mode managing. Not removing it will cause item update
    // for deallocated navigation item
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.collectionView.collectionViewLayout.minimumLineSpacing = 8.0f;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    [QMChatCell registerMenuAction:@selector(delete:)];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    if (self.chatDialog == nil) {
        
        self.inputToolbar.hidden = YES;
        self.onlineTitleView.hidden = YES;
        [self.view.layer setDrawsAsynchronously:YES];
        
        return;
    }
    
    // setting up chat controller
    self.topContentAdditionalInset =
    self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedString(@"QM_STR_INPUTTOOLBAR_PLACEHOLDER", nil);
    self.view.backgroundColor = QMChatBackgroundColor();
    
    // setting up properties
    self.detailedCells = [NSMutableSet set];
    self.statusStringBuilder = [[QMStatusStringBuilder alloc] init];
    
    
    self.mediaController = [[QMMediaController alloc] initWithViewController:self];
    
    @weakify(self);
    
    [self.mediaController setOnError:^(QBChatMessage *__unused message, NSError *error) {
        
        @strongify(self);
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:error.localizedRecoverySuggestion duration:kQMDefaultNotificationDismissTime];
    }];
    
    
    // subscribing to delegates
    [[QMCore instance].chatService addDelegate:self];
    [[QMCore instance].contactListService addDelegate:self];
    [[QMCore instance].chatService.chatAttachmentService addDelegate:self.mediaController];
    [[QMCore instance].callManager addDelegate:self];
    [self.deferredQueueManager addDelegate:self];
    
    
    self.actionsHandler = self;
    
    // text checking types for cells
    self.enableTextCheckingTypes = (NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber);
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        // set up opponent full name
        [self.onlineTitleView setTitle:[[QMCore instance].contactManager fullNameForUserID:[self.chatDialog opponentID]]];
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
    
    self.inputToolbar.audioRecordingIsEnabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [QMCore instance].activeDialogID = self.chatDialog.ID;
    
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
         [self.inputToolbar forceFinishRecording];
         
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
    
    [QMCore instance].activeDialogID = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerWillResignActive];
    
    // Delete blocks.
    [self.chatDialog clearTypingStatusBlocks];
    [self.chatDialog clearDialogOccupantsStatusBlock];
    
    //Cancel audio recording
    [self finishAudioRecording];
    [self.inputToolbar forceFinishRecording];
    
    //Stop player
    [[QMAudioPlayer audioPlayer] stop];
}

//MARK: - Deferred queue management

- (void)deferredQueueManager:(QMDeferredQueueManager *)__unused queueManager didAddMessageLocally:(QBChatMessage *)addedMessage {
    
    if ([addedMessage.dialogID isEqualToString:self.chatDialog.ID]) {
        
        [self.chatDataSource addMessage:addedMessage];
    }
}

- (void)deferredQueueManager:(QMDeferredQueueManager *)__unused queueManager
     didUpdateMessageLocally:(QBChatMessage *)addedMessage {
    
    [self.chatDataSource updateMessage:addedMessage];
}

- (id<QMMediaViewDelegate>)viewForMessage:(QBChatMessage *)message {
    
    NSIndexPath *indexPath = [self.chatDataSource indexPathForMessage:message];
    id cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if ([cell conformsToProtocol:@protocol(QMMediaViewDelegate)]) {
        return cell;
    }
    else {
        return nil;
    }
}

- (void)didUpdateMessage:(QBChatMessage *)message {
    
    if ([self.chatDialog.ID isEqualToString:message.dialogID]) {
        
        [self.chatDataSource updateMessage:message];
    }
}


//MARK: - Helpers & Utility

- (void)updateOpponentOnlineStatus {
    
    BOOL isOnline = [[QMCore instance].contactManager isUserOnlineWithID:[self.chatDialog opponentID]];
    [self setOpponentOnlineStatus:isOnline];
}

- (NSArray *)storedMessages {
    
    return [[QMCore instance].chatService.messagesMemoryStorage messagesWithDialogID:self.chatDialog.ID];
}

- (QMDeferredQueueManager *)deferredQueueManager {
    
    return [QMCore instance].chatService.deferredQueueManager;
}

- (void)refreshMessages {
    
    @weakify(self);
    // Retrieving message from Quickblox REST history and cache.
    [[QMCore instance].chatService messagesWithChatDialogID:self.chatDialog.ID
                                             iterationBlock:^(QBResponse * __unused response,
                                                              NSArray *messages,
                                                              BOOL * __unused stop) {
                                                 
                                                 @strongify(self);
                                                 
                                                 if (messages.count > 0) {
                                                     
                                                     [self.chatDataSource addMessages:messages];
                                                 }
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
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning
                                                    message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil)
                                                   duration:kQMDefaultNotificationDismissTime];
        return NO;
    }
    
    if (![QBChat instance].isConnected) {
        
        if (QBChat.instance.isConnecting) {
            
            [self.navigationController shake];
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
        
        if (![[QMCore instance].contactManager isFriendWithUserID:[self.chatDialog opponentID]]) {
            
            [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_SEND_MESSAGES", nil)
                            actionSuccess:NO
                         inViewController:self];
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
        
        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CANT_MAKE_CALLS", nil)
                        actionSuccess:NO
                     inViewController:self];
        return NO;
    }
    
    return YES;
}

//MARK:- Toolbar actions

//MARK: QMInputToolbarDelegate

- (BOOL)messagesInputToolbarAudioRecordingEnabled:(QMInputToolbar *)__unused toolbar {
    
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
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)messagesInputToolbarAudioRecordingStart:(QMInputToolbar *)toolbar {
    
    [self startAudioRecording];
    [toolbar startAudioRecording];
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
    
    [[UIScreen mainScreen] lockCurrentOrientation];
}

- (void)cancellAudioRecording {
    
    if (self.currentAudioRecorder != nil) {
        
        [[UIScreen mainScreen] unlockCurrentOrientation];
        [self.currentAudioRecorder cancelRecording];
    }
}

- (void)finishAudioRecording {
    
    if (self.currentAudioRecorder != nil) {
        
        [[UIScreen mainScreen] unlockCurrentOrientation];
        [self.currentAudioRecorder stopRecording];
    }
}

- (void)destroyAudioRecorder {
    
    if (self.currentAudioRecorder != nil) {
        
        [[UIScreen mainScreen] unlockCurrentOrientation];
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

- (void)didPressSendButton:(UIButton *)__unused button
           withMessageText:(NSString *)text
                  senderId:(NSUInteger)senderId
         senderDisplayName:(NSString *)__unused senderDisplayName
                      date:(NSDate *)date {
    
    if (![self.deferredQueueManager shouldSendMessagesInDialogWithID:self.chatDialog.ID]) {
        return;
    }
    
    if (self.typingTimer != nil) {
        
        [self stopTyping];
    }
    
    if (![self messageSendingAllowed]) {
        
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
        
        return;
    }
    
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIAlertController *alertController =
    [UIAlertController alertControllerWithTitle:nil
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_MEDIA", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker takePhotoOrVideoInViewController:self
                                                                                              maxDuration:kQMMaxAttachmentDuration
                                                                                                  quality:UIImagePickerControllerQualityTypeMedium
                                                                                            resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_MEDIA", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker chooseFromGaleryInViewController:self
                                                                                              maxDuration:kQMMaxAttachmentDuration
                                                                                            resultHandler:self
                                                                                            allowsEditing:YES];
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

//MARK: - Cells view classes

- (Class)viewClassForItem:(QBChatMessage *)item {
    
    if ([item isLocationMessage]) {
        
        return item.senderID == self.senderID ? [QMChatLocationOutgoingCell class] : [QMChatLocationIncomingCell class];
    }
    else if ([item isNotificatonMessage] || [item isCallNotificationMessage] || item.isDateDividerMessage) {
        
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
                
                if ([item isVideoAttachment]) {
                    return  [QMVideoIncomingCell class];
                }
                else if ([item isAudioAttachment]) {
                    return  [QMAudioIncomingCell class];
                    
                }
                else if ([item isImageAttachment]) {
                    return  [QMImageIncomingCell class];
                }
                else {
                    return [QMChatAttachmentIncomingCell class];
                }
            }
            else {
                
                Class classForItem = [QMChatIncomingCell class];
                
                QMLinkPreview *linkPreview = [[QMCore instance].chatService linkPreviewForMessage:item];
                if (linkPreview != nil) {
                    classForItem = [QMChatIncomingLinkPreviewCell class];
                }
                
                return classForItem;
            }
        }
        else {
            
            if ([item isMediaMessage] && item.attachmentStatus != QMMessageAttachmentStatusError) {
                
                if ([item isVideoAttachment]) {
                    return  [QMVideoOutgoingCell class];
                }
                else if ([item isAudioAttachment]) {
                    return  [QMAudioOutgoingCell class];
                    
                }
                else if ([item isImageAttachment]) {
                    return  [QMImageOutgoingCell class];
                }
                return [QMChatAttachmentOutgoingCell class];
                
            }
            else {
                
                QMLinkPreview *linkPreview =
                [[QMCore instance].chatService linkPreviewForMessage:item];
                
                if (linkPreview != nil) {
                    return  [QMChatOutgoingLinkPreviewCell class];
                }
                return [QMChatOutgoingCell class];
            }
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
    
    if ([messageItem isNotificatonMessage] || messageItem.isDateDividerMessage) {
        
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
        
        size = CGSizeMake(MIN(kQMAttachmentCellSize, maxWidth), 45);
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
        
        QMChatCellLayoutModel layoutModel = [self collectionView:self.collectionView layoutModelAtIndexPath:indexPath];
        
        CGFloat linkPreviewHeight = 54.0;
        CGFloat linkPreviewWidth = kQMAttachmentCellSize;
        
        QMLinkPreview *linkPreview = [[QMCore instance].chatService linkPreviewForMessage:item];
        
        if (linkPreview.imageURL != nil) {
            
            UIImage *image =
            [QMChatBaseLinkPreviewCell imageForURLKey:linkPreview.imageURL];
            
            if (image) {
                
                linkPreviewWidth =
                kQMAttachmentCellSize - layoutModel.containerInsets.left - layoutModel.containerInsets.right;
                
                CGFloat oldWidth = image.size.width;
                CGFloat scaleFactor = linkPreviewWidth / oldWidth;
                
                linkPreviewHeight = image.size.height * scaleFactor;
            }
        }
        
        size = CGSizeMake(MIN(kQMAttachmentCellSize,maxWidth),
                          MAX(linkPreviewHeight, 54.0));
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
    
    CGSize size = CGSizeMake(270.0, 142.0); //default video size for cell
    
    if (!CGSizeEqualToSize(CGSizeMake(attachment.width, attachment.height),
                           CGSizeZero)) {
        
        BOOL isVerticalVideo = attachment.width < attachment.height;
        
        size = isVerticalVideo ? CGSizeMake(142.0, 270.0) : size;
    }
    
    return size;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
      canPerformAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender {
    
    Class viewClass = [self viewClassForItem:[self.chatDataSource messageForIndexPath:indexPath]];
    
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

- (void)collectionView:(UICollectionView *)__unused collectionView
         performAction:(SEL)action
    forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)__unused sender {
    
    if (action == @selector(copy:)) {
        
        QBChatMessage *message = [self.chatDataSource messageForIndexPath:indexPath];
        
        if ([message isMediaMessage]) {
            
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
        
        /**
         *  Setting opponent avatar
         */
        QBUUser *sender = [[QMCore instance].usersService.usersMemoryStorage
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
        
        QMLinkPreview *linkPreview = [[QMCore instance].chatService linkPreviewForMessage:message];
        
        if (linkPreview) {
            
            [self.collectionView.collectionViewLayout removeSizeFromCacheForItemID:message.ID];
            QMChatBaseLinkPreviewCell *previewCell = (QMChatBaseLinkPreviewCell *)cell;
            [previewCell setSiteURL:linkPreview.siteUrl
                           imageURL:linkPreview.imageURL
                          siteTitle:linkPreview.siteTitle
                    siteDescription:linkPreview.siteDescription
                      onImageDidSet:^
             {
                 [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
             }];
        }
    }
    
    if ([cell conformsToProtocol:@protocol(QMChatLocationCell)]) {
        
        [[(id<QMChatLocationCell>)cell imageView]
         setSnapshotWithLocationCoordinate:message.locationCoordinate];
    }
    
    else if ([cell conformsToProtocol:@protocol(QMMediaViewDelegate)]) {
        
        QBChatAttachment *attachment = message.attachments[0];
        [self.mediaController configureView:(id<QMMediaViewDelegate>)cell
                                withMessage:message
                               attachmentID:attachment.ID];
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)__unused cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item == [collectionView numberOfItemsInSection:0] - 1) {
        // first message
        // load more if exists
        // Getting earlier messages for chat dialog identifier.
        [[[QMCore instance].chatService loadEarlierMessagesWithChatDialogID:self.chatDialog.ID] continueWithBlock:^id(BFTask<NSArray<QBChatMessage *> *> *task) {
            
            if (task.result.count > 0) {
                [self.chatDataSource addMessages:task.result];
            }
            
            return nil;
        }];
    }
    
    // marking message as read if needed
    QBChatMessage *itemMessage = [self.chatDataSource messageForIndexPath:indexPath];
    
    [self readMessage:itemMessage];
    
    // getting users if needed
    QBUUser *sender = [[QMCore instance].usersService.usersMemoryStorage userWithID:itemMessage.senderID];
    if (sender == nil) {
        
        [[[QMCore instance].usersService getUserWithID:itemMessage.senderID] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
            
            [self.chatDataSource updateMessage:itemMessage];
            
            return nil;
        }];
    }
    
    QMLinkPreview *linkPreview = [[QMCore instance].chatService linkPreviewForMessage:itemMessage];
    
    if (linkPreview == nil) {
        
        [[QMCore instance].chatService getLinkPreviewForMessage:itemMessage withCompletion:^(BOOL success) {
            
            if (success) {
                [self.chatDataSource updateMessage:itemMessage];
            }
        }];
    }
}

- (void)collectionView:(UICollectionView *)__unused collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell conformsToProtocol:@protocol(QMMediaViewDelegate)]) {
        QBChatMessage *itemMessage = [self.chatDataSource messageForIndexPath:indexPath];
        [self.mediaController cancelOperationsForMessage:itemMessage];
    }
    
}
#pragma mark - Typing status
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
    //  [self.view endEditing:YES];
    
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

- (void)_sendLocationMessage:(CLLocationCoordinate2D)locationCoordinate {
    
    QBChatMessage *message = [QMMessagesHelper chatMessageWithText:kQMLocationNotificationMessage
                                                          senderID:self.senderID
                                                      chatDialogID:self.chatDialog.ID
                                                          dateSent:[NSDate date]];
    
    message.locationCoordinate = locationCoordinate;
    
    [self _sendMessage:message];
}

- (void)_sendMessage:(QBChatMessage *)message {
    
    [[[QMCore instance].chatService sendMessage:message
                                       toDialog:self.chatDialog
                                  saveToHistory:YES
                                  saveToStorage:YES]
     continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
         
         [QMSoundManager playMessageSentSound];
         
         return nil;
     }];
}

- (void)sendMessageWithAttachment:(QBChatAttachment *)attachment {
    
    QBChatMessage *message = [QMMessagesHelper chatMessageWithText:nil
                                                          senderID:self.senderID
                                                      chatDialogID:self.chatDialog.ID
                                                          dateSent:[NSDate date]];
    [self.chatDataSource addMessage:message];
    
    [[QMCore instance].chatService sendAttachmentMessage:message
                                                toDialog:self.chatDialog
                                          withAttachment:attachment
                                              completion:^(NSError * _Nullable error) {
                                                  
                                                  if (error) {
                                                      [self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed
                                                                                                  message:error.localizedRecoverySuggestion
                                                                                                 duration:kQMDefaultNotificationDismissTime];
                                                      // perform local attachment deleting
                                                      [[QMCore instance].chatService deleteMessageLocally:message];
                                                      [self.chatDataSource deleteMessage:message];
                                                  }
                                              }];
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
                                                          
                                                          [self.deferredQueueManager perfromDefferedActionForMessage:notSentMessage];
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
    
    self.groupAvatarImageView.frame = CGRectMake(0, 0, defaultSize, defaultSize);
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
    
    // chat avatar
    self.groupAvatarImageView = [[QMImageView alloc] init];
    [self updateGroupAvatarFrameForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    self.groupAvatarImageView.imageViewType = QMImageViewTypeCircle;
    self.groupAvatarImageView.delegate = self;
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.groupAvatarImageView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self updateGroupAvatarImage];
}

- (void)updateGroupAvatarImage {
    
    NSURL *avatarURL = [NSURL URLWithString:self.chatDialog.photo];
    [self.groupAvatarImageView setImageWithURL:avatarURL
                                         title:self.chatDialog.name
                                completedBlock:nil];
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
        
        QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:[self.chatDialog opponentID]];
        
        if (opponentUser) {
            status = [[QMCore instance].contactManager onlineStatusForUser:opponentUser];
        }
    }
    
    [self.onlineTitleView setStatus:status];
}

//MARK: - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)__unused imageView {
    
    [self performSegueWithIdentifier:KQMSceneSegueGroupInfo sender:self.chatDialog];
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didLoadMessagesFromCache:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    if ([self.chatDialog.ID isEqualToString:dialogID]) {
        
        [self.chatDataSource addMessages:messages];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
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
didAddChatDialogsToMemoryStorage:(NSArray<QBChatDialog *> *)chatDialogs {
    
    if (self.chatDialog.type != QBChatDialogTypePrivate && [chatDialogs containsObject:self.chatDialog]) {
        
        [self.onlineTitleView setTitle:self.chatDialog.name];
        [self updateGroupAvatarImage];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID
{
    if ([self.chatDialog.ID isEqualToString:dialogID] && message.senderID == self.senderID) {
        // self-sending attachments
        [self.chatDataSource updateMessage:message];
    }
}

//MARK: - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)__unused chatService {
    
    [self refreshMessages];
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        [self updateOpponentOnlineStatus];
    }
}

- (void)chatServiceChatDidReconnect:(QMChatService *)__unused chatService {
    
    [self refreshMessages];
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        
        [self updateOpponentOnlineStatus];
    }
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)__unused chatService {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate) {
        // chat disconnected, updating title status for user
        
        [self setOpponentOnlineStatus:NO];
    }
}


//MARK: - Contact List Service Delegate

- (void)contactListService:(QMContactListService *)__unused contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)__unused status {
    
    if (self.chatDialog.type == QBChatDialogTypePrivate && [self.chatDialog opponentID] == userID && !self.isOpponentTyping) {
        
        [self setOpponentOnlineStatus:isOnline];
    }
}

//MARK: QMChatActionsHandler protocol

- (void)chatContactRequestDidAccept:(BOOL)accept sender:(id)sender {
    
    if (self.contactRequestTask) {
        // task in progress
        return;
    }
    
    QBUUser *opponentUser = [[QMCore instance].usersService.usersMemoryStorage userWithID:[self.chatDialog opponentID]];
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    if (accept) {
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        QBChatMessage *currentMessage = [self.chatDataSource messageForIndexPath:indexPath];
        
        __weak UINavigationController *navigationController = self.navigationController;
        
        @weakify(self);
        self.contactRequestTask = [[[QMCore instance].contactManager addUserToContactList:opponentUser] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            @strongify(self);
            [navigationController dismissNotificationPanel];
            
            if (!task.isFaulted) {
                [self.chatDataSource updateMessage:currentMessage];
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
    QBChatMessage *currentMessage = [self.chatDataSource messageForIndexPath:indexPath];
    
    QMMessageStatus status = [self.deferredQueueManager statusForMessage:currentMessage];
    
    if (status == QMMessageStatusNotSent && currentMessage.senderID == self.senderID) {
        
        [self handleNotSentMessage:currentMessage];
        return;
    }
    else if ([cell conformsToProtocol:@protocol(QMChatLocationCell)]) {
        
        QMLocationViewController *locationVC = [[QMLocationViewController alloc] initWithState:QMLocationVCStateView locationCoordinate:[currentMessage locationCoordinate]];
        
        [self.view endEditing:YES]; // hiding keyboard
        [self.navigationController pushViewController:locationVC animated:YES];
    }
    
    else if ([cell isKindOfClass:[QMBaseMediaCell class]]) {
        CGSize size =  [self.collectionView.collectionViewLayout containerViewSizeForItemAtIndexPath:indexPath];
        NSLog(@"size = %@", NSStringFromCGSize(size));
        [[((QMBaseMediaCell*)cell) presenter] didTapContainer];
    }
    else if ([cell isKindOfClass:[QMChatBaseLinkPreviewCell class]]) {
        
        CGSize cellSize = [self.collectionView.collectionViewLayout containerViewSizeForItemAtIndexPath:indexPath];
        NSLog(@"cell size = %@", NSStringFromCGSize(cellSize));
        
        QMLinkPreview *linkPreview = [[QMCore instance].chatService linkPreviewForMessage:currentMessage];
        NSURL *linkURL = [NSURL URLWithString:linkPreview.siteUrl];
        
        [self openURL:linkURL];
    }
    else if ([cell isKindOfClass:[QMChatOutgoingCell class]]
             || [cell isKindOfClass:[QMChatIncomingCell class]]) {
        
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

//MARK: - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.photoReferenceView;
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

- (void)imagePicker:(QMImagePicker *)imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    if (![[QMCore instance] isInternetConnected]) {
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
        
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        UIImage *newImage = photo;
        if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            newImage = [newImage fixOrientation];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendAttachmentMessageWithImage:newImage];
        });
    });
}

- (void)imagePicker:(QMImagePicker *)__unused imagePicker didFinishPickingVideo:(NSURL *)videoUrl {
    
    QBChatAttachment *attachment = [QBChatAttachment videoAttachmentwWithFileURL:videoUrl];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
        NSTimeInterval durationSeconds = CMTimeGetSeconds(videoAsset.duration);
        attachment.duration = lround(durationSeconds);
        
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

//MARK: - Transition size

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> __unused context) {
        [self updateGroupAvatarFrameForInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
        
    } completion:nil];
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
