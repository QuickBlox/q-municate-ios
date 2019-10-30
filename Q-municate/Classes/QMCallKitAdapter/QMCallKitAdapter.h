//
//  QMCallKitAdapter.h
//  Q-municate
//
//  Created by Injoit on 11/30/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QMCallKitAdapterUsersStorageProtocol <NSObject>

- (void)userWithID:(NSUInteger)userID completion:(void(^)(QBUUser *user))completion;

@end

/**
 QMCallKitAdapter class interface.
 Used as adapter of Apple CallKit.
 */
@interface QMCallKitAdapter : NSObject

/**
 Determines whether call kit is available in the current circumstances.
 */
@property (nonatomic, class, readonly, getter=isCallKitAvailable) BOOL callKitAvailable;

/**
 Action on microphone mute using CallKit UI.
 */
@property (copy, nonatomic) dispatch_block_t onMicrophoneMuteAction;

/**
 Action that will be executed if call was ended by call kit.
 */
@property (copy, nonatomic) dispatch_block_t onCallEndedByCallKitAction;

/**
 Init with users storage.

 @param usersStorage class that corresponds to QMCallKitAdapterUsersStorageProtocol protocol
 @return class instance
 
 @see QMCallKitAdapterUsersStorageProtocol
 */
- (instancetype)initWithUsersStorage:(id <QMCallKitAdapterUsersStorageProtocol>)usersStorage;

/**
 Start Call with user ID.
 
 @param userID user ID to perform call with
 @param session session instance
 @param uuid call uuid
 
 @discussion Use this to perform outgoing call with specific user ids.
 
 @see QBRTCSession
 */
- (void)startCallWithUserID:(NSNumber *)userID session:(QBRTCSession *)session uuid:(NSUUID *)uuid;

/**
 End call with uuid.
 
 @param uuid uuid of call
 @param completion completion block
 */
- (void)endCallWithUUID:(NSUUID *)uuid completion:(nullable dispatch_block_t)completion;

/**
 Report incoming call with user IDs.
 
 @param userIDs user IDs of incoming call
 @param session session instance
 @param uuid call uuid
 @param onAcceptAction on call accept action
 @param completion completion block
 
 @discussion Use this to show incoming call screen.
 
 @see QBRTCSession
 */
- (void)reportIncomingCallWithUserID:(NSNumber *)userID session:(QBRTCSession *)session uuid:(NSUUID *)uuid onAcceptAction:(nullable dispatch_block_t)onAcceptAction completion:(nullable void (^)(BOOL))completion;

/**
 Update outgoing call with connecting date
 
 @param uuid call uuid
 @param date connecting started date
 */
- (void)updateCallWithUUID:(NSUUID *)uuid connectingAtDate:(NSDate *)date;

/**
 Update outgoing call with connected date.
 
 @param uuid call uuid
 @param date connected date
 */
- (void)updateCallWithUUID:(NSUUID *)uuid connectedAtDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
