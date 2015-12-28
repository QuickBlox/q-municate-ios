//
//  QMApi+Users.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMContentService.h"
#import "QMFacebookService.h"
#import "QMSettingsManager.h"
#import "QMAddressBook.h"
#import "ABPerson.h"

@implementation QMApi (Users)

- (void)addUserToContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.contactListService addUserToContactListRequest:user completion:^(BOOL success) {
        //
        [[weakSelf.chatService createPrivateChatDialogWithOpponent:user] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
            //
            [weakSelf sendContactRequestSendNotificationToUser:user completion:^(NSError *error, QBChatMessage *notification) {
                
                if (completion) completion(task.isCompleted, notification);
            }];
            
            return nil;
        }];
    }];
}

- (void)removeUserFromContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.contactListService removeUserFromContactListWithUserID:user.ID completion:^(BOOL success) {
        //
        
        [weakSelf sendContactRequestDeleteNotificationToUser:user completion:^(NSError *error, QBChatMessage *notification) {
            // delete chat dialog:
            QBChatDialog *dialog = [weakSelf.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
            [weakSelf deleteChatDialog:dialog completion:^(BOOL succeed) {
                if (!succeed) {
                    if (completion) completion(succeed, nil);
                    return;
                }
                if (completion) completion(success, notification);
            }];
        }];

    }];
}

- (void)confirmAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.contactListService acceptContactRequest:user.ID completion:^(BOOL success) {
        //
        [weakSelf.chatService sendMessageAboutAcceptingContactRequest:YES toOpponentID:user.ID completion:^(NSError * _Nullable error) {
            //
            if (completion) completion(error == nil ? YES : NO);
        }];
    }];
}

- (void)rejectAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.contactListService rejectContactRequest:user.ID completion:^(BOOL success) {
        //
        [weakSelf.chatService sendMessageAboutAcceptingContactRequest:NO toOpponentID:user.ID completion:^(NSError * _Nullable error) {
            //
            if (completion) completion(error == nil ? YES : NO);
        }];
    }];
}

- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID {
    return [self.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
}

- (NSArray *)idsWithUsers:(NSArray *)users {
    
    NSMutableSet *ids = [NSMutableSet set];
    for (QBUUser *user in users) {
        [ids addObject:@(user.ID)];
    }
    return [ids allObjects];
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    return [self.usersService.usersMemoryStorage userWithID:userID];
}

- (NSArray *)usersWithIDs:(NSArray *)ids {
    
    NSMutableArray *allFriends = [NSMutableArray array];
    for (NSNumber * friendID in ids) {
        QBUUser *user = [self userWithID:friendID.integerValue];
        if (user) {
            [allFriends addObject:user];
        }
    }
    
    return allFriends;
}

- (NSArray *)friends {
    
    NSArray *ids = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    NSArray *allFriends = [self usersWithIDs:ids];
    
    return allFriends;
}

- (NSArray *)idsOfContactsOnly {
    
    NSMutableSet *IDs = [NSMutableSet new];
    NSArray *contactItems = [QBChat instance].contactList.contacts;
    
    for (QBContactListItem *item in contactItems) {
        [IDs addObject:@(item.userID)];
    }
    
    for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
        
        if (item.subscriptionState == QBPresenseSubscriptionStateFrom) {
            [IDs addObject:@(item.userID)];
        }
    }
    return IDs.allObjects;
}

- (NSArray *)contactsOnly
{
    
    NSArray *IDs = [self idsOfContactsOnly];
    NSArray *contacts = [self usersWithIDs:IDs];
    return contacts;
}

- (BOOL)isContactRequestUserWithID:(NSInteger)userID
{
    QBChatDialog *privateDialog = [self.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:userID];
    if (privateDialog == nil) return NO;
    
    QBChatMessage *lastMessage = [self.chatService.messagesMemoryStorage lastMessageFromDialogID:privateDialog.ID];
    if (lastMessage.messageType == QMMessageTypeContactRequest) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)userIDIsInPendingList:(NSUInteger)userID {
    QBContactListItem *contactlistItem = [self.contactListService.contactListMemoryStorage contactListItemWithUserID:userID];
    if (contactlistItem.subscriptionState != QBPresenseSubscriptionStateNone) {
        return NO;
    }
    return YES;
}

- (BOOL)isFriend:(QBUUser *)user
{
    NSArray *friends = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    for (NSUInteger i = 0; i < friends.count; i++) {
        if ([friends[i]  isEqual: @(user.ID)]) return YES;
    }
    return NO;
}

#pragma mark - Update current User

- (void)changePasswordForCurrentUser:(QBUpdateUserParameters *)updateParams completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateCurrentUser:updateParams successBlock:^(QBResponse *response, QBUUser *user) {
        //
        if (response.success) {
            weakSelf.currentUser.password = updateParams.password;
            [weakSelf.settingsManager setLogin:user.email andPassword:updateParams.password];
        }
        if (completion) completion(response.success);
    } errorBlock:^(QBResponse *response) {
        //
        if (completion) completion(response.success);
    }];
}

- (void)updateCurrentUser:(QBUpdateUserParameters *)updateParams image:(UIImage *)image progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __block QBUpdateUserParameters *params = updateParams;
    __weak __typeof(self)weakSelf = self;
    
    void (^updateUserProfile)(QBCBlob *) =^(QBCBlob *blob) {
        
        if (!params) {
            params = [QBUpdateUserParameters new];
            params.customData = weakSelf.currentUser.customData;
        }
        
        if (blob.publicUrl.length > 0) {
            params.avatarUrl = blob.publicUrl;
        }
        params.blobID = blob.ID;
        NSString *password = weakSelf.currentUser.password;
        
        [QBRequest updateCurrentUser:params successBlock:^(QBResponse *response, QBUUser *updatedUser) {
            //
            if (response.success) {
                weakSelf.currentUser.password = password;
            }
            if (completion) completion(response.success);
        } errorBlock:^(QBResponse *response) {
            //
            if (completion) completion(response.success);
        }];
    };
    
    if (image) {
        [self.contentService uploadJPEGImage:image progress:progress completion:^(QBResponse *response, QBCBlob *blob) {
            //
            if (response.success) {
                updateUserProfile(blob);
            }
            else {
                updateUserProfile(nil);
            }
        }];
    }
    else {
        updateUserProfile(nil);
    }
}

- (void)updateCurrentUser:(QBUpdateUserParameters *)params imageUrl:(NSURL *)imageUrl progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.contentService downloadFileWithUrl:imageUrl completion:^(NSData *data) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            [weakSelf updateCurrentUser:params image:image progress:progress completion:completion];
        }
    }];
}

#pragma mark - Import friends

- (void)importFriendsFromFacebook:(void (^)(BOOL))completion {
    __weak __typeof(self)weakSelf = self;
    [QMFacebookService fetchMyFriendsIDs:^(NSArray *facebookFriendsIDs) {
        
        if ([facebookFriendsIDs count] == 0) {
            if (completion) completion(NO);
            return;
        }
        [[weakSelf.usersService getUsersWithFacebookIDs:facebookFriendsIDs] continueWithBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
            //
            if (task.error != nil) {
                if (completion) completion(NO);
                return nil;
            }
            if ([task.result count] == 0) {
                if (completion) completion(NO);
                return nil;
            }
            
            // sending contact requests:
            for (QBUUser *user in task.result) {
                [weakSelf addUserToContactList:user completion:nil];
            }
            if (completion) completion(YES);
            return nil;
        }];
    }];
}

- (void)importFriendsFromAddressBookWithCompletion:(void(^)(BOOL succeded, NSError *error))completionBlock
{
    __weak __typeof(self)weakSelf = self;
    [QMAddressBook getContactsWithEmailsWithCompletionBlock:^(NSArray *contacts, BOOL success, NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        
        if ([contacts count] == 0) {
            completionBlock(NO, error);
            return;
        }
        NSMutableArray *emails = [NSMutableArray array];
        for (ABPerson *person in contacts) {
            [emails addObjectsFromArray:person.emails];
        }
        
        // post request for emails to QB server:
        [[strongSelf.usersService getUsersWithEmails:emails] continueWithBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
            //
            if (task.error != nil) {
                if (completionBlock) completionBlock(NO, nil);
                return nil;
            }
            
            if ([task.result count] == 0) {
                if (completionBlock) completionBlock(NO, nil);
                return nil;
            }
            
            // sending contact requests:
            for (QBUUser *user in task.result) {
                [weakSelf addUserToContactList:user completion:nil];
            }
            
            if (completionBlock) completionBlock(YES, nil);
            
            return nil;
        }];
    }];
}

@end
