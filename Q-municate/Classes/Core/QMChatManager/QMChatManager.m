//
//  QMChatManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatManager.h"
#import "QMCore.h"
#import "QMContent.h"
#import "QMChatLocationSnapshotter.h"

@interface QMChatManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;

@property (readwrite, strong, nonatomic) QMChatLocationSnapshotter *chatLocationSnapshotter;

@end

@implementation QMChatManager

@dynamic serviceManager;

#pragma mark - Chat Connection

- (BFTask *)disconnectFromChat {
    @weakify(self);
    return [[self.serviceManager.chatService disconnect] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        if (self.serviceManager.currentProfile.userData != nil) {
            
            self.serviceManager.currentProfile.lastDialogsFetchingDate = [NSDate date];
            [self.serviceManager.currentProfile synchronize];
        }
        
        return nil;
    }];
}

- (BFTask *)disconnectFromChatIfNeeded {
    
    BOOL chatNeedDisconnect =  [[QBChat instance] isConnected] || [[QBChat instance] isConnecting];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground && !self.serviceManager.callManager.hasActiveCall && chatNeedDisconnect) {
        
        return [self disconnectFromChat];
    }
    
    return nil;
}

#pragma mark - Notifications

- (BFTask *)addUsers:(NSArray *)users toGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Chat dialog must be group type!");
    
    NSArray *userIDs = [self.serviceManager.contactManager idsOfUsers:users];
    
    @weakify(self);
    return [[self.serviceManager.chatService joinOccupantsWithIDs:userIDs toChatDialog:chatDialog] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        @strongify(self);
        QBChatDialog *updatedDialog = task.result;
        [[self.serviceManager.chatService sendSystemMessageAboutAddingToDialog:updatedDialog toUsersIDs:userIDs withText:kQMDialogsUpdateNotificationMessage] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused systemNotificationTask) {
            
            return [self.serviceManager.chatService sendNotificationMessageAboutAddingOccupants:userIDs toDialog:updatedDialog withNotificationText:kQMDialogsUpdateNotificationMessage];
        }];
        
        return nil;
    }];
}

- (BFTask *)changeAvatar:(UIImage *)avatar forGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Chat dialog must be group type!");
    
    @weakify(self);
    return [[[QMContent uploadPNGImage:avatar progress:nil] continueWithSuccessBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull task) {
        
        @strongify(self);
        NSString *url = task.result.isPublic ? [task.result publicUrl] : [task.result privateUrl];
        return [self.serviceManager.chatService changeDialogAvatar:url forChatDialog:chatDialog];
        
    }] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        @strongify(self);
        [self.serviceManager.chatService sendNotificationMessageAboutChangingDialogPhoto:task.result withNotificationText:kQMDialogsUpdateNotificationMessage];
        return nil;
    }];
}

- (BFTask *)changeName:(NSString *)name forGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Chat dialog must be group type!");
    
    @weakify(self);
    return [[self.serviceManager.chatService changeDialogName:name forChatDialog:chatDialog] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        @strongify(self);
        
        return [self.serviceManager.chatService sendNotificationMessageAboutChangingDialogName:task.result withNotificationText:kQMDialogsUpdateNotificationMessage];
    }];
}

- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Chat dialog must be group type!");
    
    @weakify(self);
    return [[self.serviceManager.chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:kQMDialogsUpdateNotificationMessage] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        return [self.serviceManager.chatService deleteDialogWithID:chatDialog.ID];
    }];
}

#pragma mark - Getters

- (QMChatLocationSnapshotter *)chatLocationSnapshotter {
    
    if (_chatLocationSnapshotter == nil) {
        // lazy loading location snapshotter f needed
        // due to for some users it will not be needed at all
        // for application life span
        _chatLocationSnapshotter = [[QMChatLocationSnapshotter alloc] init];
    }
    
    return _chatLocationSnapshotter;
}

@end
