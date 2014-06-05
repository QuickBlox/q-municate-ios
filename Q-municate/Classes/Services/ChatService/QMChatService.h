//
//  QMChatService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 17/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMChatUploadingMessage.h"

@interface QMChatService : NSObject


@property (strong, nonatomic) NSMutableDictionary *allConversations;
@property (strong, nonatomic) NSMutableDictionary *allDialogsAsDictionary;
@property (strong, nonatomic) NSMutableDictionary *allChatRoomsAsDictionary;

@property (strong, nonatomic) QBWebRTCVideoChat *activeStream;

@property (strong, nonatomic) NSString *currentSessionID;
@property (nonatomic, strong) NSDictionary *customParams;
@property (nonatomic, strong) QBChatRoom *chatRoom;

@property (nonatomic, strong) QBChatDialog *lastCreatedDialog;
@property (nonatomic, readonly, getter = isLoggedIn) BOOL loggedIn;

+ (instancetype)shared;

// Log In & Log Out
- (void)loginWithUser:(QBUUser *)user completion:(QBChatResultBlock)block;
- (void)logOut;

#pragma mark - STATUS
- (void)sendPresence;


#pragma mark - Contact List (ROASTER)

- (void)sendFriendsRequestToUserWithID:(NSUInteger)userID;
- (void)confirmFriendsRequestFromUserWithID:(NSUInteger)userID;
- (void)rejectFriendsRequestFromUserWithID:(NSUInteger)userID;
- (void)removeContactFromFriendsWithID:(NSUInteger)userID;


#pragma mark - Chat

// ****************************** Dialogs **************************************
- (void)fetchAllDialogsWithBlock:(void(^)(NSArray *dialogs, NSError *error))block;
- (void)createNewDialog:(QBChatDialog *)chatDialog withCompletion:(QBChatDialogResultBlock)block;

- (void)sendMessage:(QBChatMessage *)message;
- (void)sendMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)chatRoom;
- (void)sendInviteMessageToUsers:(NSArray *)users withChatDialog:(QBChatDialog *)chatDialog;
- (void)sendContentMessage:(QMChatUploadingMessage *)message withBlob:(QBCBlob *)blob;
- (void)joinRoomWithRoomJID:(NSString *)roomJID;
- (void)joinRoomsForDialogs:(NSArray *)chatDialogs;

- (void)getMessageHistoryWithDialogID:(NSString *)dialogIDString withCompletion:(void(^)(NSArray *messages, BOOL success, NSError *error))block;


#pragma mark - Chat Utils

- (QBChatDialog *)chatDialogForFriendWithID:(NSUInteger)ID;
- (QBChatMessage *)chatMessageFromContentMessage:(QMChatUploadingMessage *)uploadingMessage;


#pragma mark - Audio/Video Calls

- (void)initActiveStream;                                                                           // for audio calls
- (void)initActiveStreamWithOpponentView:(UIView *)opponentView ownView:(UIView *)ownView;          // for video calls
- (void)releaseActiveStream;

- (void)callUser:(NSUInteger)userID withVideo:(BOOL)videoEnabled;

- (void)acceptCallFromUser:(NSUInteger)userID withVideo:(BOOL)videoEnabled customParams:(NSDictionary *)customParameters;
- (void)rejectCallFromUser:(NSUInteger)userID;

- (void)cancelCall;
- (void)finishCall;

@end
