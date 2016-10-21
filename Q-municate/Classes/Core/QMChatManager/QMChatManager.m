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
#import "QMMessagesHelper.h"

@interface QMChatManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;

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

- (BFTask *)sendBackgroundMessageWithText:(NSString *)text toDialog:(QBChatDialog *)chatDialog {
    
    BFContinuationBlock joinBlock = ^id _Nullable(BFTask * _Nonnull t) {
        
        if (!t.isFaulted
            && chatDialog.type != QBChatDialogTypePrivate
            && !chatDialog.isJoined) {
            
            return [self.serviceManager.chatService joinToGroupDialog:chatDialog];
        }
        
        return nil;
    };
    
    BFContinuationBlock messageBlock = ^id _Nullable(BFTask * _Nonnull t) {
        
        if (!t.isFaulted) {
            
            NSUInteger currentUserID = [QMCore instance].currentProfile.userData.ID;
            
            QBChatMessage *message = [QMMessagesHelper chatMessageWithText:text
                                                                  senderID:currentUserID
                                                              chatDialogID:chatDialog.ID
                                                                  dateSent:[NSDate date]];
            
            return [[QMCore instance].chatService sendMessage:message toDialog:chatDialog saveToHistory:YES saveToStorage:YES];
        }
        
        return nil;
    };
    
    BFContinuationBlock disconnectBlock = ^id _Nullable(BFTask * _Nonnull __unused t) {
        
        [QMCore instance].chatService.enableAutoJoin = YES;
        
        BOOL isConnected = [QBChat instance].isConnected;
        BOOL hasNoActiveCall = !self.serviceManager.callManager.hasActiveCall;
        BOOL isNotActive = [UIApplication sharedApplication].applicationState != UIApplicationStateActive;
        
        if (isConnected
            && hasNoActiveCall
            && isNotActive) {
            
            return [[QMCore instance].chatService disconnect];
        }
        
        return nil;
    };
    
    if (![QBChat instance].isConnected) {
        
        [QMCore instance].chatService.enableAutoJoin = NO;
        
        return [[[[[QMCore instance].chatService connect]
                  continueWithBlock:joinBlock]
                 continueWithBlock:messageBlock]
                continueWithBlock:disconnectBlock];
    }
    
    return nil;
}

@end
