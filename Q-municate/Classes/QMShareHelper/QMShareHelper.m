//
//  QMShareHelper.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/10/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareHelper.h"
#import "QMMessagesHelper.h"
#import "QMCore.h"
#import <QMChatViewController/QMImageLoader.h>


@interface QMShareHelper() <QMShareEtxentionOperationDelegate>

@property (nonatomic, weak) QMShareEtxentionOperation *shareOperation;
@property (nonatomic, strong) NSMutableArray *sendingMessages;

@end

@implementation QMShareHelper

- (void)forwardMessage:(QBChatMessage *)messageToForward
          toRecipients:(NSArray *)recipients
   withCompletionBlock:(QMShareOperationCompletionBlock)completionBlock {
    
    _sendingMessages = [NSMutableArray array];
    
    QBChatAttachment *attachment = messageToForward.attachments.firstObject;
    
    if (messageToForward.isImageAttachment) {
        attachment.image = [QMImageLoader.instance originalImageWithURL:[attachment remoteURLWithToken:NO]];
    }
    else if (messageToForward.isAudioAttachment) {
        
        NSURL *fileURL = [QMCore.instance.chatService.chatAttachmentService.storeService
                          fileURLForAttachment:attachment
                          messageID:messageToForward.ID
                          dialogID:messageToForward.dialogID];
        
        attachment.localFileURL = fileURL;
    }
    
    QMShareEtxentionOperation *operation =
    [QMShareEtxentionOperation operationWithID:messageToForward.ID
                                          text:messageToForward.text
                                    attachment:attachment
                                    recipients:recipients
                                    completion:completionBlock];
    
    __weak typeof(self) weakSelf = self;
    operation.cancelBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSArray *messages = strongSelf.sendingMessages.copy;
        for (QBChatMessage *message in messages) {
            [QMCore.instance.chatService.chatAttachmentService cancelOperationsWithMessageID:message.ID];
            [QMCore.instance.chatService deleteMessageLocally:message];
        }
    };
    
    operation.operationDelegate = self;
    
    [NSOperationQueue.mainQueue addOperation:operation];
    self.shareOperation = operation;
}

- (void)cancelForwarding {
    [self.shareOperation cancel];
}

//MARK: - QMShareEtxentionOperationDelegate

- (BFTask <QBChatDialog *> *)taskForOperation:(QMShareEtxentionOperation *)__unused operation
                                dialogForUser:(QBUUser *)user {
    QBChatDialog *privateDialog = [QMCore.instance.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
    if (privateDialog) {
        return [BFTask taskWithResult:privateDialog];
    }
    return [[QMCore.instance.chatService createPrivateChatDialogWithOpponent:user] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
        return [BFTask taskWithResult:t.result];
    }];
}


- (BFTask *)taskForOperation:(QMShareEtxentionOperation *)__unused operation
                 sendMessage:(QBChatMessage *)message {
    
    [self.sendingMessages addObject:message];
    
    BFContinuationBlock completionBlock =  ^id _Nullable(BFTask *task) {
        //Don't save forwarded message to deferred queue
        if (task.error) {
            [QMCore.instance.chatService.deferredQueueManager removeMessage:message];
        }
        return task;
    };
    
    if (message.attachments.count > 0 && !message.isLocationMessage) {
        QBChatAttachment *attachment = message.attachments.firstObject;
        
        QBChatDialog *dialog = [QMCore.instance.chatService.dialogsMemoryStorage chatDialogWithID:message.dialogID];
        return [[QMCore.instance.chatService sendAttachmentMessage:message
                                                          toDialog:dialog
                                                    withAttachment:attachment] continueWithBlock:completionBlock];
    }
    else {
        return [[QMCore.instance.chatService sendMessage:message
                                              toDialogID:message.dialogID
                                           saveToHistory:YES
                                           saveToStorage:YES] continueWithBlock:completionBlock];
    }
}

@end
