//
//  QMServicesFacade.h
//  Qmunicate
//
//  Created by Andrey on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMAuthService;
@class QMSettingsManager;
@class QMFacebookService;
@class QMUsersService;
@class QMChatService;
@class QMChatDialogsService;
@class QMAVCallService;
@class QMMessagesService;
@class QMChatReceiver;

@interface QMApi : NSObject

@property (strong, nonatomic) QMAuthService *authService;
@property (strong, nonatomic) QMSettingsManager *settingsManager;
@property (strong, nonatomic) QMFacebookService *facebookService;
@property (strong, nonatomic) QMUsersService *usersService;
@property (strong, nonatomic) QMChatService *chatService;
@property (strong, nonatomic) QMAVCallService *avCallService;
@property (strong, nonatomic) QMChatDialogsService *chatDialogsService;
@property (strong, nonatomic) QMMessagesService *messagesService;
@property (strong, nonatomic) QMChatReceiver *responceService;

@property (strong, atomic) QBUUser *currentUser;

+ (instancetype)instance;
- (BOOL)checkResult:(Result *)result;

@end

@interface QMApi (Auth)

/**
 User LogIn with facebook
 
 Type of Result - QBUUserLogInResult
 @return completion stastus
 */
- (void)loginWithFacebook:(void(^)(BOOL success))completion;

/**
 */
- (void)loginWithUser:(QBUUser *)user completion:(QBUUserLogInResultBlock)complition;

/**
 */
- (void)signUpAndLoginWithUser:(QBUUser *)user userAvatar:(UIImage *)userAvatar completion:(QBUUserResultBlock)completion;

/**
 */
- (void)updateUser:(QBUUser *)user completion:(void(^)(BOOL success))completion;
/**
 */
- (void)changePasswordForCurrentUser:(QBUUser *)currentUser completion:(void(^)(BOOL success))completion;

@end

@interface QMApi (Messages)

@end

@interface QMApi (ChatDialogs)

/**
 Get all dialogs for current user
 */
- (void)fetchAllDialogs:(void(^)(void))completion;

/**
 Create group chat dialog
 
 @param name - Group chat name.
 @param ocupants - Array of QBUUser in chat.
 @result QBChatDialogResult
 */
- (void)createGroupChatDialogWithName:(NSString *)name ocupants:(NSArray *)ocupants completion:(QBChatDialogResultBlock)completion;

/**
 Create private chat dialog
 
 @param opponent - oponent.
 @result QBChatDialogResult
 */
- (void)createPrivateChatDialogWithOpponent:(QBUUser *)opponent completion:(QBChatDialogResultBlock)completion;

/**
 Leave user from chat dialog
 
 @param userID - user identifier
 @param chatDialog - chat dialog
 @result QBChatDialogResult
 */
- (void)leaveWithUserId:(NSUInteger)userID fromChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

/**
 Join users to chat dialog
 
 @param occupantsIDs - Array of QBUUser in chat.
 @result QBChatDialogResult
 */
- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

/**
 Join new users to chat
 
 @param dialogName
 @result QBChatDialogResult
 */
- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completion;

@end


@interface QMApi (Users)

//Local storage

@property (strong, nonatomic, readonly) NSArray *friends;

- (void)addUser:(QBUUser *)user;
- (void)addUsers:(NSArray *)users;
- (QBUUser *)userWithID:(NSUInteger)userID;
- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID;

//Quickblox Api

- (BOOL)addUserInContactListWithUserID:(NSUInteger)userID;
- (void)retrieveFriendsIfNeeded:(void(^)(BOOL updated))completion;
- (void)retrieveUsersForChatDialog:(QBChatDialog *)chatDialog completion:(void(^)(BOOL updated))completion;
- (void)retrieveUsersWithIDs:(NSArray *)idsToFetch completion:(void(^)(BOOL updated))completion;

@end

@interface QMApi (Facebook)

- (NSURL *)fbUserImageURLWithUserID:(NSString *)userID;
- (void)fbFriends:(void(^)(NSArray *fbFriends))completion;

@end