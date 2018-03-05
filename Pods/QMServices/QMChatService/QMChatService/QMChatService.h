//
//  QMChatService.h
//  QMServices
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMBaseService.h"
#import "QMDialogsMemoryStorage.h"
#import "QMMessagesMemoryStorage.h"
#import "QMChatAttachmentService.h"
#import "QMChatTypes.h"
#import "QMChatConstants.h"
#import "QMDeferredQueueManager.h"

@protocol QMChatServiceDelegate;
@protocol QMChatServiceCacheDataSource;
@protocol QMChatConnectionDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef void(^QMCacheCollection)(NSArray * _Nullable collection);
/**
 *  Chat dialog service
 */
@interface QMChatService : QMBaseService

/**
 *  Determines whether auto join for group dialogs is enabled or not.
 *  Default value is YES.
 *
 *  @discussion Disable auto join if you want to handle group chat dialogs joining manually
 *  or you are using our Enterprise feature to manage group chat dialogs without join being required.
 *  By default QMServices will perform join to all existent group dialogs in cache after
 *  every chat connect/reconnect and every chat dialog receive/update.
 */
@property (assign, nonatomic, getter=isAutoJoinEnabled) BOOL enableAutoJoin;

/**
 *  Chat messages per page with messages load methods
 */
@property (assign, nonatomic) NSUInteger chatMessagesPerPage;

/**
 *  Dialogs datasoruce
 */
@property (strong, nonatomic, readonly) QMDialogsMemoryStorage *dialogsMemoryStorage;

/**
 *  Messages datasource
 */
@property (strong, nonatomic, readonly) QMMessagesMemoryStorage *messagesMemoryStorage;

/**
 *  Attachment Service
 */
@property (strong, nonatomic, readonly) QMChatAttachmentService *chatAttachmentService;


@property (strong, nonatomic, readonly) QMDeferredQueueManager *deferredQueueManager;

/**
 *  Init chat service
 *
 *  @param serviceManager   delegate confirmed QMServiceManagerProtocol protocol
 *  @param cacheDataSource  delegate confirmed QMChatServiceCacheDataSource
 *
 *  @return Return QMChatService instance
 */
- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                       cacheDataSource:(nullable id<QMChatServiceCacheDataSource>)cacheDataSource;
/**
 *  Add delegate (Multicast)
 *
 *  @param delegate Instance confirmed QMChatServiceDelegate protocol
 */
- (void)addDelegate:(id<QMChatServiceDelegate, QMChatConnectionDelegate>)delegate;

/**
 *  Remove delegate from observed list
 *
 *  @param delegate Instance confirmed QMChatServiceDelegate protocol
 */
- (void)removeDelegate:(id<QMChatServiceDelegate, QMChatConnectionDelegate>)delegate;

/**
 *  Connect to chat
 *
 *  @param completion   The block which informs whether a chat did connect or not. nil if no errors.
 */
- (void)connectWithCompletionBlock:(nullable QBChatCompletionBlock)completion;

/**
 *  Disconnect from chat
 *
 *  @param completion   The block which informs whether a chat did disconnect or not. nil if no errors.
 */
- (void)disconnectWithCompletionBlock:(nullable QBChatCompletionBlock)completion;

//MARK: - Group dialog join

/**
 *  Joins user to group dialog and correctly updates cache. Please use this method instead of 'join' in QBChatDialog if you are using QMServices.
 *
 *  @param dialog       dialog to join
 *  @param completion   completion block with failure error
 */
- (void)joinToGroupDialog:(QBChatDialog *)dialog completion:(nullable QBChatCompletionBlock)completion;

//MARK: - Dialog history

/**
 *  Retrieve chat dialogs
 *
 *  @param extendedRequest Set of request parameters. http://quickblox.com/developers/SimpleSample-chat_users-ios#Filters
 *  @param completion Block with response dialogs instances
 */
- (void)allDialogsWithPageLimit:(NSUInteger)limit
                extendedRequest:(nullable NSDictionary *)extendedRequest
                 iterationBlock:(nullable void(^)(QBResponse *response, NSArray<QBChatDialog *> * _Nullable dialogObjects, NSSet<NSNumber *> * _Nullable dialogsUsersIDs, BOOL *stop))iterationBlock
                     completion:(nullable void(^)(QBResponse *response))completion;

//MARK: - Chat dialog creation

/**
 *  Create p2p dialog
 *
 *  @param opponent   QBUUser opponent
 *  @param completion Block with response and created chat dialog instances
 */
- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent
                                 completion:(nullable void(^)(QBResponse *response, QBChatDialog * _Nullable createdDialog))completion;

/**
 *  Create group dialog
 *
 *  @param name       Dialog name
 *  @param occupants  QBUUser collection
 *  @param completion Block with response and created chat dialog instances
 */
- (void)createGroupChatDialogWithName:(nullable NSString *)name photo:(nullable NSString *)photo occupants:(NSArray<QBUUser *> *)occupants completion:(nullable void(^)(QBResponse *response, QBChatDialog * _Nullable createdDialog))completion;

/**
 *  Create p2p dialog
 *
 *  @param opponentID Opponent ID
 *  @param completion Block with response and created chat dialog instances
 */
- (void)createPrivateChatDialogWithOpponentID:(NSUInteger)opponentID
                                   completion:(nullable void(^)(QBResponse *response, QBChatDialog * _Nullable createdDialog))completion;

//MARK: - Edit dialog methods

/**
 *  Change dialog name
 *
 *  @param dialogName Dialog name
 *  @param chatDialog QBChatDialog instance
 *  @param completion Block with response and updated chat dialog instances
 */
- (void)changeDialogName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog
              completion:(nullable void(^)(QBResponse *response, QBChatDialog * _Nullable updatedDialog))completion;

/**
 *  Change dialog avatar
 *
 *  @param avatarPublicUrl avatar url
 *  @param chatDialog      QBChatDialog instance
 *  @param completion      Block with response and updated chat dialog instances
 */
- (void)changeDialogAvatar:(NSString *)avatarPublicUrl forChatDialog:(QBChatDialog *)chatDialog
                completion:(nullable void(^)(QBResponse *response, QBChatDialog * _Nullable updatedDialog))completion;

/**
 *  Join occupants
 *
 *  @param ids        Occupants ids
 *  @param chatDialog QBChatDialog instance
 *  @param completion Block with response and updated chat dialog instances
 */
- (void)joinOccupantsWithIDs:(NSArray<NSNumber *> *)ids toChatDialog:(QBChatDialog *)chatDialog
                  completion:(nullable void(^)(QBResponse *response, QBChatDialog * _Nullable updatedDialog))completion;

/**
 *  Delete dialog by id on server and chat cache
 *
 *  @param completion Block with response dialogs instances
 */
- (void)deleteDialogWithID:(NSString *)dialogId
                completion:(nullable void(^)(QBResponse *response))completion;

/**
 *  Loads dialogs specific to user from disc cache and puth them in memory storage.
 *  @warning This method MUST be called after the login.
 *
 *  @param completion Completion block to handle ending of operation.
 */
- (void)loadCachedDialogsWithCompletion:(nullable dispatch_block_t)completion;

//MARK: - System Messages

/**
 *  Send system message to users about adding to dialog with dialog inside with text.
 *
 *  @param chatDialog   created dialog we notificate about
 *  @param usersIDs     array of users id to send message
 *  @param text         text to users
 *  @param completion   completion block with failure error
 */
- (void)sendSystemMessageAboutAddingToDialog:(QBChatDialog *)chatDialog
                                  toUsersIDs:(NSArray<NSNumber *> *)usersIDs
                                    withText:(nullable NSString *)text
                                  completion:(nullable QBChatCompletionBlock)completion;

//MARK: - Notification messages

/**
 *  Send message about accepting or rejecting contact requst.
 *
 *  @param accept     YES - accept, NO reject
 *  @param opponentID   opponent ID
 *  @param completion completion block with failure error
 */
- (void)sendMessageAboutAcceptingContactRequest:(BOOL)accept
                                   toOpponentID:(NSUInteger)opponentID
                                     completion:(nullable QBChatCompletionBlock)completion;

/**
 *  Sending notification message about adding occupants to specific dialog.
 *
 *  @param occupantsIDs     array of occupants that were added to a specific dialog
 *  @param chatDialog       chat dialog to send notification message to
 *  @param notificationText notification message body (text)
 *  @param completion       completion block with failure error
 */
- (void)sendNotificationMessageAboutAddingOccupants:(NSArray<NSNumber *> *)occupantsIDs
                                           toDialog:(QBChatDialog *)chatDialog
                               withNotificationText:(NSString *)notificationText
                                         completion:(nullable QBChatCompletionBlock)completion;

/**
 *  Sending notification message about leaving dialog.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *  @param completion       completion block with failure error
 */
- (void)sendNotificationMessageAboutLeavingDialog:(QBChatDialog *)chatDialog
                             withNotificationText:(NSString *)notificationText
                                       completion:(nullable QBChatCompletionBlock)completion;

/**
 *  Sending notification message about changing dialog photo.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *  @param completion       completion block with failure error
 */
- (void)sendNotificationMessageAboutChangingDialogPhoto:(QBChatDialog *)chatDialog
                                   withNotificationText:(NSString *)notificationText
                                             completion:(nullable QBChatCompletionBlock)completion;

/**
 *  Sending notification message about changing dialog name.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *  @param completion       completion block with failure error
 */
- (void)sendNotificationMessageAboutChangingDialogName:(QBChatDialog *)chatDialog
                                  withNotificationText:(NSString *)notificationText
                                            completion:(nullable QBChatCompletionBlock)completion;

//MARK: - Fetch messages

/**
 *  Updating message in cache and memory storage.
 *
 *  @param message message to update
 */
- (void)updateMessageLocally:(QBChatMessage *)message;

/**
 *  Deleting message from cache and memory storage.
 *
 *  @param message message to delete
 */
- (void)deleteMessageLocally:(QBChatMessage *)message;

/**
 *  Deleting messages from cache and memory storage.
 *
 *  @param messages messages to delete
 *  @param dialogID chat dialog identifier
 */
- (void)deleteMessagesLocally:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID;

/**
 *  Fetch messages with chat dialog id from the latest (newest) message in cache.
 *
 *  @param chatDialogID Chat dialog id
 *  @param completion   Block with response instance and array of chat messages if request succeded or nil if failed
 */
- (void)messagesWithChatDialogID:(NSString *)chatDialogID
                      completion:(nullable void(^)(QBResponse *response, NSArray<QBChatMessage *> * _Nullable messages))completion;

/**
 *  Fetch messages with chat dialog id using custom extended request.
 *
 *  @param chatDialogID     Chat dialog id
 *  @param extendedRequest  extended parameters
 *  @param completion       Block with response instance and array of chat messages if request succeded or nil if failed
 *
 *  @discussion Pass nil or empty dictionary into extendedRequest to load only newest messages from latest message in cache.
 */
- (void)messagesWithChatDialogID:(NSString *)chatDialogID
                 extendedRequest:(nullable NSDictionary <NSString *, NSString *> *)extendedRequest
                      completion:(nullable void(^)(QBResponse *response, NSArray<QBChatMessage *> * _Nullable messages))completion;

/**
 *  Fetch messages with chat dialog id using custom extended request.
 *
 *  @param chatDialogID     Chat dialog id
 *  @param iterationBlock   iteration block (pagination handling)
 *  @param completion       Block with response instance and array of chat messages that were already iterated in iteration block
 */
- (void)messagesWithChatDialogID:(NSString *)chatDialogID
                  iterationBlock:(nullable void(^)(QBResponse *response, NSArray * _Nullable messages, BOOL *stop))iterationBlock
                      completion:(nullable void(^)(QBResponse *response, NSArray<QBChatMessage *> * _Nullable messages))completion;

/**
 *  Fetch messages with chat dialog id using custom extended request.
 *
 *  @param chatDialogID     Chat dialog id
 *  @param extendedRequest  extended parameters
 *  @param iterationBlock   iteration block (pagination handling)
 *  @param completion       Block with response instance and array of chat messages that were already iterated in iteration block
 *
 *  @discussion Pass nil or empty dictionary into extendedRequest to load only newest messages from latest message in cache.
 */
- (void)messagesWithChatDialogID:(NSString *)chatDialogID
                 extendedRequest:(nullable NSDictionary <NSString *, NSString *> *)extendedRequest
                  iterationBlock:(nullable void(^)(QBResponse *response, NSArray * _Nullable messages, BOOL *stop))iterationBlock
                      completion:(nullable void(^)(QBResponse *response, NSArray<QBChatMessage *> * _Nullable messages))completion;
/**
 *  Loads messages that are older than oldest message in cache.
 *
 *  @param chatDialogID Chat dialog identifier
 *  @param completion   Block with response instance and array of chat messages if request succeded or nil if failed
 */
- (void)earlierMessagesWithChatDialogID:(NSString *)chatDialogID
                             completion:(nullable void(^)(QBResponse *response, NSArray<QBChatMessage *> * _Nullable messages))completion;
//MARK: - Fetch dialogs

/**
 *  Fetch dialog with dialog id.
 *
 *  @param dialogID   Dialog identifier
 *  @param completion Block with dialog if request succeded or nil if failed
 */
- (void)fetchDialogWithID:(NSString *)dialogID completion:(nullable void (^)(QBChatDialog * _Nullable dialog))completion;

/**
 *  Load dialog with dialog id from Quickblox and saving to memory storage and cache.
 *
 *  @param dialogID   Dialog identifier
 *  @param completion Block with dialog if request succeded or nil if failed
 */
- (void)loadDialogWithID:(NSString *)dialogID completion:(nullable void (^)(QBChatDialog * _Nullable loadedDialog))completion;

/**
 *  Fetch dialog with last activity date from date
 *
 *  @param date         date to fetch dialogs from
 *  @param limit        page limit
 *  @param iteration    iteration block with dialogs for pages
 *  @param completion   Block with response when fetching finished
 */
- (void)fetchDialogsUpdatedFromDate:(NSDate *)date
                       andPageLimit:(NSUInteger)limit
                     iterationBlock:(nullable void(^)(QBResponse *response, NSArray<QBChatDialog *> * _Nullable dialogObjects, NSSet<NSNumber *> * _Nullable dialogsUsersIDs, BOOL *stop))iteration
                    completionBlock:(nullable void (^)(QBResponse *response))completion;

//MARK: Send message

/**
 *  Send message with a specific message type to dialog with identifier.
 *
 *  @param message       QBChatMessage instance
 *  @param type          QMMessageType type
 *  @param dialog        QBChatDialog instance
 *  @param saveToHistory if YES - saves message to chat history
 *  @param saveToStorage if YES - saves to local storage
 *  @param completion    completion block with failure error
 *
 *  @discussion The purpose of this method is to have a proper way of sending messages
 *  with a different message type, which does not have their own methods (e.g. contact request).
 */
- (void)sendMessage:(QBChatMessage *)message
               type:(QMMessageType)type
           toDialog:(QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(nullable QBChatCompletionBlock)completion;

/**
 *  Send message to dialog with identifier.
 *
 *  @param message          QBChatMessage instance
 *  @param dialogID         dialog identifier
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *  @param completion       completion block with failure error
 */
- (void)sendMessage:(QBChatMessage *)message
         toDialogID:(NSString *)dialogID
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(nullable QBChatCompletionBlock)completion;

/**
 *  Send message to.
 *
 *  @param message          QBChatMessage instance
 *  @param dialog           dialog instance to send message to
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *  @param completion       completion block with failure error
 */
- (void)sendMessage:(QBChatMessage *)message
           toDialog:(QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(nullable QBChatCompletionBlock)completion;

/**
 *  Send attachment message to dialog.
 *
 *  @param attachmentMessage    QBChatMessage instance with attachment
 *  @param dialog               dialog instance to send message to
 *  @param image                attachment image to upload
 *  @param completion           completion block with failure error
 */
- (void)sendAttachmentMessage:(QBChatMessage *)attachmentMessage
                     toDialog:(QBChatDialog *)dialog
          withAttachmentImage:(UIImage *)image
                   completion:(nullable QBChatCompletionBlock)completion;
/**
 *  Send attachment message to dialog.
 *
 *  @param attachmentMessage    QBChatMessage instance with attachment
 *  @param dialog               dialog instance to send message to
 *  @param attachment           QBChatAttachment instance to upload and send
 *  @param completion           completion block with failure error
 */
- (void)sendAttachmentMessage:(QBChatMessage *)attachmentMessage
                     toDialog:(QBChatDialog *)dialog
               withAttachment:(QBChatAttachment *)attachment
                   completion:(nullable QBChatCompletionBlock)completion;

//MARK: - mark as delivered

/**
 *  Mark message as delivered.
 *
 *  @param message      QBChatMessage instance to mark as delivered
 *  @param completion   completion block with failure error
 */
- (void)markMessageAsDelivered:(QBChatMessage *)message completion:(nullable QBChatCompletionBlock)completion;

/**
 *  Mark messages as delivered.
 *
 *  @param messages      array of QBChatMessage instances to mark as delivered
 *  @param completion   completion block with failure error
 */
- (void)markMessagesAsDelivered:(NSArray<QBChatMessage *> *)messages completion:(nullable QBChatCompletionBlock)completion;

//MARK: - read messages

/**
 *  Sending read status for message and updating unreadMessageCount for dialog in cache
 *
 *  @param message      QBChatMessage instance to mark as read
 *  @param completion   completion block with failure error
 */
- (void)readMessage:(QBChatMessage *)message completion:(nullable QBChatCompletionBlock)completion;

/**
 *  Sending read status for messages and updating unreadMessageCount for dialog in cache
 *
 *  @param messages     Array of QBChatMessage instances to mark as read
 *  @param dialogID     ID of dialog to update
 *  @param completion   completion block with failure error
 */
- (void)readMessages:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID completion:(nullable QBChatCompletionBlock)completion;

//MARK:- QMLinkPreview

//- (void)getLinkPreviewForMessage:(QBChatMessage *)message withCompletion:(QMLinkPreviewCompletionBlock)completion;
//
//- (QMLinkPreview *)linkPreviewForMessage:(QBChatMessage *)message;

@end

//MARK: - Bolts

/**
 *  Bolts methods for QMChatService
 */
@interface QMChatService (Bolts)

/**
 *  Connect to the chat using Bolts.
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)connect DEPRECATED_ATTRIBUTE;

/**
 *  Connect to the chat using Bolts.
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)connectWithUserID:(NSUInteger)userID password:(NSString *)password;

/**
 *  Disconnect from the chat using Bolts.
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)disconnect;

/**
 *  Join group chat dialog.
 *
 *  @param dialog group chat dialog to join
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)joinToGroupDialog:(QBChatDialog *)dialog;

/**
 *  Retrieve chat dialogs using Bolts.
 *
 *  @param extendedRequest Set of request parameters. http://quickblox.com/developers/SimpleSample-chat_users-ios#Filters
 *  @param iterationBlock  block with dialog pagination
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)allDialogsWithPageLimit:(NSUInteger)limit
                    extendedRequest:(nullable NSDictionary *)extendedRequest
                     iterationBlock:(nullable void(^)(QBResponse *response, NSArray<QBChatDialog *> * _Nullable dialogObjects, NSSet<NSNumber *> * _Nullable dialogsUsersIDs, BOOL *stop))iterationBlock;

/**
 *  Create private dialog with user if needed using Bolts.
 *
 *  @param opponent opponent user to create private dialog with
 *
 *  @return BFTask with created chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<QBChatDialog *> *)createPrivateChatDialogWithOpponent:(QBUUser *)opponent;

/**
 *  Create group chat using Bolts.
 *
 *  @param name      group chat name
 *  @param photo     group chatm photo url
 *  @param occupants array of QBUUser instances to add to chat
 *
 *  @return BFTask with created chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<QBChatDialog *> *)createGroupChatDialogWithName:(nullable NSString *)name photo:(nullable NSString *)photo occupants:(NSArray<QBUUser *> *)occupants;

/**
 *  Create private dialog if needed using Bolts.
 *
 *  @param opponentID opponent user identificatior to create dialog with
 *
 *  @return BFTask with created chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<QBChatDialog *> *)createPrivateChatDialogWithOpponentID:(NSUInteger)opponentID;

/**
 *  Change dialog name using Bolts.
 *
 *  @param dialogName new dialog name
 *  @param chatDialog chat dialog to update
 *
 *  @return BFTask with updated dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<QBChatDialog *> *)changeDialogName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog;

/**
 *  Change dialog avatar using Bolts.
 *
 *  @param avatarPublicUrl avatar url
 *  @param chatDialog      chat dialog to update
 *
 *  @return BFTask with updated dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<QBChatDialog *> *)changeDialogAvatar:(NSString *)avatarPublicUrl forChatDialog:(QBChatDialog *)chatDialog;

/**
 *  Join occupants to dialog using Bolts.
 *
 *  @param ids        occupants ids to join
 *  @param chatDialog chat dialog to update
 *
 *  @return BFTask with updated dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<QBChatDialog *> *)joinOccupantsWithIDs:(NSArray<NSNumber *> *)ids toChatDialog:(QBChatDialog *)chatDialog;

/**
 *  Delete dialog by id on server and chat cache using Bolts
 *
 *  @param dialogID id of dialog to delete
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)deleteDialogWithID:(NSString *)dialogID;

/**
 *  Fetch messages with chat dialog id using Bolts.
 *
 *  @param chatDialogID chat dialog identifier to fetch messages from
 *
 *  @return BFTask with NSArray of QBChatMessage instances
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask <NSArray<QBChatMessage *> *> *)messagesWithChatDialogID:(NSString *)chatDialogID;

/**
 *  Fetch messages with chat dialog id using Bolts.
 *
 *  @param chatDialogID     chat dialog identifier to fetch messages from
 *  @param extendedRequest  extended parameters
 *
 *  @return BFTask with NSArray of QBChatMessage instances
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask <NSArray<QBChatMessage *> *> *)messagesWithChatDialogID:(NSString *)chatDialogID
                                                  extendedRequest:(nullable NSDictionary <NSString *, NSString *> *)extendedRequest;

/**
 *  Fetch messages with chat dialog id using custom extended request using Bolts.
 *
 *  @param chatDialogID     Chat dialog id
 *  @param iterationBlock   iteration block (pagination handling)
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask <NSArray<QBChatMessage *> *> *)messagesWithChatDialogID:(NSString *)chatDialogID
                                                   iterationBlock:(nullable void(^)(QBResponse *response, NSArray * _Nullable messages, BOOL *stop))iterationBlock;

/**
 *  Fetch messages with chat dialog id using custom extended request using Bolts.
 *
 *  @param chatDialogID     Chat dialog id
 *  @param extendedRequest  extended parameters
 *  @param iterationBlock   iteration block (pagination handling)
 *
 *  @discussion Pass nil or empty dictionary into extendedRequest to load only newest messages from latest message in cache.
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask <NSArray<QBChatMessage *> *> *)messagesWithChatDialogID:(NSString *)chatDialogID
                                                  extendedRequest:(nullable NSDictionary <NSString *, NSString *> *)extendedRequest
                                                   iterationBlock:(nullable void(^)(QBResponse *response, NSArray * _Nullable messages, BOOL *stop))iterationBlock;

/**
 *  Loads messages that are older than oldest message in cache.
 *
 *  @param chatDialogID     chat dialog identifier
 *
 *  @return BFTask instance of QBChatMessage's array
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask <NSArray<QBChatMessage *> *> *)loadEarlierMessagesWithChatDialogID:(NSString *)chatDialogID;

/**
 *  Fetch dialog with identifier using Bolts.
 *
 *  @param dialogID dialog identifier to fetch
 *
 *  @return BFTask with chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<QBChatDialog *> *)fetchDialogWithID:(NSString *)dialogID;

/**
 *  Load dialog with dialog identifier from server and saving to memory storage and cache using Bolts.
 *
 *  @param dialogID dialog identifier to load.
 *
 *  @return BFTask with chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<QBChatDialog *> *)loadDialogWithID:(NSString *)dialogID;

/**
 *  Fetch dialog with last activity date from date using Bolts.
 *
 *  @param date         date to fetch dialogs from
 *  @param limit        page limit
 *  @param iterationBlock    iteration block with dialogs for pages
 *
 *  @return BFTask with chat dialog
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)fetchDialogsUpdatedFromDate:(NSDate *)date
                           andPageLimit:(NSUInteger)limit
                         iterationBlock:(nullable void(^)(QBResponse *response, NSArray<QBChatDialog *> * _Nullable dialogObjects, NSSet<NSNumber *> * _Nullable dialogsUsersIDs, BOOL *stop))iterationBlock;

/**
 *  Send system message to users about adding to dialog with dialog inside using Bolts.
 *
 *  @param chatDialog   created dialog we notificate about
 *  @param usersIDs     array of users id to send message
 *  @param text         text to users
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendSystemMessageAboutAddingToDialog:(QBChatDialog *)chatDialog
                                      toUsersIDs:(NSArray<NSNumber *> *)usersIDs
                                        withText:(nullable NSString *)text;

/**
 *  Send message about accepting or rejecting contact requst using Bolts.
 *
 *  @param accept     YES - accept, NO reject
 *  @param opponentID   opponent ID
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendMessageAboutAcceptingContactRequest:(BOOL)accept
                                       toOpponentID:(NSUInteger)opponentID;

/**
 *  Sending notification message about adding occupants to specific dialog using Bolts.
 *
 *  @param occupantsIDs     array of occupants that were added to a specific dialog
 *  @param chatDialog       chat dialog to send notification message to
 *  @param notificationText notification message body (text)
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendNotificationMessageAboutAddingOccupants:(NSArray<NSNumber *> *)occupantsIDs
                                               toDialog:(QBChatDialog *)chatDialog
                                   withNotificationText:(NSString *)notificationText;

/**
 *  Sending notification message about leaving dialog using Bolts.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendNotificationMessageAboutLeavingDialog:(QBChatDialog *)chatDialog
                                 withNotificationText:(NSString *)notificationText;

/**
 *  Sending notification message about changing dialog photo using Bolts.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendNotificationMessageAboutChangingDialogPhoto:(QBChatDialog *)chatDialog
                                       withNotificationText:(NSString *)notificationText;

/**
 *  Sending notification message about changing dialog name.
 *
 *  @param chatDialog       chat dialog to send message to
 *  @param notificationText notification message body (text)
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendNotificationMessageAboutChangingDialogName:(QBChatDialog *)chatDialog
                                      withNotificationText:(NSString *)notificationText;

/**
 *  Send message with a specific message type to dialog with identifier using Bolts.
 *
 *  @param message       QBChatMessage instance
 *  @param type          QMMessageType type
 *  @param dialog        QBChatDialog instance
 *  @param saveToHistory if YES - saves message to chat history
 *  @param saveToStorage if YES - saves to local storage
 *
 *  @discussion The purpose of this method is to have a proper way of sending messages
 *  with a different message type, which does not have their own methods (e.g. contact request).
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendMessage:(QBChatMessage *)message
                   type:(QMMessageType)type
               toDialog:(QBChatDialog *)dialog
          saveToHistory:(BOOL)saveToHistory
          saveToStorage:(BOOL)saveToStorage;

/**
 *  Send message to dialog with identifier using Bolts.
 *
 *  @param message          QBChatMessage instance
 *  @param dialogID         dialog identifier
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendMessage:(QBChatMessage *)message
             toDialogID:(NSString *)dialogID
          saveToHistory:(BOOL)saveToHistory
          saveToStorage:(BOOL)saveToStorage;

/**
 *  Send message to using Bolts.
 *
 *  @param message          QBChatMessage instance
 *  @param dialog           dialog instance to send message to
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendMessage:(QBChatMessage *)message
               toDialog:(QBChatDialog *)dialog
          saveToHistory:(BOOL)saveToHistory
          saveToStorage:(BOOL)saveToStorage;

/**
 *  Send attachment message to dialog using Bolts.
 *
 *  @param attachmentMessage    QBChatMessage instance with attachment
 *  @param dialog               dialog instance to send message to
 *  @param image                attachment image to upload
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendAttachmentMessage:(QBChatMessage *)attachmentMessage
                         toDialog:(QBChatDialog *)dialog
              withAttachmentImage:(UIImage *)image;

/**
 *  Send attachment message to dialog using Bolts.
 *
 *  @param attachmentMessage    QBChatMessage instance with attachment
 *  @param dialog               dialog instance to send message to
 *  @param attachment           QBChatAttachment instance to upload and send
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)sendAttachmentMessage:(QBChatMessage *)attachmentMessage
                         toDialog:(QBChatDialog *)dialog
                   withAttachment:(QBChatAttachment *)attachment;

/**
 *  Mark message as delivered.
 *
 *  @param message      QBChatMessage instance to mark as delivered
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)markMessageAsDelivered:(QBChatMessage *)message;

/**
 *  Mark messages as delivered.
 *
 *  @param messages      array of QBChatMessage instances to mark as delivered
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)markMessagesAsDelivered:(NSArray<QBChatMessage *> *)messages;

/**
 *  Sending read status for message and updating unreadMessageCount for dialog in cache
 *
 *  @param message      QBChatMessage instance to mark as read
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)readMessage:(QBChatMessage *)message;

/**
 *  Sending read status for messages and updating unreadMessageCount for dialog in cache
 *
 *  @param messages     Array of QBChatMessage instances to mark as read
 *  @param dialogID     ID of dialog to update
 *
 *  @return BFTask with failure error
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask *)readMessages:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID;


/**
 * Loads the later messages which were added to the cache after the last message in the memory storage and saves them to the memory storage.
 *
 * @param dialogID      ID of dialog to update
 *
 * @return BFTask with 'NSArray' instance.
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<NSArray<QBChatMessage *>*> *)syncMessagesWithCacheForDialogID:(NSString *)dialogID;

/**
 * Loads the later dialogs which were added to the cache after the last message in the memory storage and saves them to the memory storage.
 *
 * @param date 'NSDate' instance to sync dialogs from
 *
 * @return BFTask with 'NSArray' instance.
 *
 *  @see In order to know how to work with BFTask's see documentation https://github.com/BoltsFramework/Bolts-iOS#bolts
 */
- (BFTask<NSArray<QBChatDialog *>*> *)syncLaterDialogsWithCacheFromDate:(NSDate *)date;

@end

@protocol QMChatServiceCacheDataSource <NSObject>
@required

/**
 * Is called when chat service will start. Need to use for inserting initial data QMDialogsMemoryStorage
 *
 *  @param block Block for provide QBChatDialogs collection
 */
- (void)cachedDialogs:(nullable QMCacheCollection)block;

/**
 *  Will return dialog with specific identificator from cache or nil if dialog doesn't exist
 *
 *  @param dialogID   dialog identificator
 *  @param completion completion block with dialog
 */
- (void)cachedDialogWithID:(NSString *)dialogID completion:(nullable void (^)(QBChatDialog * _Nullable dialog))completion;

/**
 *  Is called when begin fetch messages. @see -messagesWithChatDialogID:completion:
 *  Need to use for inserting initial data QMMessagesMemoryStorage by dialogID
 *
 *  @param dialogID Dialog ID
 *  @param block    Block for provide QBChatMessages collection
 */
- (void)cachedMessagesWithDialogID:(NSString *)dialogID block:(nullable QMCacheCollection)block;

@optional

/**
 *  Is called when begin fetch messages with predicate.
 *  Need to use for inserting to 'QMMessagesMemoryStorage' instance
 *
 *  @param predicate NSPredicate instance
 *  @param block    Block for providing QBChatMessages collection
 */
- (void)cachedMessagesWithPredicate:(NSPredicate *)predicate
                              block:(nullable QMCacheCollection)block;

/**
 *  Is called when begin fetch dialogs with predicate.
 *  Need to use for inserting to 'QMDialogsMemoryStorage' instance
 *
 *  @param predicate NSPredicate instance
 *  @param block    Block for providing QBChatDialog collection
 */
- (void)cachedDialogsWithPredicate:(NSPredicate *)predicate
                             block:(nullable QMCacheCollection)block;

@end

@protocol QMChatServiceDelegate <NSObject>
@optional
/**
 *  Is called when ChatDialogs did load from cache.
 *
 *  @param chatService      instance
 *  @param dialogs          array of QBChatDialogs loaded from cache
 *  @param dialogsUsersIDs  all users from all ChatDialogs
 */
- (void)chatService:(QMChatService *)chatService didLoadChatDialogsFromCache:(NSArray<QBChatDialog *> *)dialogs withUsers:(NSSet<NSNumber *> *)dialogsUsersIDs;

/**
 *  Is called when messages did load from cache for some dialog.
 *
 *  @param chatService instance
 *  @param messages array of QBChatMessages loaded from cache
 *  @param dialogID messages dialog ID
 */
- (void)chatService:(QMChatService *)chatService didLoadMessagesFromCache:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID;

/**
 *  Is called when dialog instance did add to memmory storage.
 *
 *  @param chatService instance
 *  @param chatDialog QBChatDialog has added to memory storage
 */
- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog;

/**
 *  Is called when dialogs array did add to memmory storage.
 *
 *  @param chatService instance
 *  @param chatDialogs QBChatDialog items has added to memory storage
 */
- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray<QBChatDialog *> *)chatDialogs;

/**
 *  Is called when some dialog did update in memory storage
 *
 *  @param chatService instance
 *  @param chatDialog updated QBChatDialog
 */
- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog;

/**
 *  Is called when some dialogs did update in memory storage
 *
 *  @param chatService instance
 *  @param dialogs     updated array of QBChatDialog's
 */
- (void)chatService:(QMChatService *)chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)dialogs;

/**
 *  Is called when some dialog did delete from memory storage
 *
 *  @param chatService instance
 *  @param chatDialogID deleted QBChatDialog
 */
- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID;

/**
 *  Is called when message did add to memory storage for dialog with id
 *
 *  @param chatService instance
 *  @param message added QBChatMessage
 *  @param dialogID message dialog ID
 */
- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID;

/**
 *  Is called when message did update in memory storage for dialog with id
 *
 *  @param chatService instance
 *  @param message updated QBChatMessage
 *  @param dialogID message dialog ID
 */
- (void)chatService:(QMChatService *)chatService didUpdateMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID;

/**
 *  Is called when message did update in memory storage for dialog with id
 *
 *  @param chatService  instance
 *  @param messages     array of updated messages
 *  @param dialogID     messages dialog ID
 */
- (void)chatService:(QMChatService *)chatService didUpdateMessages:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID;

/**
 *  Is called when messages did add to memory storage for dialog with id
 *
 *  @param chatService instance
 *  @param messages array of QBChatMessage
 *  @param dialogID message dialog ID
 */
- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray<QBChatMessage *>*)messages forDialogID:(NSString *)dialogID;

/**
 *  Is called when message was deleted from memory storage for dialog id
 *
 *  @param chatService chat service instance
 *  @param message     message that was deleted
 *  @param dialogID    dialog identifier of deleted message
 */
- (void)chatService:(QMChatService *)chatService didDeleteMessageFromMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID;

/**
 *  Is called when messages was deleted from memory storage for dialog id
 *
 *  @param chatService chat service instance
 *  @param messages    messages that were deleted
 *  @param dialogID    dialog identifier of deleted messages
 */
- (void)chatService:(QMChatService *)chatService didDeleteMessagesFromMemoryStorage:(NSArray<QBChatMessage *>*)messages forDialogID:(NSString *)dialogID;

/**
 *  Is called when chat service did receive notification message
 *
 *  @param chatService instance
 *  @param message received notification message
 *  @param dialog QBChatDialog from notification message
 */
- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog;

@end

/**
 *  Chat connection delegate can handle chat stream events. Like did connect, did reconnect etc...
 */

@protocol QMChatConnectionDelegate <NSObject>
@optional

/**
 *  Called when chat service did start connecting to the chat.
 *
 *  @param chatService QMChatService instance
 */
- (void)chatServiceChatHasStartedConnecting:(QMChatService *)chatService;

/**
 *  It called when chat did connect.
 *
 *  @param chatService instance
 */
- (void)chatServiceChatDidConnect:(QMChatService *)chatService;

/**
 *  Called when chat did not connect.
 *
 *  @param chatService instance
 *  @param error       connection failure error
 */
- (void)chatService:(QMChatService *)chatService chatDidNotConnectWithError:(NSError *)error;

/**
 *  It called when chat did accidentally disconnect
 *
 *  @param chatService instance
 */
- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)chatService;

/**
 *  It called when chat did reconnect
 *
 *  @param chatService instance
 */
- (void)chatServiceChatDidReconnect:(QMChatService *)chatService;

/**
 *  It called when chat did catch error from chat stream
 *
 *  @param error NSError from stream
 */
- (void)chatServiceChatDidFailWithStreamError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
