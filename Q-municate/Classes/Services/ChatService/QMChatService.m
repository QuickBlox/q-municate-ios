//
//  QMChatService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 17/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatService.h"
#import "QMContactList.h"


@interface QMChatService () <QBChatDelegate, QBActionStatusDelegate>

@property (copy, nonatomic) QBChatResultBlock chatBlock;
@property (copy, nonatomic) QBChatRoomResultBlock chatRoomResultBlock;
@property (copy, nonatomic) QBChatDialogResultBlock chatDialogResultBlock;
@property (copy, nonatomic) QBChatDialogHistoryBlock chatDialogHistoryBlock;

@property (strong, nonatomic) NSTimer *presenceTimer;

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
	[self.presenceTimer invalidate];
    self.presenceTimer = nil;
}


#pragma mark - Audio/Video Calls

- (void)callUser:(NSUInteger)userID withVideo:(BOOL)videoEnabled
{
    if (videoEnabled) {
        [self.activeStream callUser:userID conferenceType:QBVideoChatConferenceTypeAudioAndVideo];
        return;
    }
    [self.activeStream callUser:userID conferenceType:QBVideoChatConferenceTypeAudio];
}

- (void)acceptCallFromUser:(NSUInteger)userID withVideo:(BOOL)videoEnabled customParams:(NSDictionary *)customParameters
{
    self.activeStream.viewToRenderOpponentVideoStream.remotePlatform = self.customParams[qbvideochat_platform];
    self.activeStream.viewToRenderOpponentVideoStream.remoteVideoOrientation = [QBChatUtils interfaceOrientationFromString:self.customParams[qbvideochat_device_orientation]];
    if (videoEnabled) {
        [self.activeStream acceptCallWithOpponentID:userID conferenceType:QBVideoChatConferenceTypeAudioAndVideo customParameters:customParameters];
        return;
    }
    [self.activeStream acceptCallWithOpponentID:userID conferenceType:QBVideoChatConferenceTypeAudio];
}

- (void)rejectCallFromUser:(NSUInteger)userID
{
    [self.activeStream rejectCallWithOpponentID:userID];
}

- (void)cancelCall
{
    [self.activeStream finishCall];
}

- (void)finishCall
{
    [self cancelCall];
}


#pragma mark - Active Stream Options

- (void)initActiveStream
{
    if (currentSessionID == nil) {
        self.activeStream = [[QBChat instance] createAndRegisterWebRTCVideoChatInstanceWithSessionID:nil];
        return;
    }
    self.activeStream = [[QBChat instance] createAndRegisterWebRTCVideoChatInstanceWithSessionID:currentSessionID];
}

- (void)initActiveStreamWithOpponentView:(QBVideoView *)opponentView ownView:(UIView *)ownView
{
    // Active stream initialize:
    if (currentSessionID == nil)
    {
        self.activeStream = [[QBChat instance] createWebRTCVideoChatInstance];
    } else {
        self.activeStream = [[QBChat instance] createAndRegisterWebRTCVideoChatInstanceWithSessionID:currentSessionID];
    }
    self.activeStream.viewToRenderOpponentVideoStream = opponentView;  ///   opponent' view
//    self.activeStream.viewToRenderOwnVideoStream = ownView;        ///   my view
}

- (void)releaseActiveStream
{
    //Destroy active stream:
    [[QBChat instance] unregisterWebRTCVideoChatInstance:self.activeStream];
    self.activeStream = nil;
}


#pragma mark - QBChatDelegate - Login to Chat

//Chat Login
- (void)chatDidLogin
{
    if (self.presenceTimer == nil) {
        self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
    }
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
    currentSessionID = _sessionID;
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
    currentSessionID = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasRejectedNotification object:nil];
}

// user doesn't answer:
-(void) chatCallUserDidNotAnswer:(NSUInteger)userID
{
    currentSessionID = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:@{@"reason":kStopVideoChatCallStatus_OpponentDidNotAnswer}];
}

// call finished of canceled:
- (void)chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status
{
    currentSessionID = nil;
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
               
    [[NSNotificationCenter defaultCenter] postNotificationName:kCallWasStoppedNotification object:nil userInfo:@{@"reason":stopCallReason}];
}


#pragma mark - Chat

// ******************* GETTING DIALOGS ***************************
- (void)fetchAllDialogs
{
    [[QBChat instance] dialogsWithDelegate:self];
}

- (void)chatDidNotSendMessage:(QBChatMessage *)message
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kChatDidNotSendMessage object:nil userInfo:@{@"message" : message}];
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message
{
    // get dialog entity with current user:
    NSString *kRecipientID = [@(message.senderID) stringValue];
    QBChatDialog *currentDialog = self.allDialogsAsDictionary[kRecipientID];
    if (currentDialog != nil) {
        
        // get chat history with current dialog id:
        NSMutableArray *currentHistory = self.allConversations[currentDialog.ID];
        if (currentHistory != nil) {
            [currentHistory addObject:message];
        } else {
            currentHistory = [@[message] mutableCopy];
            self.allConversations[currentDialog.ID] = currentHistory;
        }
    }
    
	[[NSNotificationCenter defaultCenter] postNotificationName:kChatDidReceiveMessage object:nil];
}

- (void)chatDidFailWithError:(NSInteger)code
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kChatDidFailWithError object:nil userInfo:@{@"errorCode" : [NSNumber numberWithInteger:code]}];
}

- (void)sendMessage:(QBChatMessage *)message
{
	[[QBChat instance] sendMessage:message]; 
    
    // get dialog entity with current user:
    NSString *kRecipientID = [@(message.recipientID) stringValue];
    QBChatDialog *currentDialog = self.allDialogsAsDictionary[kRecipientID];
    if (currentDialog != nil) {
        
        // get chat history with current dialog id:
        NSMutableArray *currentHistory = self.allConversations[currentDialog.ID];
        if (currentHistory != nil) {
            [currentHistory addObject:message];
        } else {
            currentHistory = [@[message] mutableCopy];
            self.allConversations[currentDialog.ID] = currentHistory;
        }
    }
}

- (void)saveMessageToLocalHistory:(QBChatMessage *)chatMessage
{
	//
}

#pragma mark - Group Chat

- (void)createRoomWithName:(NSString *)groupChatNameString withCompletion:(QBChatRoomResultBlock)block
{
	_chatRoomResultBlock = block;
	[[QBChat instance] createOrJoinRoomWithName:groupChatNameString membersOnly:YES persistent:NO];
}

- (void)createNewDialog:(QBChatDialog *)chatDialog withCompletion:(QBChatDialogResultBlock)block
{
	_chatDialogResultBlock = block;
	[[QBChat instance] createDialog:chatDialog delegate:self];
}

- (void)getMessageHistoryWithDialogID:(NSString *)dialogIDString withCompletion:(QBChatDialogHistoryBlock)block
{
	_chatDialogHistoryBlock = block;
	[[QBChat instance] messagesWithDialogID:dialogIDString delegate:self];
}

- (void)postMessage:(QBChatMessage *)chatMessage withRoom:(QBChatRoom *)chatRoom withCompletion:(QBChatDialogResultBlock)block
{
	_chatDialogResultBlock = block;
	[[QBChat instance] sendMessage:chatMessage.text toRoom:chatRoom];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName
{

}

- (void)chatRoomDidReceiveInformation:(NSDictionary *)information room:(NSString *)roomName
{

}

- (void)chatRoomDidCreate:(NSString *)roomName
{

}

- (void)chatRoomDidEnter:(QBChatRoom *)room
{
	//1
	if (_chatRoomResultBlock) {
		[QMChatService shared].chatRoom = room;
		_chatRoomResultBlock(room, nil);
		_chatRoomResultBlock = nil;
	}
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
	//3
}

- (void)chatRoomDidDestroy:(NSString *)roomName
{

}

- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName
{
	//2
}

- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName
{

}

- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName
{

}


#pragma mark - Chat Utils

- (QBChatDialog *)chatDialogForFriendWithID:(NSUInteger)ID
{
    NSString *kUserID = [@(ID) stringValue];
    QBChatDialog *dialog= self.allDialogsAsDictionary[kUserID];
    if (dialog != nil) {
        return dialog;
        
    }
    // create fake dialog:
    dialog = [[QBChatDialog alloc] init];
    dialog.type = QBChatDialogTypePrivate;
    dialog.occupantIDs = @[[@(ID) stringValue]];
    dialog.ID = kUserID;
    
    self.allDialogsAsDictionary[kUserID] = dialog;
    
    return dialog;
}


#pragma mark - QBActionStatusDelegate

- (void)completedWithResult:(Result *)result
{
	if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
		if (_chatDialogResultBlock) {
			QBChatDialog *chatDialog = ((QBChatDialogResult *)result).dialog;
			if (chatDialog) {
				_chatDialogResultBlock(chatDialog, nil);
				_chatDialogResultBlock = nil;
			}
		}
	} else if (result.success && [result isKindOfClass:[QBChatHistoryMessageResult class]]) {
		if (_chatDialogHistoryBlock) {
			NSMutableArray *messagesMArray = ((QBChatHistoryMessageResult *)result).messages;
			if (messagesMArray) {
				_chatDialogHistoryBlock(messagesMArray, nil);
				_chatDialogHistoryBlock = nil;
			}
		}
	} else if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *dialogsResult = (QBDialogsPagedResult *)result;
        NSArray *dialogs = dialogsResult.dialogs;
        self.allDialogsAsDictionary = [self arrayToDictionary:dialogs];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatDialogsLoaded" object:nil];
        
    }
}

- (NSMutableDictionary *)arrayToDictionary:(NSArray *)array
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

@end
