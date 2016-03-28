//
//  QMContactManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactManager.h"
#import "QMCore.h"
#import <QMChatService+AttachmentService.h>

@interface QMContactManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;

@end

@implementation QMContactManager

@dynamic serviceManager;

- (void)serviceWillStart {
    
}

#pragma mark - Contacts management

- (BFTask *)addUserToContactList:(QBUUser *)user {
    
    @weakify(self);
    return [[[self.serviceManager.contactListService addUserToContactListRequest:user] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        @strongify(self);
        return [self.serviceManager.chatService createPrivateChatDialogWithOpponent:user];
    }] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        @strongify(self);
        QBChatMessage *chatMessage = [self.serviceManager.notificationManager contactRequestNotificationForUser:user withChatDialog:task.result];
        [self.serviceManager.chatService sendMessage:chatMessage
                                                 type:chatMessage.messageType
                                             toDialog:task.result
                                        saveToHistory:YES
                                        saveToStorage:YES
                                           completion:nil];
        
        NSString *notificationMessage = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_FRIEND_REQUEST_DID_SEND_FOR_OPPONENT", @"{FullName}"), self.serviceManager.currentProfile.userData.fullName];
        
        return [self.serviceManager.notificationManager sendPushNotificationToUser:user withText:notificationMessage];
    }];
}

- (BFTask *)confirmAddContactRequest:(QBUUser *)user {
    
    @weakify(self);
    return [[self.serviceManager.contactListService acceptContactRequest:user.ID] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        @strongify(self);
        return [self.serviceManager.chatService sendMessageAboutAcceptingContactRequest:YES toOpponentID:user.ID];
    }];
}

- (BFTask *)rejectAddContactRequest:(QBUUser *)user {
    
    @weakify(self);
    return [[self.serviceManager.contactListService rejectContactRequest:user.ID] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        @strongify(self);
        return [self.serviceManager.chatService sendMessageAboutAcceptingContactRequest:NO toOpponentID:user.ID];
    }];
}

- (BFTask *)removeUserFromContactList:(QBUUser *)user {
    
    @weakify(self);
    return [[self.serviceManager.contactListService removeUserFromContactListWithUserID:user.ID] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        @strongify(self);
        QBChatDialog *chatDialog = [self.serviceManager.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
        QBChatMessage *notificationMessage = [self.serviceManager.notificationManager removeContactNotificationForUser:user];
        
        [self.serviceManager.chatService sendMessage:notificationMessage
                                                type:notificationMessage.messageType
                                            toDialog:chatDialog
                                       saveToHistory:NO
                                       saveToStorage:NO
                                          completion:nil];
        
        return [self.serviceManager.chatService deleteDialogWithID:chatDialog.ID];
    }];

}

#pragma mark - Users

- (NSString *)fullNameForUserID:(NSUInteger)userID {
    
    QBUUser *user = [self.serviceManager.usersService.usersMemoryStorage userWithID:userID];
    
    NSString *fullName = user.fullName != nil ? user.fullName : [NSString stringWithFormat:@"%tu", userID];
    
    return fullName;
}

- (NSArray *)allContacts {
    
    NSArray *ids = [self.serviceManager.contactListService.contactListMemoryStorage userIDsFromContactList];
    NSArray *allContacts = [self.serviceManager.usersService.usersMemoryStorage usersWithIDs:ids];
    
    return allContacts;
}

- (NSArray *)allContactsSortedByFullName {
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:kQMQBUUserFullNameKeyPathKey
                                ascending:YES
                                selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [[self allContacts] sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

- (NSArray *)friends {
    
    NSMutableArray *friends = [NSMutableArray array];
    NSArray *allContactsIDs = self.serviceManager.contactListService.contactListMemoryStorage.userIDsFromContactList;
    
    for (NSNumber *userID in allContactsIDs) {
        
        QBContactListItem *item = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID.integerValue];
        if (item.subscriptionState == QBPresenceSubscriptionStateBoth) {
            
            QBUUser *user = [self.serviceManager.usersService.usersMemoryStorage userWithID:userID.integerValue];
            if (user) {
                
                [friends addObject:user];
            }
        }
    }
    
    return friends.copy;
}

- (NSArray *)idsOfUsers:(NSArray *)users {
    
    NSMutableArray *ids = [NSMutableArray array];
    
    for (QBUUser *user in users) {
        
        [ids addObject:@(user.ID)];
    }
    
    return ids.copy;
}

#pragma mark - States

- (BOOL)isFriendWithUserID:(NSUInteger)userID {
    
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return contactListItem.subscriptionState == QBPresenceSubscriptionStateBoth;
}

- (BOOL)isUserIDInPendingList:(NSUInteger)userID {
    
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return contactListItem.subscriptionState == QBPresenceSubscriptionStateFrom;
}

- (BOOL)isAwaitingForApprovalFromUserID:(NSUInteger)userID {
    
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return contactListItem.subscriptionState == QBPresenceSubscriptionStateTo;
}

- (BOOL)isUserOnlineWithID:(NSUInteger)userID {
    
    QBContactListItem *item = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return item.isOnline;
}

@end
