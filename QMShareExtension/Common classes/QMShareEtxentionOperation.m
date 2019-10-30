//
//  QMMessageMediator.m
//  Q-municate
//
//  Created by Injoit on 11/2/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMShareEtxentionOperation.h"
#import "QMShareItemProtocol.h"
#import <Bolts/Bolts.h>
#import <Quickblox/Quickblox.h>
#import "QBChatMessage+QMCustomParameters.h"


@interface QMRecipientOperationResultDetails()

@property (nonatomic, strong) NSMutableSet *mutableSentRecipients;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSError *> *mutableUnsentRecipients;

@end

@implementation QMRecipientOperationResultDetails

- (instancetype)init {
    
    if (self  = [super init]) {
        _mutableUnsentRecipients = [NSMutableDictionary dictionary];
        _mutableSentRecipients = [NSMutableSet set];
    }
    return self;
}

- (NSDictionary<NSString *,NSError *> *)unsentRecipients {
    return _mutableUnsentRecipients.copy;
}

- (NSSet *)sentRecipients {
    return _mutableSentRecipients.copy;
}

- (NSString *)description {

    NSMutableString *desc = [NSMutableString stringWithString:[super description]];
    [desc appendFormat:@
     "\r   Sent:%@"
     "\r   Unsent: %@",
     _mutableSentRecipients,
     _mutableUnsentRecipients];

    return desc;
}

@end

@interface QMShareEtxentionOperation()

@property (nonatomic, strong, readwrite) NSArray *recipients;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) QBChatAttachment *attachment;
@property (nonatomic, copy) QMShareOperationCompletionBlock shareOperationCompletionBlock;
@property (nonatomic, strong) BFCancellationTokenSource *uploadAttachmentCancellationToken;

@end

@implementation QMShareEtxentionOperation

+ (QMShareEtxentionOperation *)operationWithID:(NSString *)ID
                                          text:(NSString *)text
                                    attachment:(QBChatAttachment * _Nullable )attachment
                                    recipients:(NSArray *)recipients
                                    completion:(QMShareOperationCompletionBlock)shareOperationCompletionBlock {
    
    QMShareEtxentionOperation *operation = [[QMShareEtxentionOperation alloc] init];
    
    operation.operationID = ID;
    operation.recipients = recipients;
    operation.text = text;
    operation.attachment = attachment;
    operation.shareOperationCompletionBlock = shareOperationCompletionBlock;

    return operation;
}

- (void)asyncTask {
  
    [[self taskSendTextToRecipients] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        
        if (self.isCancelled) {
            self.shareOperationCompletionBlock(NO, t.result);
        }
        else {
            [self finish];
            self.shareOperationCompletionBlock(YES, t.result);
        }
        
        self.shareOperationCompletionBlock = nil;
        
        return nil;
    }];
}

- (BFTask *)taskSendTextToRecipients {
    
    if (self.isCancelled) {
        return [BFTask cancelledTask];
    }
    
    NSArray *itemsToShare = self.recipients;
    
    QMRecipientOperationResultDetails *resultDetails = [[QMRecipientOperationResultDetails alloc] init];
    
    BFTask *task = [BFTask taskWithResult:nil];
    
    for (id <QMShareItemProtocol> shareItem in itemsToShare) {
        
        // For each item, extend the task with a function to share with the item.
        task = [task continueWithBlock:^id(BFTask  *t) {
            if (self.isCancelled) {
                return [BFTask cancelledTask];
            }
            
            return [[self taskSendMessageToRecipient:shareItem] continueWithBlock:^id _Nullable(BFTask * _Nonnull sendMessageTask) {
                
                if (sendMessageTask.error) {
                   resultDetails.mutableUnsentRecipients[shareItem] = sendMessageTask.error;
                }
                else {
                    [resultDetails.mutableSentRecipients addObject:shareItem];
                }
                
                return nil;
            }];
        }];
    }
    
    return [task continueWithBlock:^id _Nullable(BFTask * _Nonnull  t) {
        return  [BFTask taskWithResult:resultDetails];
    }];
}

- (void)cancel {
    
    [self.uploadAttachmentCancellationToken cancel];
    [super cancel];
}

- (BFTask <QBChatMessage *> *)taskMessageForRecipient:(id<QMShareItemProtocol>)recipient {
    
    if (self.isCancelled) {
        return [BFTask cancelledTask];
    }
    
    return [[self dialogForShareItem:recipient] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull dialogTask) {
        
        if (self.isCancelled) {
            return [BFTask cancelledTask];
        }
        
        QBChatMessage *message = [QBChatMessage new];
        message.text = self.text;
        
        BFTask *(^sucessBlock)(QBChatMessage *,
                               QBChatAttachment *) =
        ^(QBChatMessage *msg,
          QBChatAttachment *att) {

            if (att) {
                msg.attachments = @[att];
            }
            
            QBChatDialog *dialog = dialogTask.result;
            NSUInteger senderID = QBSession.currentSession.currentUser.ID;
            msg.senderID = senderID;
            msg.markable = YES;
            msg.deliveredIDs = @[@(senderID)];
            msg.readIDs = @[@(senderID)];
            msg.dialogID = dialog.ID;
            msg.dateSent = [NSDate date];
            msg.saveToHistory = @"1";
           
            return [BFTask taskWithResult:msg];
        };
        
        if (self.attachment) {
            if (self.attachment.ID) {
                return sucessBlock(message, self.attachment);
            }
            else {
                return [[self taskUploadAttachment:self.attachment] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatAttachment *> * _Nonnull t) {
                    if (self.isCancelled) {
                        return [BFTask cancelledTask];
                    }
                    
                    self.attachment.ID = t.result.ID;
                    return sucessBlock(message, t.result);
                }];
            }
        }
      
        return sucessBlock(message, nil);
    }];
}

- (BFTask <QBChatAttachment *>*)taskUploadAttachment:(QBChatAttachment *)attachment {
    
    if (self.isCancelled) {
        return [BFTask cancelledTask];
    }
    
    if ([self.operationDelegate respondsToSelector:@selector(customTaskForOperation:
                                                             uploadAttachment:
                                                             progressBlock:
                                                             cancellationToken:)]) {
        
        self.uploadAttachmentCancellationToken = [BFCancellationTokenSource cancellationTokenSource];
        
        return [self.operationDelegate customTaskForOperation:self
                                             uploadAttachment:attachment
                                                progressBlock:self.progressBlock
                                            cancellationToken:self.uploadAttachmentCancellationToken.token];
    }
    
    return [BFTask taskWithResult:attachment];
}


- (BFTask *)taskSendMessageToRecipient:(id<QMShareItemProtocol>)recipient {
    
    if (self.isCancelled) {
        return [BFTask cancelledTask];
    }
    
    return [[self taskMessageForRecipient:recipient] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatMessage *> * _Nonnull messageTask) {
        return [self sendMessage:messageTask.result];
    }];
}

//MARK: - Helpers
- (BOOL)isSending {
    return self.isExecuting;
}

- (BFTask *)sendMessage:(QBChatMessage *)message {
    
    if (self.isCancelled) {
        return [BFTask cancelledTask];
    }
    else {
        return [self.operationDelegate taskForOperation:self
                                            sendMessage:message];
    }
}

- (BFTask <QBChatDialog *> *)dialogForUser:(QBUUser *)user {
    return [self.operationDelegate taskForOperation:self
                                      dialogForUser:user];
}

- (BFTask <QBChatDialog *>*)dialogForShareItem:(id <QMShareItemProtocol>)shareItem {
    
    if ([shareItem isKindOfClass:QBChatDialog.self]) {
        return [BFTask taskWithResult:((QBChatDialog *)shareItem)];
    }
    else {
        return [self dialogForUser:(QBUUser *)shareItem];
    }
}

@end
