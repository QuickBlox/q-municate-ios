 //
//  QMChatService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 17/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatService.h"
#import "QMContactList.h"
#import "NSArray+ArrayToString.h"
#import <TWMessageBarManager.h>
#import "QMDBStorage+Messages.h"
#import  <Quickblox/Quickblox.h>


@interface QMChatService () <QBChatDelegate, QBActionStatusDelegate>

@property (copy, nonatomic) QBChatResultBlock chatBlock;
@property (copy, nonatomic) QBChatRoomResultBlock chatRoomResultBlock;
@property (copy, nonatomic) QBChatDialogResultBlock chatDialogResultBlock;
@property (copy, nonatomic) QBChatDialogHistoryBlock chatDialogHistoryBlock;


/** Video Chat */
@property (strong, nonatomic) QBWebRTCVideoChat *activeStream;

@property (strong, nonatomic) NSString *currentSessionID;
@property (nonatomic, strong) NSDictionary *customParams;
@property (nonatomic, assign) QMVideoChatType callType;

/** */
@property (strong, nonatomic) NSTimer *presenceTimer;

/** Upload message needed for replacing with delivered message in chat hisoty. When used, it means that upload finished, and message has been delivered */
@property (strong, nonatomic) QMChatUploadingMessage *uploadingMessage;

@end

@implementation QMChatService
@synthesize currentSessionID;


+ (instancetype)shared {
    static id chatServiceInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chatServiceInstance = [[self alloc] init];
    });
    return chatServiceInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.allConversations = [NSMutableDictionary new];
        [QBChat instance].delegate = self;
    }
    return self;
}

#pragma mark - LogIn & LogOut

- (void)loginWithUser:(QBUUser *)user completion:(QBChatResultBlock)block
{
    _chatBlock = block;
    
    [[QBChat instance] loginWithUser:user];
}

- (void)logOut
{
    [[QBChat instance] logout];
    _loggedIn = NO;
	[self.presenceTimer invalidate];
    self.presenceTimer = nil;
}


#pragma mark - STATUS

- (void)sendPresence
{
    NSString *status = [[NSUserDefaults standardUserDefaults] objectForKey:kUserStatusText];
    if (status != nil) {
        [[QBChat instance] sendPresenceWithStatus:status];
        return;
    }
    [[QBChat instance] sendPresence];
}


#pragma mark - Contact List (ROSTER)

/** Contact Requests */
- (void)sendFriendsRequestToUserWithID:(NSUInteger)userID
{
    [[QBChat instance] addUserToContactListRequest:userID];
}

- (void)confirmFriendsRequestFromUserWithID:(NSUInteger)userID
{
    [[QBChat instance] confirmAddContactRequest:userID];
}

- (void)rejectFriendsRequestFromUserWithID:(NSUInteger)userID
{
    [[QBChat instance] rejectAddContactRequest:userID];
}

- (void)removeContactFromFriendsWithID:(NSUInteger)userID
{
    [[QBChat instance] removeUserFromContactList:userID];
}

/** DELEGATES */
- (void)chatContactListDidChange:(QBContactList *)contactList
{
    NSLog(@"%@", [contactList description]);
    
    [[QMContactList shared] retrieveFriendsWithContactListInfo:contactList completion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsReloadedNotification object:nil];
    }];
}

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID
{
    [self confirmFriendsRequestFromUserWithID:userID];
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status
{
    ILog(@"UserID:%lu, online: %hhd, status:%@", (unsigned long)userID, isOnline, status);
}


#pragma mark -
#pragma mark - Audio/Video Calls


- (void)initActiveStreamWithOpponentView:(QBVideoView *)opponentView sessionID:(NSString *)sessionID callType:(QMVideoChatType)type
{
    // Active stream initialize:
    if (sessionID == nil)
    {
        self.activeStream = [[QBChat instance] createWebRTCVideoChatInstance];
    } else {
        self.activeStream = [[QBChat instance] createAndRegisterWebRTCVideoChatInstanceWithSessionID:currentSessionID];
    }
    // set conference type:
    self.activeStream.currentConferenceType = (int)type;
    
    // set opponent' view
    self.activeStream.viewToRenderOpponentVideoStream = opponentView;
}

- (void)releaseActiveStream
{
    //Destroy active stream:
    [[QBChat instance] unregisterWebRTCVideoChatInstance:self.activeStream];
    
    [self clearCallsCacheParams];
}

- (void)callUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView callType:(QMVideoChatType)callType
{
    [self initActiveStreamWithOpponentView:opponentView sessionID:nil callType:callType];
    [self.activeStream callUser:userID];
}

- (void)acceptCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView
{
    [self initActiveStreamWithOpponentView:opponentView sessionID:self.currentSessionID callType:self.callType];
    
    self.activeStream.viewToRenderOpponentVideoStream.remotePlatform = self.customParams[qbvideochat_platform];
    self.activeStream.viewToRenderOpponentVideoStream.remoteVideoOrientation = [QBChatUtils interfaceOrientationFromString:self.customParams[qbvideochat_device_orientation]];
    
    [self.activeStream acceptCallWithOpponentID:userID customParameters:self.customParams];
}

- (void)rejectCallFromUser:(NSUInteger)userID opponentView:(QBVideoView *)opponentView
{
    [self initActiveStreamWithOpponentView:opponentView sessionID:self.currentSessionID callType:self.callType];
    [self.activeStream rejectCallWithOpponentID:userID];
    [self releaseActiveStream];
}

- (void)cancelCall
{
    [self.activeStream finishCall];
    [self releaseActiveStream];
}

- (void)finishCall
{
    [self cancelCall];
}



#pragma mark - QBChatDelegate - Login to Chat

//Chat Login
- (void)chatDidLogin
{
    if (self.presenceTimer == nil) {
        self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(sendPresence) userInfo:nil repeats:YES];
    }
    
    // set is logged in flag:
    _loggedIn = YES;
    
    if (_chatBlock != nil) {
        _chatBlock(YES);
        _chatBlock = nil;
    }
}

- (void)chatDidNotLogin
{
    if (_chatBlock != nil) {
        _chatBlock(NO);
        _chatBlock = nil;
    }
}


#pragma mark - QBChatDelegate - Audio/Video Calls

// incoming call:
- (void)chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString *)_sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType customParameters:(NSDictionary *)customParameters
{
    self.customParams = customParameters;
    self.currentSessionID = _sessionID;
    self.callType = (NSUInteger)conferenceType;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kIncomingCallNotification object:nil userInfo:@{@"id" : @(userID), @"type" : @(conferenceType)}];
}

// call accepted:
- (void)chatCallDidAcceptByUser:(NSUInteger)userID
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallDidAcceptByUserNotification object:nil];
}

// call started:
- (void)chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallDidStartedByUserNotification object:nil];
}

// call rejected:
- (void)chatCallDidRejectByUser:(NSUInteger)userID
{
    [self releaseActiveStream];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasRejectedNotification object:nil];
}

// user doesn't answer:
-(void) chatCallUserDidNotAnswer:(NSUInteger)userID
{
    [self releaseActiveStream];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:@{@"reason":kStopVideoChatCallStatus_OpponentDidNotAnswer}];
}

// call finished of canceled:
- (void)chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status
{
    [self releaseActiveStream];
    
    NSString *stopCallReason = nil;
    if ([status isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]) {
        stopCallReason = kStopVideoChatCallStatus_OpponentDidNotAnswer;
    } else if ([status isEqualToString:kStopVideoChatCallStatus_Manually]) {
        stopCallReason = kStopVideoChatCallStatus_Manually;
    } else if ([status isEqualToString:kStopVideoChatCallStatus_Cancel]) {
        stopCallReason = kStopVideoChatCallStatus_Cancel;
    } else if ([status isEqualToString:kStopVideoChatCallStatus_BadConnection]) {
        stopCallReason = kStopVideoChatCallStatus_BadConnection;
    }
    
    if (status == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:@{@"reason":stopCallReason}];
}

- (void)clearCallsCacheParams
{
    self.customParams = nil;
    self.currentSessionID = nil;
    self.callType = 0;
}


#pragma mark - Chat Dialogs

- (void)fetchAllDialogsWithCompletion:(void(^)(NSArray *dialogs, NSError *error))completionHandler
{
    QBResultBlock resBlock = ^(Result *result) {
        if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
            NSArray *dialogs = ((QBDialogsPagedResult *)result).dialogs;
            
            // load dialogs to dictionary:
            self.allDialogsAsDictionary = [self dialogsAsDictionaryFromDialogsArray:dialogs];
            
            completionHandler(dialogs, nil);
            return;
        }
        completionHandler(nil, result.errors[0]);
    };
    [QBChat dialogsWithDelegate:self context:Block_copy((__bridge void *)(resBlock))];
    
}

- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent completion:(QBChatDialogResultBlock)completionHandler
{
    NSString *opponentID = [NSString stringWithFormat:@"%lu", (unsigned long)opponent.ID];
    NSArray *occupantsIDs = @[opponentID];
    
    // creating private chat dialog:
    QBChatDialog *newDialog = [[QBChatDialog alloc] init];
    
    newDialog.type = QBChatDialogTypePrivate;
    newDialog.occupantIDs = occupantsIDs;
    
    
    QBResultBlock resultBlock = ^(Result *result) {
        if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
            QBChatDialog *chatDialog = ((QBChatDialogResult *)result).dialog;
            completionHandler(chatDialog, nil);
            return;
        }
        completionHandler(nil, result.errors[0]);
    };
    
	[QBChat createDialog:newDialog delegate:self context:Block_copy((__bridge void *)(resultBlock))];
}

- (void)createChatDialog:(QBChatDialog *)chatDialog withCompletion:(QBChatDialogResultBlock)completionHandler
{
	 QBResultBlock resultBlock = ^(Result *result) {
        if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
            QBChatDialog *chatDialog = ((QBChatDialogResult *)result).dialog;
            completionHandler(chatDialog, nil);
            return;
        }
         completionHandler(nil, result.errors[0]);
     };
    
	[QBChat createDialog:chatDialog delegate:self context:Block_copy((__bridge void *)(resultBlock))];
}

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completionHandler
{
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[@"name"] = dialogName;
    
    [self updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialog *dialog, NSError *error) {
        completionHandler(dialog, error);
    }];
}

- (void)addUsers:(NSArray *)users toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completionHandler
{
    NSString *usersIDsAsString = [users stringFromArray];
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[@"push[occupants_ids][]"] = usersIDsAsString;
    
    [self updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialog *dialog, NSError *error) {
        completionHandler(dialog, error);
    }];
}

- (void)leaveChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completionHandler
{
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    extendedRequest[@"pull_all[occupants_ids][]"] = [NSString stringWithFormat:@"%lu", (unsigned long)[QMContactList shared].me.ID];
    
    [self updateChatDialogWithID:chatDialog.ID extendedRequest:extendedRequest completion:^(QBChatDialog *dialog, NSError *error) {
        completionHandler(dialog, error);
    }];
}

/** ABSTRACT UPDATE CHAT DIALOG METHOD */

- (void)updateChatDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest completion:(QBChatDialogResultBlock)completionHandler
{
    QBResultBlock resultBlock = ^(Result *result) {
        if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
            QBChatDialog *chatDialog = ((QBChatDialogResult *)result).dialog;
            
            // save to history:
            self.allDialogsAsDictionary[chatDialog.roomJID] = chatDialog;
            
            completionHandler(chatDialog, nil);
            return;
        }
        completionHandler(nil, result.errors[0]);
    };
    
    [QBChat updateDialogWithID:dialogID extendedRequest:extendedRequest delegate:self context:Block_copy((__bridge void *)(resultBlock))];
}


#pragma mark - Chat

- (void)joinRoomsForDialogs:(NSArray *)chatDialogs
{
    for (QBChatDialog *dialog in chatDialogs) {
        if (dialog.type == QBChatDialogTypePrivate) {
            continue;
        }
        // check for existing room:
        QBChatRoom *existRoom = self.allChatRoomsAsDictionary[dialog.roomJID];
        if (existRoom != nil && existRoom.isJoined) {
            continue;
        }
        [self joinRoomWithRoomJID:dialog.roomJID];
    }
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message
{
    if (message.delayed) {
        return;
    }
    // check for notification:
    if (message.customParameters[@"notification_type"] != nil) {
        [self createOrUpdateChatDialogFromChatMessage:message];

        [[NSNotificationCenter defaultCenter] postNotificationName:kChatDialogsDidLoadedNotification object:nil];
        return;
    }

    // find opponent and fetch if needed:
    [self searchForOpponentWithIDAndFetchIfNeeded:message.senderID];
    
//    // show popup message:
//    [[TWMessageBarManager sharedInstance] showMessageWithTitle:opponent.fullName description:message.text type:TWMessageBarMessageTypeInfo duration:5.0f callback:nil];
    
    NSString *dialogKey = [NSString stringWithFormat:@"%lu", (unsigned long)message.senderID];
    [self saveMessageToLocalHistory:message chatDialogKey:dialogKey];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kChatDidReceiveMessage object:nil];
}

- (void)chatDidFailWithError:(NSInteger)code
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kChatDidFailWithError
                                                        object:nil
                                                      userInfo:@{@"errorCode" : @(code)}];
}

- (void)sendMessage:(QBChatMessage *)message
{
    // send message:
	[[QBChat instance] sendMessage:message];
    
    // check for notification message. If exist, ignore them
    if (message.customParameters[@"notification_type"]) {
        return;
    }
    
    // get dialog entity with current user:
    NSString *kRecipientID = [@(message.recipientID) stringValue];
    QBChatDialog *currentDialog = self.allDialogsAsDictionary[kRecipientID];
    if (currentDialog != nil) {
        
        // update dialog:
        [self updateDialogsLastMessageFields:currentDialog forLastMessage:message];
        
        // get chat history with current dialog id:
        NSMutableArray *currentHistory = self.allConversations[currentDialog.ID];
        if (currentHistory != nil) {
            
            if ([message isKindOfClass:QMChatUploadingMessage.class]) {
                // convert upload message to chat message & replace it:
                QBChatMessage *validMessage = [self chatMessageFromContentMessage:(QMChatUploadingMessage *)message];
                NSUInteger contentMessageIndex = [currentHistory indexOfObject:message];
                [currentHistory replaceObjectAtIndex:contentMessageIndex withObject:validMessage];
                return;
            }
            [currentHistory addObject:message];
            return;
        }
        currentHistory = [@[message] mutableCopy];
        self.allConversations[currentDialog.ID] = currentHistory;
    }
}

- (void)sendChatDialogDidCreateNotificationToUsers:(NSArray *)users withChatDialog:(QBChatDialog *)chatDialog
{
    QBUUser *me = [QMContactList shared].me;
    for (QBUUser *user in users) {
        
        if ([user isEqual:me]) {
            continue;
        }
        // create message:
        QBChatMessage *inviteMessage = [QBChatMessage message];
        inviteMessage.recipientID = user.ID;
        inviteMessage.text = [NSString stringWithFormat:@"%@ created a group conversation", me.fullName];
        
        NSMutableDictionary *customParams = [NSMutableDictionary new];
        if (chatDialog.roomJID) {
             customParams[@"xmpp_room_jid"] = chatDialog.roomJID;
        }
        if (chatDialog.name) {
             customParams[@"name"] = chatDialog.name;
        }
        customParams[@"_id"] = chatDialog.ID;
        customParams[@"type"] = @(chatDialog.type);
        customParams[@"occupants_ids"] = [chatDialog.occupantIDs stringFromArray];
        
        NSTimeInterval timestamp = (unsigned long)[[NSDate date] timeIntervalSince1970];
        customParams[@"date_sent"] = @(timestamp);
        
        // save to hostory:
        customParams[@"notification_type"] = @"1";
        
        inviteMessage.customParameters = customParams;
        
        [[QBChat instance] sendMessage:inviteMessage];
    }
}

- (void)sendChatDialogDidUpdateNotificationToUsers:(NSArray *)users withChatDialog:(QBChatDialog *)chatDialog
{
    QBUUser *me = [QMContactList shared].me;
    for (QBUUser *user in users) {
        if ([user isEqual:me]) {
            continue;
        }
        // create message:
        QBChatMessage *updateMessage = [QBChatMessage message];
        updateMessage.recipientID = user.ID;
        
        NSMutableDictionary *customParams = [NSMutableDictionary new];
        customParams[@"name"] = chatDialog.name;
        customParams[@"occupants_ids"] = [chatDialog.occupantIDs stringFromArray];

        // notification type: 2 = Chat dialog was updated:
        customParams[@"notification_type"] = @"2";
        
        updateMessage.customParameters = customParams;
        
        [[QBChat instance] sendMessage:updateMessage];
    }
}

- (void)sendContentMessage:(QMChatUploadingMessage *)contentMessage withBlob:(QBCBlob *)blob
{
    QBChatAttachment *attachment = [[QBChatAttachment alloc] init];
    attachment.type = @"photo";
    attachment.url = [blob publicUrl];
    attachment.ID = [@(blob.ID) stringValue];
    
    contentMessage.attachments = @[attachment];
    
    if (contentMessage.roomJID != nil) {
        QBChatRoom *currentRoom = self.allChatRoomsAsDictionary[contentMessage.roomJID];
        if (currentRoom != nil) {
            [self sendMessage:contentMessage toRoom:currentRoom];
        }
    }
    
    // additional params:
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSTimeInterval timestamp = (unsigned long)[[NSDate date] timeIntervalSince1970];
    params[@"date_sent"] = @(timestamp);
    params[@"save_to_history"] = @YES;
    contentMessage.customParameters = params;
    
    [self sendMessage:contentMessage];
}


#pragma mark - Group Chat

- (void)joinRoomWithRoomJID:(NSString *)roomJID;
{
    QBChatRoom *chatRoom = [[QBChatRoom alloc] initWithRoomJID:roomJID];
    [chatRoom joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
    
    if (self.allChatRoomsAsDictionary == nil) {
        self.allChatRoomsAsDictionary = [NSMutableDictionary new];
    }
    self.allChatRoomsAsDictionary[chatRoom.JID] = chatRoom;
}

- (void)getMessageHistoryWithDialogID:(NSString *)dialogIDString withCompletion:(void(^)(NSArray *messages, BOOL success, NSError *error))block
{
    
	QBResultBlock resulBlock = ^(Result *result) {
        
        if (result.success && [result isKindOfClass:[QBChatHistoryMessageResult class]]) {
            
            NSArray *messages = ((QBChatHistoryMessageResult *)result).messages;
#warning Storage turned off
//            [self.dbStorage cacheQBChatMessages:messages withDialogId:dialogIDString finish:^{
//                block(messages, YES, nil);
//            }];
            block(messages, YES, nil);
        }else {
            block(nil, NO, result.errors[0]);
        }
        
    };
	[QBChat messagesWithDialogID:dialogIDString delegate:self context:Block_copy((__bridge void *)(resulBlock))];
}

- (void)sendMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)chatRoom
{
    // send message to user:
    [[QBChat instance] sendChatMessage:message toRoom:chatRoom];
    
    // cache upload message for replace with delivered message:
    if ([message isKindOfClass:[QMChatUploadingMessage class]]) {
        self.uploadingMessage = (QMChatUploadingMessage *)message;
    }
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID
{
    if (self.uploadingMessage != nil) {
        // track all incoming messages with attachments:
        if ([message.attachments count] > 0) {
            // if message is mine:
            if (message.senderID == [QMContactList shared].me.ID) {
                // get history and replace messages:
                NSMutableArray *messageHistory = self.allConversations[roomJID];
                NSUInteger index = [messageHistory indexOfObject:self.uploadingMessage];
                [messageHistory replaceObjectAtIndex:index withObject:message];
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDidReceiveMessageNotification object:nil];
                
                // release cached upload message:
                self.uploadingMessage = nil;
                return;
            }
        }
    }
    // if not my message:
    if (message.senderID != [QMContactList shared].me.ID) {
        // find user:
        [self searchForOpponentWithIDAndFetchIfNeeded:message.senderID];
    }
    
    [self saveMessageToLocalHistory:message chatDialogKey:roomJID];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDidReceiveMessageNotification object:nil];
}

- (void)chatRoomDidReceiveInformation:(NSDictionary *)information room:(NSString *)roomName
{
    //
}

- (void)chatRoomDidCreate:(NSString *)roomName
{
    //
}

- (void)chatRoomDidEnter:(QBChatRoom *)room
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDidEnterNotification object:nil];
}

- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error
{
	if (_chatRoomResultBlock) {
		[QMChatService shared].chatRoom = nil;
		_chatRoomResultBlock(nil, error);
		_chatRoomResultBlock = nil;
	}
}

- (void)chatRoomDidLeave:(NSString *)roomName
{
	// You leaved room
}

- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName
{
    //
}

- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomDidChangeOnlineUsersList object:nil userInfo:@{@"online_users":users}];
} 


#pragma mark - Chat Utils

- (QBChatMessage *)chatMessageFromContentMessage:(QMChatUploadingMessage *)uploadingMessage
{
    QBChatMessage *newMessage = [QBChatMessage message];
    newMessage.text = uploadingMessage.text;
    newMessage.recipientID = uploadingMessage.recipientID;
    newMessage.senderID = uploadingMessage.senderID;
    newMessage.attachments = uploadingMessage.attachments;
    return newMessage;
}

- (void)saveMessageToLocalHistory:(QBChatMessage *)message chatDialogKey:(NSString *)dialogKey
{
    // get dialog entity with current user:
    QBChatDialog *chatDialog = self.allDialogsAsDictionary[dialogKey];
    
    if (chatDialog == nil) {
         NSAssert(!chatDialog, @"Dialog you are looking for not found.");
    }
    
    // update dialog:
    [self updateDialogsLastMessageFields:chatDialog forLastMessage:message];
    
    // get chat history with current dialog id:
    NSMutableArray *currentHistory = self.allConversations[chatDialog.ID];
    if (currentHistory != nil) {
        [currentHistory addObject:message];
    } else {
        currentHistory = [@[message] mutableCopy];
        self.allConversations[chatDialog.ID] = currentHistory;
    }
    
}

- (QBChatDialog *)chatDialogForFriendWithID:(NSUInteger)ID
{
    NSString *kUserID = [NSString stringWithFormat:@"%lu", (unsigned long)ID];
    QBChatDialog *dialog= self.allDialogsAsDictionary[kUserID];
    
    return dialog;
}

- (QBChatDialog *)createChatDialogForChatMessage:(QBChatMessage *)chatMessage
{
    QBChatDialog *chatDialog = [[QBChatDialog alloc] init];
    
    chatDialog.ID = chatMessage.customParameters[@"_id"];
    chatDialog.roomJID = chatMessage.customParameters[@"xmpp_room_jid"];
    chatDialog.name = chatMessage.customParameters[@"name"];
    chatDialog.type = [chatMessage.customParameters[@"type"] intValue];
    
    NSString *occupantsIDs = chatMessage.customParameters[@"occupants_ids"];
    chatDialog.occupantIDs = [self stringToArray:occupantsIDs];
    
    return chatDialog;
}

/** Only for Group dialogs */
- (void)updateChatDialogForChatMessage:(QBChatMessage *)chatMessage
{
    NSString *kRoomJID = chatMessage.customParameters[@"xmpp_room_jid"];
    
    QBChatDialog *dialog = self.allDialogsAsDictionary[kRoomJID];
    if (dialog == nil) {
        NSAssert(!dialog, @"Dialog you are looking for not found.");
        return;
    }
    
    dialog.name = chatMessage.customParameters[@"name"];
    
    NSString *occupantsIDs = chatMessage.customParameters[@"occupants_ids"];
    dialog.occupantIDs = [self stringToArray:occupantsIDs];
}

- (void)createOrUpdateChatDialogFromChatMessage:(QBChatMessage *)message
{
    NSInteger notificationType = [message.customParameters[@"notification_type"] intValue];
    
    // if notification type = update dialog:
    if (notificationType == 2) {
        [self updateChatDialogForChatMessage:message];
        return;
    }
    
    // if notification type = create dialog:
    QBChatDialog *newDialog = [self createChatDialogForChatMessage:message];
    
    // save to history:
    if (newDialog.type == QBChatDialogTypePrivate) {
        NSString *kSenderID = [NSString stringWithFormat:@"%lu",(unsigned long)message.senderID];
        self.allDialogsAsDictionary[kSenderID] = newDialog;
        return;
    }
    // if dialog type = group:
    self.allDialogsAsDictionary[newDialog.roomJID] = newDialog;
    
    // if user is not joined to room, join:
    if (![self userIsJoinedRoomWithJID:newDialog.roomJID]) {
        [self joinRoomWithRoomJID:newDialog.roomJID];
    }
}

- (void)updateDialogsLastMessageFields:(QBChatDialog *)dialog forLastMessage:(QBChatMessage *)message
{
    dialog.lastMessageDate = message.datetime;
    dialog.lastMessageText = message.text;
    dialog.lastMessageUserID = message.senderID;
    if (message.senderID != [QMContactList shared].me.ID) {
        dialog.unreadMessageCount +=1;
    }
}

//- (QBChatDialog *)createPrivateDialogWithOpponentID:(NSString *)opponentID message:(QBChatMessage *)message
//{
//    QBChatDialog *newDialog = [QBChatDialog new];
//    newDialog.type = QBChatDialogTypePrivate;
//    newDialog.occupantIDs = @[ opponentID];  // occupant ID
//    [self updateDialogsLastMessageFields:newDialog forLastMessage:message];
//    
//    return newDialog;
//}

- (BOOL)userIsJoinedRoomWithJID:(NSString *)roomJID
{
    QBChatRoom *room = self.allChatRoomsAsDictionary[roomJID];
    if (room == nil) {
        return NO;
    }
    return YES;
}

- (void)searchForOpponentWithIDAndFetchIfNeeded:(NSUInteger)opponentID
{
    // find user:
    NSString *kOpponentID = [NSString stringWithFormat:@"%lu",(unsigned long)opponentID];
    
    QBUUser *opponent = [QMContactList shared].friendsAsDictionary[kOpponentID];
    if (opponent == nil) {
        opponent = [QMContactList shared].allUsersAsDictionary[kOpponentID];
        if (opponent == nil) {
            [[QMContactList shared] retrieveUserWithID:opponentID completion:^(QBUUser *user, NSError *error) {
                // update dialogs names:
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatDialogsDidLoadedNotification object:nil];
            }];
        }
    }
}

- (NSMutableDictionary *)dialogsAsDictionaryFromDialogsArray:(NSArray *)array
{
    NSMutableDictionary *dictionaryOfDialogs = [NSMutableDictionary new];
    for (QBChatDialog *dialog in array) {
        
        if (dialog.type != QBChatDialogTypePrivate) {
            
            // save group dialogs by roomJID:
            dictionaryOfDialogs[dialog.roomJID] = dialog;
            continue;
        }
        
        for (NSString *ID in dialog.occupantIDs) {
            NSString *meID = [NSString stringWithFormat:@"%lu", (unsigned long)[QMContactList shared].me.ID];
            
            // if my ID
            if (![meID isEqualToString:ID]) {
                dictionaryOfDialogs[ID] = dialog;
                break;
            }
        }
    }
    return dictionaryOfDialogs;
}

- (NSArray *)stringToArray:(NSString *)string
{
    NSString *newString = [string copy];
    NSMutableArray *array = [NSMutableArray new];
    
    while ([newString rangeOfString:@","].location < 1000000) {
        NSRange range = [newString rangeOfString:@","];
        // ID:
        NSString *ID = [newString substringToIndex:range.location];
        [array addObject:ID];
        
        // оставшаяся строка:
        newString = [newString substringFromIndex:range.location+1];
    }
    [array addObject:newString];
    
    return [array copy];
}


#pragma mark - QBActionStatusDelegate

- (void)completedWithResult:(Result *)result
{
    if ([result isKindOfClass:[QBChatHistoryMessageResult class]]) {
        
        if (result.success) {
            if (_chatDialogHistoryBlock) {
                NSMutableArray *messagesMArray = ((QBChatHistoryMessageResult *)result).messages;
                if (messagesMArray) {
                    _chatDialogHistoryBlock(messagesMArray, nil);
                    _chatDialogHistoryBlock = nil;
                } else {
                    messagesMArray = [NSMutableArray new];
                    _chatDialogHistoryBlock(messagesMArray, nil);
                    _chatDialogHistoryBlock = nil;
                }
            }
        }
        
	}
}

- (void)completedWithResult:(Result *)result context:(void *)contextInfo
{
    ((__bridge void (^)(Result * result))(contextInfo))(result);
    Block_release(contextInfo);
}

@end
