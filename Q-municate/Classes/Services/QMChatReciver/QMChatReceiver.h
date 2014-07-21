//
//  QMChatReceiver.h
//  Qmunicate
//
//  Created by Andrey on 07.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^QMChatDidLogin)(BOOL success);
typedef void(^QMChatDidFailLogin)(NSInteger errorCode);
typedef void(^QMChatMessageBlock)(QBChatMessage *message);
typedef void(^QMChatDidReceivePresenceOfUser)(NSUInteger userID, NSString *type);
typedef void(^QMChatDidReceiveListOfRooms)(NSArray *rooms);
typedef void(^QMChatRoomDidReceiveMessage)(QBChatMessage *message, NSString *roomJID);
typedef void(^QMChatRoomDidReceiveInformation)(NSDictionary *information, NSString *roomJID, NSString *roomName);
typedef void(^QMChatRoomDidCreate)(NSString *roomName);
typedef void(^QMChatRoomDidEnter)(QBChatRoom *room);
typedef void(^QMChatRoomDidNotEnter)(NSString *roomName, NSError *error);
typedef void(^QMChatRoomDidLeave)(NSString *roomName);
typedef void(^QMChatRoomDidDestroy)(NSString *roomName);
typedef void(^QMChatRoomDidChangeOnlineUsers)(NSArray *onlineUsers, NSString *roomName);
typedef void(^QMChatRoomDidReceiveListOfUsers)(NSArray *users, NSString *roomName);
typedef void(^QMChatRoomDidReceiveListOfOnlineUsers)(NSArray *users, NSString *roomName);
typedef void(^QMChatDidReceiveCallRequest)(NSUInteger userID, NSString *sessionID, QBVideoChatConferenceType conferenceType);
typedef void(^QMChatDidReceiveCallRequestCustomParams)(NSUInteger userID, NSString *sessionID, QBVideoChatConferenceType conferenceType, NSDictionary *customParameters);
typedef void(^QMChatCallUserDidNotAnswer)(NSUInteger userID);
typedef void(^QMChatCallDidAcceptByUser)(NSUInteger userID);
typedef void(^QMChatCallDidAcceptByUserCustomParams)(NSUInteger userID, NSDictionary *customParameters);
typedef void(^QMChatCallDidRejectByUser)(NSUInteger userID);
typedef void(^QMChatCallDidStopByUser)(NSUInteger userID, NSString *status);
typedef void(^QMChatCallDidStopByUserCustomParams)(NSUInteger userID, NSString *status, NSDictionary *customParameters);
typedef void(^QMChathatCallDidStartWithUser)(NSUInteger userID, NSString *sessionID);
typedef void(^QMDidStartUseTURNForVideoChat)(void);
typedef void(^QMChatDidReceiveContactAddRequest)(NSUInteger userID);
typedef void(^QMChatContactListDidChange)(QBContactList * contactList);
typedef void(^QMChatContactListWillChange)(void);
typedef void(^QMChathatDidReceiveContactItemActivity)(NSUInteger userID, BOOL isOnline, NSString *status);

@interface QMChatReceiver : NSObject <QBChatDelegate>

+ (instancetype)instance;

- (void)unsubsribeForTarget:(id)target;
/**
 ChatService
 */
- (void)chatDidLoginWithTarget:(id)target block:(QMChatDidLogin)block;
- (void)chatDidNotLoginWithTarget:(id)target block:(QMChatDidLogin)block;
- (void)chatDidFailWithTarget:(id)target block:(QMChatDidFailLogin)block;
- (void)chatDidReceiveMessageWithTarget:(id)target block:(QMChatMessageBlock)block;
- (void)chatAfterDidReceiveMessageWithTarget:(id)target block:(QMChatMessageBlock)block;
- (void)chatDidNotSendMessageWithTarget:(id)target block:(QMChatMessageBlock)block;
- (void)chatDidReceivePresenceOfUserWithTarget:(id)target block:(QMChatDidReceivePresenceOfUser)block;
/**
 ContactList
 */
- (void)chatDidReceiveContactAddRequestWithTarget:(id)target block:(QMChatDidReceiveContactAddRequest)block;
- (void)chatContactListDidChangeWithTarget:(id)target block:(QMChatContactListDidChange)block;
- (void)chatContactListWilChangeWithTarget:(id)target block:(QMChatContactListWillChange)block;
- (void)chatDidReceiveContactItemActivityWithTarget:(id)target block:(QMChathatDidReceiveContactItemActivity)block;
/**
 ChatRoom
 */
- (void)chatDidReceiveListOfRoomsWithTarget:(id)target block:(QMChatDidReceiveListOfRooms)block;
- (void)chatRoomDidReceiveMessageWithTarget:(id)target block:(QMChatRoomDidReceiveMessage)block;
- (void)chatRoomDidReceiveInformationWithTarget:(id)target block:(QMChatRoomDidReceiveInformation)block;
- (void)chatRoomDidCreateWithTarget:(id)target block:(QMChatRoomDidCreate)block;
- (void)chatRoomDidEnterWithTarget:(id)target block:(QMChatRoomDidEnter)block;
- (void)chatRoomDidNotEnterWithTarget:(id)target block:(QMChatRoomDidNotEnter)block;
- (void)chatRoomDidLeaveWithTarget:(id)target block:(QMChatRoomDidLeave)block;
- (void)chatRoomDidDestroyWithTarget:(id)target block:(QMChatRoomDidDestroy)block;
- (void)chatRoomDidChangeOnlineUsersWithTarget:(id)target block:(QMChatRoomDidChangeOnlineUsers)block;
- (void)chatRoomDidReceiveListOfUsersWithTarget:(id)target block:(QMChatRoomDidReceiveListOfUsers)block;
- (void)chatRoomDidReceiveListOfOnlineUsersWithTarget:(id)target block:(QMChatRoomDidReceiveListOfOnlineUsers)block;
/**
 VideoChat
 */


#pragma mark - AUDIO/VIDEO CALLS
#pragma mark -

- (void)chatDidReceiveCallRequestCustomParametesrWithTarget:(id)target block:(QMChatDidReceiveCallRequestCustomParams)block;
- (void)chatAfrerDidReceiveCallRequestCustomParametesrWithTarget:(id)target block:(QMChatDidReceiveCallRequestCustomParams)block;

- (void)chatCallDidAcceptCustomParametersWithTarget:(id)target block:(QMChatCallDidAcceptByUserCustomParams)block;

- (void)chatCallDidRejectByUserWithTarget:(id)target block:(QMChatCallDidRejectByUser)block;
- (void)chatAfterCallDidRejectByUserWithTarget:(id)target block:(QMChatCallDidRejectByUser)block;

- (void)chatCallDidStopCustomParametersWithTarget:(id)target block:(QMChatCallDidStopByUserCustomParams)block;
- (void)chatAfterCallDidStopWithTarget:(id)target block:(QMChatCallDidStopByUser)block;

- (void)chatCallDidStartWithTarget:(id)target block:(QMChathatCallDidStartWithUser)block;


#pragma mark - Unsued

//- (void)chatDidReceiveCallRequestWithTarget:(id)target block:(QMChatDidReceiveCallRequest)block;
//- (void)chatCallUserDidNotAnswerWithTarget:(id)target block:(QMChatCallUserDidNotAnswer)block;
//- (void)chatCallDidAcceptWithTarget:(id)target block:(QMChatCallDidAcceptByUser)block;
//- (void)chatCallDidStopWithTarget:(id)target block:(QMChatCallDidStopByUser)block;
//- (void)didStartUseTURNForVideoChatWithTarget:(id)target block:(QMDidStartUseTURNForVideoChat)block;

@end

