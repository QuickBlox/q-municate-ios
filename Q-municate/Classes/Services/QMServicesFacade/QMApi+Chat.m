//
//  QMApi+Messages.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMSettingsManager.h"
#import "QMApi+Notifications.m"
#import "QMContentService.h"
#import "QMChatUtils.h"

@implementation QMApi (Chat)

/**
 *  Messages
 */

#pragma mark - Messages

- (void)connectChat:(void(^)(BOOL success))block {
    [self.chatService connectWithCompletionBlock:^(NSError * _Nullable error) {
        //
        if (error != nil) {
            block(YES);
        }
        else {
            block(NO);
        }
    }];
}

- (void)disconnectFromChat {
    __weak __typeof(self)weakSelf = self;
    [self.chatService disconnectWithCompletionBlock:^(NSError * _Nullable error) {
        //
        if (error == nil) {
            [weakSelf.settingsManager setLastActivityDate:[NSDate date]];
        }
    }];
}

/**
 *  ChatDialog
 */

#pragma mark - ChatDialog

NSString const *kQMEditDialogExtendedNameParameter = @"name";
NSString const *kQMEditDialogExtendedPushOccupantsParameter = @"push[occupants_ids][]";
NSString const *kQMEditDialogExtendedPullOccupantsParameter = @"pull_all[occupants_ids][]";

- (void)fetchAllDialogs:(void(^)(void))completion {

    __weak __typeof(self)weakSelf = self;
    if (self.settingsManager.lastActivityDate != nil) {
        [self.chatService fetchDialogsUpdatedFromDate:self.settingsManager.lastActivityDate andPageLimit:kQMDialogsPageLimit iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            //
            [weakSelf.usersService getUsersWithIDs:[dialogsUsersIDs allObjects]];
        } completionBlock:^(QBResponse *response) {
            //
            if (weakSelf.isAuthorized && response.success) weakSelf.settingsManager.lastActivityDate = [NSDate date];
            if (completion) completion();
        }];
    }
    else {
        [self.chatService allDialogsWithPageLimit:kQMDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            //
            [weakSelf.usersService getUsersWithIDs:[dialogsUsersIDs allObjects]];
        } completion:^(QBResponse *response) {
            //
            if (weakSelf.isAuthorized && response.success) weakSelf.settingsManager.lastActivityDate = [NSDate date];
            if (completion) completion();
        }];
    }
}

- (void)fetchChatDialogWithID:(NSString *)dialogID completion:(void(^)(QBChatDialog *chatDialog))completion
{
    
    __weak typeof(self)weakSelf = self;
    
    [self.chatService fetchDialogWithID:dialogID completion:^(QBChatDialog *dialog) {
        //
        if (!dialog) {
            if (completion) completion(dialog);
            return;
        }
        [[weakSelf.usersService getUsersWithIDs:dialog.occupantIDs] continueWithBlock:^id(BFTask<NSArray<QBUUser *> *> *task) {
            if (completion) completion(dialog);
            return nil;
        }];
    }];
}


#pragma mark - Create Chat Dialogs


- (void)createPrivateChatDialogIfNeededWithOpponent:(QBUUser *)opponent completion:(void(^)(QBChatDialog *chatDialog))completion
{
    [self.chatService createPrivateChatDialogWithOpponent:opponent completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        //
        if (completion) completion(createdDialog);
    }];
}

- (void)createGroupChatDialogWithName:(NSString *)name occupants:(NSArray *)occupants completion:(void(^)(QBChatDialog *chatDialog))completion {
    
    __weak typeof(self)weakSelf = self;
    [self.chatService createGroupChatDialogWithName:name photo:nil occupants:occupants completion:^(QBResponse *response, QBChatDialog *createdDialog) {
        
        if (response.success) {
            
            __typeof(weakSelf)strongSelf = weakSelf;
            NSArray *occupantsIDs = [strongSelf idsWithUsers:occupants];
            
            [strongSelf.chatService sendSystemMessageAboutAddingToDialog:createdDialog toUsersIDs:occupantsIDs completion:^(NSError * _Nullable systemMessageError) {
                //
                [strongSelf.chatService sendNotificationMessageAboutAddingOccupants:occupantsIDs toDialog:createdDialog completion:^(NSError * _Nullable notificationError) {
                    //
                    if (completion) completion(createdDialog);
                }];
            }];
        } else {
            if (completion) completion(nil);
        }
    }];
}


#pragma mark - Edit dialog methods

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService changeDialogName:dialogName forChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.success) {
            
            [weakSelf.chatService sendNotificationMessageAboutChangingDialogName:updatedDialog completion:^(NSError * _Nullable error) {
                //
            }];
        }
        if (completion) completion(response,updatedDialog);
    }];
}

- (void)changeAvatar:(UIImage *)avatar forChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion
{
    __weak typeof(self)weakSelf = self;
    [self.contentService uploadPNGImage:avatar progress:^(float progress) {
        //
    } completion:^(QBResponse *response, QBCBlob *blob) {
        //
        // update chat dialog:
        if (!response.success) {
            return;
        }
        
        __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.chatService changeDialogAvatar:blob.publicUrl forChatDialog:chatDialog completion:^(QBResponse *updateResponse, QBChatDialog *updatedDialog) {
            //
            if (updateResponse.success) {
                // send notification:
                [strongSelf.chatService sendNotificationMessageAboutChangingDialogPhoto:updatedDialog completion:^(NSError * _Nullable error) {
                    //
                    if (completion) completion(updateResponse, updatedDialog);
                }];
            }

        }];
    }];
}

- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResponseBlock)completion {
    
    NSArray *occupantsToJoinIDs = [self idsWithUsers:occupants];
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService joinOccupantsWithIDs:occupantsToJoinIDs toChatDialog:chatDialog completion:^(QBResponse *response, QBChatDialog *updatedDialog) {
        //
        if (response.success) {
            __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.chatService sendSystemMessageAboutAddingToDialog:chatDialog toUsersIDs:occupantsToJoinIDs completion:^(NSError * _Nullable systemMessageError) {
                //
                [strongSelf.chatService sendNotificationMessageAboutAddingOccupants:occupantsToJoinIDs toDialog:updatedDialog completion:^(NSError * _Nullable notificationError) {
                    //
                    if (completion) completion(response,updatedDialog);
                }];
            }];
        } else {
            completion (response, nil);
        }
    }];
}

- (void)leaveChatDialog:(QBChatDialog *)chatDialog completion:(QBChatCompletionBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    [self.chatService sendNotificationMessageAboutLeavingDialog:chatDialog completion:^(NSError * _Nullable error) {
        //
        if (error == nil) {
            [weakSelf.chatService deleteDialogWithID:chatDialog.ID completion:^(QBResponse *response) {
                //
                if (completion) completion(response.error.error);
            }];
        } else {
            if (completion) completion(error);
        }
    }];
}

- (NSUInteger )occupantIDForPrivateChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(chatDialog.type == QBChatDialogTypePrivate, @"Chat dialog type != QBChatDialogTypePrivate");
    
    NSInteger myID = self.currentUser.ID;
    
    for (NSNumber *ID in chatDialog.occupantIDs) {
        
        if (ID.integerValue != myID) {
            return ID.integerValue;
        }
    }
    
    NSAssert(nil, @"Need update this case");
    return 0;
}

- (void)deleteChatDialog:(QBChatDialog *)dialog completion:(void(^)(BOOL success))completionHandler
{
    [self.chatService deleteDialogWithID:dialog.ID completion:^(QBResponse *response) {
        //
        if (completionHandler) completionHandler(response.success);
    }];
}

#pragma mark - Dialogs toos

- (NSArray *)dialogHistory {
    return [self.chatService.dialogsMemoryStorage unsortedDialogs];
}

- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID {
    
    return [self.chatService.dialogsMemoryStorage chatDialogWithID:dialogID];
}

- (NSArray *)allOccupantIDsFromDialogsHistory{
    
    NSArray *allDialogs = [self.chatService.dialogsMemoryStorage unsortedDialogs];
    NSMutableSet *ids = [NSMutableSet set];
    
    for (QBChatDialog *dialog in allDialogs) {
        [ids addObjectsFromArray:dialog.occupantIDs];
    }
    
    return ids.allObjects;
}

@end
