//
//  QMApi+Messages.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMSettingsManager.h"
#import "QMContentService.h"
#import "QMAVCallManager.h"
#import "QMChatUtils.h"

@implementation QMApi (Chat)

/**
 *  Messages
 */

#pragma mark - Messages

- (void)connectChat:(void(^)(BOOL success))block {
    [[self.chatService connect] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        //
        if (block) {
            block(task.isFaulted ? NO : YES);
        }
        return nil;
    }];
}

- (void)disconnectFromChat {
    @weakify(self);
    [[self.chatService disconnect] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        //
        if (task.isCompleted) {
            @strongify(self);
            [self.settingsManager setLastActivityDate:[NSDate date]];
        }
        return nil;
    }];
}

- (void)disconnectFromChatIfNeeded {
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground && !self.avCallManager.hasActiveCall && [[QBChat instance] isConnected]) {
        [self disconnectFromChat];
    }
}

/**
 *  ChatDialog
 */

#pragma mark - ChatDialog

- (void)fetchAllDialogs:(void(^)(void))completion {

    @weakify(self);
    if (self.settingsManager.lastActivityDate != nil) {
        [[self.chatService fetchDialogsUpdatedFromDate:self.settingsManager.lastActivityDate andPageLimit:kQMDialogsPageLimit iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            @strongify(self);
            [self.usersService getUsersWithIDs:[dialogsUsersIDs allObjects]];
        }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            @strongify(self);
            if (self.isAuthorized && task.isCompleted) self.settingsManager.lastActivityDate = [NSDate date];
            if (completion) completion();
            return nil;
        }];
    }
    else {
        [[self.chatService allDialogsWithPageLimit:kQMDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
            @strongify(self);
            [self.usersService getUsersWithIDs:[dialogsUsersIDs allObjects]];
        }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            //
            @strongify(self);
            if (self.isAuthorized && task.isCompleted) self.settingsManager.lastActivityDate = [NSDate date];
            if (completion) completion();
            return nil;
        }];
    }
}

#pragma mark - Create Chat Dialogs

- (void)createGroupChatDialogWithName:(NSString *)name occupants:(NSArray *)occupants completion:(void(^)(QBChatDialog *chatDialog))completion {
    
    __block QBChatDialog *chatDialog = nil;
    NSArray *occupantsIDs = [self idsWithUsers:occupants];
    
    @weakify(self);
    [[[self.chatService createGroupChatDialogWithName:name photo:nil occupants:occupants] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        @strongify(self);
        if (task.isFaulted) {
            if (completion) completion(nil);
            return nil;
        } else {
            if (completion) completion(task.result);
            chatDialog = task.result;
            return [self.chatService sendSystemMessageAboutAddingToDialog:chatDialog toUsersIDs:occupantsIDs];
        }
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        @strongify(self);
        return [self.chatService sendNotificationMessageAboutAddingOccupants:occupantsIDs toDialog:chatDialog withNotificationText:kDialogsUpdateNotificationMessage];
    }];
}

#pragma mark - Edit dialog methods

- (void)changeChatName:(NSString *)dialogName forChatDialog:(QBChatDialog *)chatDialog completion:(void (^)(QBChatDialog *updatedDialog))completion {
    
    @weakify(self);
    [[self.chatService changeDialogName:dialogName forChatDialog:chatDialog] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        @strongify(self);
        if (task.isFaulted) {
            if (completion) completion(nil);
            return nil;
        } else {
            if (completion) completion(task.result);
            return [self.chatService sendNotificationMessageAboutChangingDialogName:task.result withNotificationText:kDialogsUpdateNotificationMessage];
        }
    }];
}

- (void)changeAvatar:(UIImage *)avatar forChatDialog:(QBChatDialog *)chatDialog completion:(void(^)(QBChatDialog *updatedDialog))completion
{
    @weakify(self);
    [self.contentService uploadPNGImage:avatar progress:^(float progress) {
        //
    } completion:^(QBResponse *response, QBCBlob *blob) {
        //
        // update chat dialog:
        if (!response.success) {
            return;
        }
        
        @strongify(self);
        [[self.chatService changeDialogAvatar:blob.publicUrl forChatDialog:chatDialog] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
            //
            if (task.isFaulted) {
                if (completion) completion(nil);
                return nil;
            } else {
                if (completion) completion(task.result);
                return [self.chatService sendNotificationMessageAboutChangingDialogPhoto:task.result withNotificationText:kDialogsUpdateNotificationMessage];
            }
        }];
    }];
}

- (void)joinOccupants:(NSArray *)occupants toChatDialog:(QBChatDialog *)chatDialog completion:(void(^)(QBChatDialog *updatedDialog))completion {
    
    __block QBChatDialog *dialog = nil;
    NSArray *occupantsToJoinIDs = [self idsWithUsers:occupants];
    
    @weakify(self);
    [[[self.chatService joinOccupantsWithIDs:occupantsToJoinIDs toChatDialog:chatDialog] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        //
        if (task.isFaulted) {
            if (completion) completion(nil);
            return nil;
        } else {
            @strongify(self);
            dialog = task.result;
            if (completion) completion(task.result);
            return [self.chatService sendSystemMessageAboutAddingToDialog:dialog toUsersIDs:occupantsToJoinIDs];
        }
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        @strongify(self);
        return [self.chatService sendNotificationMessageAboutAddingOccupants:occupantsToJoinIDs toDialog:dialog withNotificationText:kDialogsUpdateNotificationMessage];
    }];
}

- (void)leaveChatDialog:(QBChatDialog *)chatDialog completion:(QBChatCompletionBlock)completion {
    
    @weakify(self);
    [[[self.chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:kDialogsUpdateNotificationMessage] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        //
        if (task.isFaulted) {
            if (completion) completion(task.error);
            return nil;
        } else {
            @strongify(self);
            return [self.chatService deleteDialogWithID:chatDialog.ID];
        }
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        //
        if (completion) completion(task.error);
        return nil;
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
