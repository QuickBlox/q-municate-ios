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
        [weakSelf createPrivateChatDialogIfNeededWithOpponent:user completion:^(QBChatDialog *chatDialog) {
            [weakSelf sendContactRequestSendNotificationToUser:user completion:^(NSError *error, QBChatMessage *notification) {
                
                if (completion) completion(success, notification);
            }];
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
                    completion(succeed, nil);
                    return;
                }
                completion(success, notification);
            }];
        }];

    }];
}

- (void)confirmAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    [self.contactListService acceptContactRequest:user.ID completion:^(BOOL success) {
        //
        [self.chatService notifyOponentAboutAcceptingContactRequest:YES opponentID:user.ID completion:^(NSError *error) {
            //
            completion(error == nil ? YES : NO);
        }];
    }];
}

- (void)rejectAddContactRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    [self.contactListService rejectContactRequest:user.ID completion:^(BOOL success) {
        //
        [self.chatService notifyOponentAboutAcceptingContactRequest:NO opponentID:user.ID completion:^(NSError *error) {
            //
            completion(error == nil ? YES : NO);
        }];
    }];
}

/**
 @param QBUUser ID
 @return QBContactListItem from chaced contactList
 */

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
    return [self.contactListService.usersMemoryStorage userWithID:userID];
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

- (NSArray *)contactsOnly
{
    
    NSArray *IDs = [self.contactListService idsOfContactsOnly];
    NSArray *contacts = [self usersWithIDs:IDs];
    return contacts;
}

- (BOOL)isContactRequestUserWithID:(NSInteger)userID
{
//    
//    for (NSNumber *contactID in self.usersService.confirmRequestUsersIDs) {
//        if (contactID.intValue == userID) {
//            return YES;
//        }
//    }
    return NO;
}

- (NSArray *)contactRequestUsers
{
//    [self.contactListService]
//    NSArray *ids = [self.usersService.confirmRequestUsersIDs allObjects];
//    NSArray *users = [self usersWithIDs:ids];
//    return users;
    
    return nil;
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

    BOOL isFriend = [self isFriend:[self.contactListService.usersMemoryStorage userWithID:occupantID]];
    return isFriend;
}

- (BOOL)isFriend:(QBUUser *)user
{
    NSArray *friends = [self.contactListService.contactListMemoryStorage userIDsFromContactList];
    for (NSUInteger i = 0; i < friends.count; i++) {
        if ([friends[i]  isEqual: @(user.ID)]) return YES;
    }
    return NO;
}

- (void)retriveIfNeededUserWithID:(NSUInteger)userID completion:(void(^)(BOOL retrieveWasNeeded))completionBlock
{
    [self.contactListService retrieveUsersWithIDs:@[@(userID)] forceDownload:NO completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        if (response != nil) {
            completionBlock(YES);
            return;
        }
        completionBlock(NO);
    }];
}

- (void)retriveIfNeededUsersWithIDs:(NSArray *)usersIDs completion:(void (^)(BOOL retrieveWasNeeded))completionBlock
{
    [self.contactListService retrieveUsersWithIDs:usersIDs forceDownload:NO completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        if (response != nil) {
            completionBlock(YES);
            return;
        }
        completionBlock(NO);
    }];
}


#pragma mark - Update current User

- (void)changePasswordForCurrentUser:(QBUUser *)currentUser completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    QBUpdateUserParameters *params = [QBUpdateUserParameters new];
    params.password = currentUser.password;
//    [self.usersService updateCurrentUser:params withCompletion:^(QBResponse *response, QBUUser *user) {
//        //
//        if ([weakSelf checkResponse:response withObject:user]) {
//
//            weakSelf.currentUser.password = currentUser.password;
//            [weakSelf.settingsManager setLogin:currentUser.email andPassword:currentUser.password];
//        }
//        
//        completion(response.success);
//    }];
}

- (void)updateUser:(QBUUser *)user image:(UIImage *)image progress:(QMContentProgressBlock)progress completion:(void (^)(BOOL success))completion {
    
    __block QBUUser *userInfo = user;
    __weak __typeof(self)weakSelf = self;
    
    void (^updateUserProfile)(QBCBlob *) =^(QBCBlob *blob) {
        
        if (!userInfo) {
            userInfo = weakSelf.currentUser;
        }
        
        if (blob.publicUrl.length > 0) {
            userInfo.avatarUrl = blob.publicUrl;
        }
        userInfo.blobID = blob.ID;
        NSString *password = userInfo.password;
        userInfo.password = nil;
        
//        [weakSelf.usersService updateUser:userInfo withCompletion:^(QBUUserResult *result) {
//            
//            if ([weakSelf checkResult:result]) {
//                
//                weakSelf.currentUser = result.user;
//                weakSelf.currentUser.password = password;
//            }
//            
//            completion(result.success);
//        }];
    };
    
//    if (image) {
//        [self.contentService uploadJPEGImage:image progress:progress completion:^(QBCFileUploadTaskResult *result) {
//            if ([weakSelf checkResult:result]) {
//                updateUserProfile(result.uploadedBlob);
//            }
//            else {
//                updateUserProfile(nil);
//            }
//        }];
//    }
//    else {
//        updateUserProfile(nil);
//    }
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
        [weakSelf.contactListService retrieveUsersWithFacebookIDs:facebookFriendsIDs completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            //
            if (!response.success) {
                return;
            }
            if ([users count] == 0) {
                return;
            }
            
            // sending contact requests:
            for (QBUUser *user in users) {
                [weakSelf addUserToContactList:user completion:nil];
            }
        }];
    }];
}

- (void)importFriendsFromAddressBookWithCompletion:(void(^)(BOOL succeded, NSError *error))completionBLock
{
    __weak __typeof(self)weakSelf = self;
    [QMAddressBook getContactsWithEmailsWithCompletionBlock:^(NSArray *contacts, BOOL success, NSError *error) {
        
        if ([contacts count] == 0) {
            completionBLock(NO, error);
            return;
        }
        NSMutableArray *emails = [NSMutableArray array];
        for (ABPerson *person in contacts) {
            [emails addObjectsFromArray:person.emails];
        }
        
        // post request for emails to QB server:
        [weakSelf.contactListService retrieveUsersWithEmails:emails completion:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
            //
            if (!response.success) {
                completionBLock(NO, nil);
                return;
            }
            
            if ([users count] == 0) {
                completionBLock(NO, nil);
                return;
            }
            
            // sending contact requests:
            for (QBUUser *user in users) {
                [weakSelf addUserToContactList:user completion:^(BOOL successed, QBChatMessage *notification) {}];
            }
            completionBLock(YES, nil);
        }];
    }];
}

@end
