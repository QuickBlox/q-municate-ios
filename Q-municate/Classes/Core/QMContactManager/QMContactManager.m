//
//  QMContactManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactManager.h"
#import "QMCore.h"
#import "QMNotification.h"
#import "QMMessagesHelper.h"
#import <QMChatViewController/QMDateUtils.h>

@interface QMContactManager () <QBChatDelegate>

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;
@property (nonatomic) NSMutableArray<NSNumber *> *requests;

@end

@implementation QMContactManager

@dynamic serviceManager;

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager {
    
    self = [super initWithServiceManager:serviceManager];
    if (self) {
        _requests = [NSMutableArray array];
        [QBChat.instance addDelegate:self];
    }
    return self;
}

//MARK: - Contacts management

- (BFTask *)addUserToContactList:(QBUUser *)user {
    
    // determine whether we have already received contact request from user or not
    QBChatDialog *chatDialog = [self.serviceManager.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
    QBChatMessage *lastMessage = [self.serviceManager.chatService.messagesMemoryStorage lastMessageFromDialogID:chatDialog.ID];
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
    
    if (lastMessage.messageType == QMMessageTypeContactRequest
        && lastMessage.senderID != self.serviceManager.currentProfile.userData.ID
        && contactListItem == nil) {
        
        return [self confirmAddContactRequest:user];
    }
    else {
        
        return [[[self.serviceManager.contactListService addUserToContactListRequest:user]
                 continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
                     
                     return [self.serviceManager.chatService createPrivateChatDialogWithOpponent:user];
                     
                 }] continueWithSuccessBlock:^id(BFTask<QBChatDialog *> *task) {
                     
                     QBChatMessage *chatMessage = [QMMessagesHelper contactRequestNotificationForUser:user];
                     [self.serviceManager.chatService sendMessage:chatMessage
                                                             type:chatMessage.messageType
                                                         toDialog:task.result
                                                    saveToHistory:YES
                                                    saveToStorage:YES
                                                       completion:nil];
                     return nil;
                 }];
    }
}

- (BFTask *)confirmAddContactRequest:(QBUUser *)user {
    
    return [[self.serviceManager.contactListService acceptContactRequest:user.ID]
            continueWithSuccessBlock:^id(BFTask *__unused task) {
                return [self.serviceManager.chatService sendMessageAboutAcceptingContactRequest:YES
                                                                                   toOpponentID:user.ID];
            }];
}

- (BFTask *)rejectAddContactRequest:(QBUUser *)user {
    
    return [[self.serviceManager.contactListService rejectContactRequest:user.ID]
            continueWithSuccessBlock:^id(BFTask *__unused task) {
                return [self.serviceManager.chatService sendMessageAboutAcceptingContactRequest:NO
                                                                                   toOpponentID:user.ID];
            }];
}

- (BFTask *)removeUserFromContactList:(QBUUser *)user {
    
    __block QBChatDialog *chatDialog = nil;
    
    return [[[[self.serviceManager.contactListService removeUserFromContactListWithUserID:user.ID]
              continueWithSuccessBlock:^id(BFTask *__unused task) {
                  
                  return [self.serviceManager.chatService createPrivateChatDialogWithOpponent:user];
                  
              }] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
                  
                  chatDialog = t.result;
                  QBChatMessage *notificationMessage = [QMMessagesHelper removeContactNotificationForUser:user];
                  
                  return [self.serviceManager.chatService sendMessage:notificationMessage
                                                                 type:notificationMessage.messageType
                                                             toDialog:chatDialog
                                                        saveToHistory:YES
                                                        saveToStorage:NO];
                  
              }] continueWithBlock:^id _Nullable(BFTask * __unused t) {
                  
                  return [self.serviceManager.chatService deleteDialogWithID:chatDialog.ID];
              }];
}

//MARK: - Users

- (NSString *)fullNameForUserID:(NSUInteger)userID {
    
    QBUUser *user = [self.serviceManager.usersService.usersMemoryStorage userWithID:userID];
    NSString *fullName = user.fullName ?: [NSString stringWithFormat:@"%tu", userID];
    
    return fullName;
}

- (NSArray *)allContacts {
    
    NSArray *ids = [self.serviceManager.contactListService.contactListMemoryStorage userIDsFromContactList];
    NSArray *allContacts = [self.serviceManager.usersService.usersMemoryStorage usersWithIDs:ids];
    
    return allContacts;
}

- (NSArray *)allContactsSortedByFullName {
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:qm_keypath(QBUUser, fullName)
                                                           ascending:YES
                                                            selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [[self allContacts] sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

- (NSArray *)friends {
    
    NSArray *allContactListItems = [self.serviceManager.contactListService.contactListMemoryStorage allContactListItems];
    NSMutableArray *friends = [NSMutableArray arrayWithCapacity:allContactListItems.count];
    
    for (QBContactListItem *item in allContactListItems) {
        
        if (item.subscriptionState != QBPresenceSubscriptionStateNone) {
            
            QBUUser *user = [self.serviceManager.usersService.usersMemoryStorage userWithID:item.userID];
            if (user) {
                
                [friends addObject:user];
            }
        }
    }
    
    return [friends copy];
}

- (NSArray *)friendsByExcludingUsersWithIDs:(NSArray *)userIDs {
    
    NSArray *friends = [self friends];
    NSMutableArray *mutableUsers = [friends mutableCopy];
    
    for (QBUUser *user in friends) {
        
        if ([userIDs containsObject:@(user.ID)]) {
            [mutableUsers removeObject:user];
        }
    }
    
    return [mutableUsers copy];
}

- (NSArray *)idsOfUsers:(NSArray *)users {
    
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        
        [ids addObject:@(user.ID)];
    }
    
    return [ids copy];
}

- (NSArray *)occupantsWithoutCurrentUser:(NSArray *)occupantIDs {
    
    NSMutableArray *occupantsWithoutCurrentUser = [occupantIDs mutableCopy];
    
    [occupantsWithoutCurrentUser removeObject:@(self.serviceManager.currentProfile.userData.ID)];
    
    return [occupantsWithoutCurrentUser copy];
}

- (NSString *)onlineStatusForUser:(QBUUser *)user {
    
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
    
    NSString *status = nil;
    

    if (!contactListItem) {
        
        if ([self isUserContactRequest:user.ID]) {
            return @"Contact request";
        }
        
        return nil;
    }
    
    if (user.ID == self.serviceManager.currentProfile.userData.ID || contactListItem.isOnline) {
        return NSLocalizedString(@"QM_STR_ONLINE", nil);
    }
    else {
        
        NSDate *statusDate = user.lastRequestAt;
        if (statusDate == nil) {
            statusDate = user.createdAt;
        }
        
        status = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"QM_STR_LAST_SEEN", nil),
                  [QMDateUtils formattedLastSeenString:statusDate withTimePrefix:NSLocalizedString(@"QM_STR_TIME_PREFIX", nil)]];
        
        if (contactListItem.subscriptionState != QBPresenceSubscriptionStateNone) {
            // requesting update on activity
            [[QBChat instance] lastActivityForUserWithID:contactListItem.userID completion:^(NSUInteger seconds, NSError * _Nullable error) {
                if (error == nil) {
                    if (seconds != (NSUInteger)fabs([user.lastRequestAt timeIntervalSinceNow])) {
                        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-(NSTimeInterval)seconds];
                        if ([user.lastRequestAt compare:date] == NSOrderedAscending) {
                            // always should have newest date
                            user.lastRequestAt = date;
                            [self.serviceManager.usersService updateUsers:@[user]];
                        }
                    }
                }
            }];
        }
    }
    
    return status;
}

//MARK: - States

- (BOOL)isFriendWithUserID:(NSUInteger)userID {
    
    if (userID == self.serviceManager.currentProfile.userData.ID) {
        
        return YES;
    }
    
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return contactListItem != nil && contactListItem.subscriptionState != QBPresenceSubscriptionStateNone;
}

- (BOOL)isContactListItemExistentForUserWithID:(NSUInteger)userID {
    
    QBContactListItem *contactListItem = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return contactListItem != nil;
}

- (BOOL)isUserOnlineWithID:(NSUInteger)userID {
    
    QBContactListItem *item = [self.serviceManager.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    
    return item.isOnline;
}

// MARK: QBChatContactListProtocol

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID {
    NSParameterAssert(![self.requests containsObject:@(userID)]);
    [self.requests addObject:@(userID)];
}

- (void)chatDidReceiveAcceptContactRequestFromUser:(NSUInteger)userID {
    [self.requests removeObject:@(userID)];
}

- (void)chatDidReceiveRejectContactRequestFromUser:(NSUInteger)userID {
    [self.requests removeObject:@(userID)];
}

- (BOOL)isUserContactRequest:(NSUInteger)userID {
    return [self.requests containsObject:@(userID)];
}

@end
