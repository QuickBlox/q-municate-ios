//
//  QMApi+Users.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMUsersService.h"
#import "QMContentService.h"
#import "QMFacebookService.h"
#import "QMMessagesService.h"
#import "QMChatReceiver.h"
#import "QMChatDialogsService.h"
#import "QMSettingsManager.h"
#import "QMAddressBook.h"
#import "ABPerson.h"


@implementation QMApi (Users)

- (void)addUserToContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion {

    __weak typeof(self) weakSelf = self;
    [self.messagesService chat:^(QBChat *chat) {
        [weakSelf.usersService addUser:user];
        BOOL success = [chat addUserToContactListRequest:user.ID];
        
        [weakSelf createPrivateChatDialogIfNeededWithOpponent:user completion:^(QBChatDialog *chatDialog) {
            [weakSelf sendContactRequestSendNotificationToUser:user completion:^(NSError *error, QBChatMessage *notification) {

                if (completion) completion(success, notification);
            }];
        }];
    }];
}

- (void)removeUserFromContactList:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.messagesService chat:^(QBChat *chat) {
        BOOL successed = [chat removeUserFromContactList:user.ID];
        
        [weakSelf sendContactRequestDeleteNotificationToUser:user completion:^(NSError *error, QBChatMessage *notification) {
            // delete chat dialog:
            QBChatDialog *dialog = [weakSelf.chatDialogsService privateDialogWithOpponentID:user.ID];
            [weakSelf deleteChatDialog:dialog completion:^(BOOL success) {
                if (!success) {
                    completion(success, nil);
                    return;
                }
                completion(successed, notification);
            }];
        }];
    }];
}

- (void)confirmAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.messagesService chat:^(QBChat *chat) {
        BOOL success = [chat confirmAddContactRequest:user.ID];
        [weakSelf sendContactRequestConfirmNotificationToUser:user completion:^(NSError *error, QBChatMessage *notification) {
            [weakSelf.usersService deleteContactRequestUserID:user.ID];
            completion(success, notification);
        }];
    }];
}

- (void)rejectAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success, QBChatMessage *notification))completion {
    
    __weak typeof(self) weakSelf = self;
    [self.messagesService chat:^(QBChat *chat) {
        BOOL success = [chat rejectAddContactRequest:user.ID];
        [weakSelf sendContactRequestRejectNotificationToUser:user completion:^(NSError *error, QBChatMessage *notification) {
            [weakSelf.usersService deleteContactRequestUserID:user.ID];
            completion(success, notification);
        }];
    }];
}

/**
 @param QBUUser ID
 @return QBContactListItem from chaced contactList
 */

- (QBContactListItem *)contactItemWithUserID:(NSUInteger)userID {
    
    NSArray *contacts = self.usersService.contactList;
    for (QBContactListItem *item in contacts) {
        
        if (item.userID == userID) {
            return item;
        }
    }
    
    return nil;
}

- (NSArray *)idsWithUsers:(NSArray *)users {

    NSMutableSet *ids = [NSMutableSet set];
    for (QBUUser *user in users) {
        [ids addObject:@(user.ID)];
    }
    return [ids allObjects];
}

- (QBUUser *)userWithID:(NSUInteger)userID {
    return [self.usersService userWithID:userID];
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
    
    NSArray *ids = [self.usersService idsFromContactListItems];
    NSArray *allFriends = [self usersWithIDs:ids];
    
    return allFriends;
}

- (BOOL)isContactRequestUserWithID:(NSInteger)userID
{
    for (NSNumber *contactID in self.usersService.confirmRequestUsersIDs) {
        if (contactID.intValue == userID) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)contactRequestUsers
{
    NSArray *ids = [self.usersService.confirmRequestUsersIDs allObjects];
    NSArray *users = [self usersWithIDs:ids];
    return users;
}

- (QBUUser *)userForContactRequestWithPrivateChatDialog:(QBChatDialog *)chatDialog
{
    NSAssert(chatDialog.type == QBChatDialogTypePrivate, @"Dialog is not private. Private dialog needed.");
    QBUUser *contact = nil;
    NSInteger occupantID = [self occupantIDForPrivateChatDialog:chatDialog];
    
    BOOL isContactRequest = [self isContactRequestUserWithID:occupantID];
    if (isContactRequest) {
        contact = [self userWithID:occupantID];
    }
    return contact;
}

- (BOOL)isFriendForChatDialog:(QBChatDialog *)chatDialog
{
    NSUInteger occupantID = [self occupantIDForPrivateChatDialog:chatDialog];
    BOOL isFriend = [self.usersService isFriendWithID:occupantID];
    return isFriend;
}

- (BOOL)isFriend:(QBUUser *)user
{
    return [self.usersService isFriendWithID:user.ID];
}

- (void)retriveIfNeededUserWithID:(NSUInteger)userID completion:(void(^)(BOOL retrieveWasNeeded))completionBlock
{
    [self.usersService retriveIfNeededUserWithID:userID completion:completionBlock];
}


#pragma mark - Update current User

- (void)changePasswordForCurrentUser:(QBUUser *)currentUser completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.usersService updateUser:currentUser withCompletion:^(QBUUserResult *result) {
        
        if ([weakSelf checkResult:result]) {
            
            weakSelf.currentUser = result.user;
            weakSelf.currentUser.password = currentUser.password;
            [weakSelf.settingsManager setLogin:currentUser.email andPassword:currentUser.password];
        }
        
        completion(result.success);
    }];
}

- (void)updateUser:(QBUUser *)user image:(UIImage *)image progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __block QBUUser *userInfo = user;
    __weak __typeof(self)weakSelf = self;
    
    void (^updateUserProfile)(QBCBlob *) =^(QBCBlob *blob) {

        if (!userInfo) {
            userInfo = weakSelf.currentUser;
        }
        
        if (blob.publicUrl.length > 0) {
            userInfo.avatarURL = blob.publicUrl;
        }
        userInfo.blobID = blob.ID;
        NSString *password = userInfo.password;
        userInfo.password = nil;
        
        [weakSelf.usersService updateUser:userInfo withCompletion:^(QBUUserResult *result) {
            
            if ([weakSelf checkResult:result]) {
                
                weakSelf.currentUser = result.user;
                weakSelf.currentUser.password = password;
            }
            
            completion(result.success);
        }];
    };
    
    if (image) {
        [self.contentService uploadJPEGImage:image progress:progress completion:^(QBCFileUploadTaskResult *result) {
            if ([weakSelf checkResult:result]) {
                updateUserProfile(result.uploadedBlob);
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

- (void)updateUser:(QBUUser *)user imageUrl:(NSURL *)imageUrl progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.contentService downloadFileWithUrl:imageUrl completion:^(NSData *data) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            [weakSelf updateUser:user image:image progress:progress completion:completion];
        }
    }];
}


#pragma mark - Import friends

- (void)importFriendsFromFacebook
{
    __weak __typeof(self)weakSelf = self;
    [QMFacebookService fetchMyFriendsIDs:^(NSArray *facebookFriendsIDs) {
        
        if ([facebookFriendsIDs count] == 0) {
            return;
        }
        [weakSelf.usersService retrieveUsersWithFacebookIDs:facebookFriendsIDs completion:^(QBUUserPagedResult *pagedResult) {

            if (!pagedResult.success) {
                return;
            }
            if ([pagedResult.users count] == 0) {
                return;
            }
            
            // sending contact requests:
            for (QBUUser *user in pagedResult.users) {
                [weakSelf addUserToContactList:user completion:nil];
            }
        }];
    }];
}

- (void)importFriendsFromAddressBook
{
    __weak __typeof(self)weakSelf = self;
    [QMAddressBook getContactsWithEmailsWithCompletionBlock:^(NSArray *contactsWithEmails) {
        
        if ([contactsWithEmails count] == 0) {
            return;
        }
        NSMutableArray *emails = [NSMutableArray array];
        for (ABPerson *person in contactsWithEmails) {
            [emails addObjectsFromArray:person.emails];
        }
        
        // post request for emails to QB server:
        [weakSelf.usersService retrieveUsersWithEmails:emails completion:^(QBUUserPagedResult *pagedResult) {
            if (!pagedResult.success) {
                return;
            }
            
            if ([pagedResult.users count] == 0) {
                return;
            }
            
            // sending contact requests:
            for (QBUUser *user in pagedResult.users) {
                [weakSelf addUserToContactList:user completion:^(BOOL success, QBChatMessage *notification) {}];
            }
        }];
    }];
}

@end
