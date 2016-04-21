//
//  QMChatManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChatManager.h"
#import "QMCore.h"

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
        self.serviceManager.lastActivityDate = [NSDate date];
        
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

- (BFTask *)addUsers:(NSArray *)users toGroupChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type == QBChatDialogTypeGroup, @"Chat dialog must be group type!");
    
    NSArray *userIDs = [self.serviceManager.contactManager idsOfUsers:users];
    
    @weakify(self);
    return [[self.serviceManager.chatService joinOccupantsWithIDs:userIDs toChatDialog:chatDialog] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        @strongify(self);
        QBChatDialog *updatedDialog = task.result;
        [[self.serviceManager.chatService sendSystemMessageAboutAddingToDialog:updatedDialog toUsersIDs:userIDs] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused systemNotificationTask) {
            
            return [self.serviceManager.chatService sendNotificationMessageAboutAddingOccupants:userIDs toDialog:updatedDialog withNotificationText:kQMDialogsUpdateNotificationMessage];
        }];
        
        return nil;
    }];
}

- (BFTask *)leaveChatDialog:(QBChatDialog *)chatDialog {
    NSAssert(chatDialog.type != QBChatDialogTypePrivate, @"Dialog type must be group!");
    
    @weakify(self);
    return [[self.serviceManager.chatService sendNotificationMessageAboutLeavingDialog:chatDialog withNotificationText:kQMDialogsUpdateNotificationMessage] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        return [self.serviceManager.chatService deleteDialogWithID:chatDialog.ID];
    }];
}

@end
