//
//  QMCore.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCore.h"
#import <Reachability.h>
#import "QMProfile.h"
#import "QMFacebook.h"
#import "QMNotifications.h"
#import <QMChatService+AttachmentService.h>
#import <DigitsKit/DigitsKit.h>

NSString *const kQMLastActivityDateKey = @"last_activity_date";

@interface QMCore ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation QMCore

+ (instancetype)instance {
    
    static QMCore *core = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        core = [[self alloc] init];
    });
    
    return core;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Contact list service init
        [QMContactListCache setupDBWithStoreNamed:kContactListCacheNameKey];
        _contactListService = [[QMContactListService alloc] initWithServiceManager:self cacheDataSource:self];
        [_contactListService addDelegate:self];
        
        // Profile init
        _currentProfile = [QMProfile currentProfile];
        
        // Users cache init
        [self.usersService loadFromCache];
        
        // Reachability init
//        _internetConnection = [Reachability reachabilityForInternetConnection];
        
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

#pragma mark - Auth methods

- (BFTask *)logout {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    @weakify(self);
    [super logoutWithCompletion:^{
        @strongify(self);
        
        if (self.currentProfile.accountType == QMAccountTypeFacebook) {
            
            [QMFacebook logout];
        } else if (self.currentProfile.accountType == QMAccountTypeDigits) {
            
            [[Digits sharedInstance] logOut];
        }
        
        [self.currentProfile clearProfile];
        
        [source setResult:nil];
    }];
    
    return source.task;
}

#pragma mark - Chat Connection

- (BFTask *)disconnectFromChat {
    @weakify(self);
    return [[self.chatService disconnect] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        @strongify(self);
        if (!task.isFaulted) {
            
            self.lastActivityDate = [NSDate date];
        }
        
        return nil;
    }];
}

- (BFTask *)disconnectFromChatIfNeeded {
#warning TODO: implement disconnect if needed during active call
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground /*&& !self.avCallManager.hasActiveCall*/ && [[QBChat instance] isConnected]) {
        return [self disconnectFromChat];
    }
    
    return nil;
}

#pragma mark - Notifications

- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog {
    
    @weakify(self);
    return [[self.chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:kDialogsUpdateNotificationMessage] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (!task.isFaulted) {
            @strongify(self);
            return [self.chatService deleteDialogWithID:chatDialog.ID];
        }
        
        return nil;
    }];
}

#pragma mark - Users

- (NSArray *)allContacts {
    
    NSArray *ids = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    NSArray *allFriends = [self.usersService.usersMemoryStorage usersWithIDs:ids];
    
    return allFriends;
}

- (NSArray *)allContactsSortedByFullName {
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"fullName"
                                ascending:YES
                                selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [[self allContacts] sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

- (NSArray *)friends {
    
    NSMutableArray *friends = [NSMutableArray array];
    NSArray *allContactsIDs = self.contactListService.contactListMemoryStorage.userIDsFromContactList;
    
    for (NSNumber *userID in allContactsIDs) {
        
        QBContactListItem *item = [self.contactListService.contactListMemoryStorage contactListItemWithUserID:userID.integerValue];
        if (item.subscriptionState == QBPresenceSubscriptionStateBoth) {
            
            QBUUser *user = [self.usersService.usersMemoryStorage userWithID:userID.integerValue];
            if (user) {
                
                [friends addObject:user];
            }
        }
    }
    
    return friends.copy;
}

- (BOOL)isFriendWithUserID:(NSUInteger)userID {
    
    NSArray *ids = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    return [ids containsObject:@(userID)];
}

- (BOOL)userIDIsInPendingList:(NSUInteger)userID {
    
    QBContactListItem *contactlistItem = [self.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return contactlistItem.subscriptionState != QBPresenceSubscriptionStateBoth ? YES : NO;
}

- (NSArray *)idsOfUsers:(NSArray *)users {
    
    NSMutableArray *ids = [NSMutableArray array];
    
    for (QBUUser *user in users) {
        
        [ids addObject:@(user.ID)];
    }
    
    return ids.copy;
}

#pragma mark - Last activity date

- (void)setLastActivityDate:(NSDate *)lastActivityDate
{
    [self.defaults setObject:lastActivityDate forKey:kQMLastActivityDateKey];
    [self.defaults synchronize];
}

- (NSDate *)lastActivityDate
{
    return [self.defaults objectForKey:kQMLastActivityDateKey];
}

#pragma mark - Contacts management

- (BFTask *)addUserToContactList:(QBUUser *)user {
    
    @weakify(self);
    return [[[self.contactListService addUserToContactListRequest:user] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        @strongify(self);
        return [self.chatService createPrivateChatDialogWithOpponent:user];
    }] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        @strongify(self);
        QBChatMessage *chatMessage = [QMNotifications contactRequestNotificationForUser:user withChatDialog:task.result];
        [self.chatService sendMessage:chatMessage
                                 type:chatMessage.messageType
                             toDialog:task.result
                        saveToHistory:YES
                        saveToStorage:YES
                           completion:nil];
        
        NSString *notificationMessage = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_OPPONENT", @"{FullName}"), self.currentProfile.userData.fullName];
        
        return [QMNotifications sendPushNotificationToUser:user withText:notificationMessage];
    }];
}

- (BFTask *)confirmAddContactRequest:(QBUUser *)user {
    
    @weakify(self);
    return [[self.contactListService acceptContactRequest:user.ID] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        @strongify(self);
        return [self.chatService sendMessageAboutAcceptingContactRequest:YES toOpponentID:user.ID];
    }];
}

- (BFTask *)rejectAddContactRequest:(QBUUser *)user {
    
    @weakify(self);
    return [[self.contactListService rejectContactRequest:user.ID] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        @strongify(self);
        return [self.chatService sendMessageAboutAcceptingContactRequest:NO toOpponentID:user.ID];
    }];
}

- (BOOL)isUserOnline:(NSUInteger)userID {
    
    QBContactListItem *item = [self.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return item.isOnline;
}

- (NSString *)fullNameForUserID:(NSUInteger)userID {
    
    QBUUser *user = [self.usersService.usersMemoryStorage userWithID:userID];
    
    NSString *fullName = user.fullName != nil ? user.fullName : [NSString stringWithFormat:@"%tu", userID];
    
    return fullName;
}

#pragma mark QMContactListServiceCacheDelegate delegate

- (void)cachedContactListItems:(QMCacheCollection)block {
    
    [[QMContactListCache instance] contactListItems:block];
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    [[QMContactListCache instance] insertOrUpdateContactListItemsWithContactList:contactList completion:nil];
    
    // load users if needed
    [[QMCore instance].usersService getUsersWithIDs:self.contactListService.contactListMemoryStorage.userIDsFromContactList];
}

@end
