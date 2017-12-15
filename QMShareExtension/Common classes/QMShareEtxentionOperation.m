//
//  QMMessageMediator.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/2/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareEtxentionOperation.h"
#import "QMShareItemProtocol.h"
#import <Bolts/Bolts.h>
#import <Quickblox/Quickblox.h>
#import <QMServices.h>



@interface QMShareEtxentionOperation()

@property (nonatomic, strong, readwrite) NSArray *recipients;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) QBChatAttachment *attachment;
@property (nonatomic, copy) QMShareOperationCompletionBlock shareOperationCompletionBlock;

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
    operation.shareOperationCompletionBlock = [shareOperationCompletionBlock copy];
    
    return operation;
}

- (void)asyncTask {
    
    [[self taskSendTextToRecipients] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (self.isCancelled) {
            self.shareOperationCompletionBlock(nil, NO);
        }
        else {
            [self finish];
            self.shareOperationCompletionBlock(t.error, YES);
        }
        return nil;
    }];
}

- (void)dealloc {
    NSLog(@"Deallock = %@",self.operationID);
}

- (BFTask *)taskSendTextToRecipients {
    
    if (self.isCancelled) {
        return [BFTask cancelledTask];
    }
    
    NSArray *itemsToShare = self.recipients;
    
    BFTask *task = [BFTask taskWithResult:nil];
    
    for (id <QMShareItemProtocol> shareItem in itemsToShare) {
        
        // For each item, extend the task with a function to share with the item.
        task = [task continueWithBlock:^id(BFTask __unused *t) {
            if (self.isCancelled) {
                return [BFTask cancelledTask];
            }
            return [self taskSendMessageToRecipient:shareItem];
        }];
    }
    
    return task;
}

- (BFTask <QBChatMessage *> *)taskMessageForRecipient:(id<QMShareItemProtocol>)recipient {
    
    if (self.isCancelled) {
        return [BFTask cancelledTask];
    }
    
    return [[self dialogForShareItem:recipient] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull dialogTask) {
        
        if (self.isCancelled) {
            return [BFTask cancelledTask];
        }
        
        QBChatMessage *message = [QBChatMessage new];
        message.text = self.text;
        
        BFTask *(^sucessBlock)(QBChatMessage *message,
                               QBChatAttachment *attachment) =
        ^(QBChatMessage *msg, QBChatAttachment *att) {
            NSLog(@"dialogTask = %@", dialogTask);
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
            return  [[self taskUploadAttachment:self.attachment] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatAttachment *> * _Nonnull t) {
                if (self.isCancelled) {
                    return [BFTask cancelledTask];
                }
                return sucessBlock(message, t.result);
            }];
        }
        
        return sucessBlock(message,nil);
    }];
}


- (BFTask <QBChatAttachment *>*)taskUploadAttachment:(QBChatAttachment *)attachment {
    
    if (self.isCancelled) {
        return [BFTask cancelledTask];
    }
    
    if ([self.operationDelegate respondsToSelector:@selector(customTaskForOperation:
                                                             uploadAttachment:
                                                             progressBlock:)]) {
        return [self.operationDelegate customTaskForOperation:self
                                             uploadAttachment:attachment
                                                progressBlock:self.progressBlock];
    }
    
    return [BFTask taskWithResult:attachment];
}



- (BFTask *)taskSendMessageToRecipient:(id<QMShareItemProtocol>)recipient {
    
    if (self.isCancelled) {
        NSLog(@"if (self.isCancelled) ");
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
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        if ([shareItem isKindOfClass:QBChatDialog.self]) {
            [source setResult:((QBChatDialog *)shareItem)];
        }
        else {
            [[self dialogForUser:(QBUUser *)shareItem] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
                t.error ? [source setError:t.error] : [source setResult:t.result];
                return nil;
            }];
        }
    });
}

@end
