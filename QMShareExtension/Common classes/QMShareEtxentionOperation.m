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
@property (nonatomic, strong) QBRequest *currentRequest;

@end


@implementation QMShareEtxentionOperation

+ (QMShareEtxentionOperation *)operationWithID:(NSString *)ID
                                          text:(NSString *)text
                                    attachment:(QBChatAttachment * _Nullable )attachment
                                    recipients:(NSArray *)recipients
                                    completion:(QMShareOperationCompletionBlock)shareOperationCompletionBlock {
    
    QMShareEtxentionOperation *operation = [[QMShareEtxentionOperation alloc] init];
    
    if (operation) {
        operation.operationID = ID;
        operation.recipients = recipients;
        operation.text = [text copy];
        operation.attachment = attachment;
        operation.shareOperationCompletionBlock = [shareOperationCompletionBlock copy];
    }
    
    return operation;
}

- (instancetype)init {
    
    if (self = [super init]) {
        return self;
    }
    return nil;
}

- (void)cancel {
    
    [self.currentRequest cancel];
    [super cancel];
}

- (void)start {
    
    [[self sendTextToRecipients:self.text withAttachment:self.attachment] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (self.isCancelled) {
            self.shareOperationCompletionBlock(nil, NO);
        }
        else {
            self.shareOperationCompletionBlock(t.error, YES);
        }
        return nil;
    }];
}

- (BFTask *)sendTextToRecipients:(NSString *)text
                  withAttachment:(QBChatAttachment *)attachment {
    if (self.isCancelled) {
        return [BFTask cancelledTask];
    }
    NSArray *itemsToShare = self.recipients;
    
    BFTask *task = [BFTask taskWithResult:nil];
    for (id <QMShareItemProtocol> shareItem in itemsToShare) {
        QBChatMessage *message = [QBChatMessage new];
        message.text = text;
        if (attachment) {
            message.attachments = @[attachment];
        }
        // For each item, extend the task with a function to delete the item.
        task = [task continueWithBlock:^id(BFTask __unused *t) {
            if (self.isCancelled) {
                return [BFTask cancelledTask];
            }
            return [self shareTaskWithMessage:message shareItem:shareItem];
        }];
    }
    
    return task;
}

- (BFTask *)shareTaskWithMessage:(QBChatMessage *)message
                       shareItem:(id<QMShareItemProtocol>)shareItem {
    if (self.isCancelled) {
        NSLog(@"if (self.isCancelled) ");
    }
    return [[self dialogIDForShareItem:shareItem] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull dialogTask) {
        NSLog(@"dialogTask = %@", dialogTask);
        NSString *dialogID = dialogTask.result;
        NSUInteger senderID = QBSession.currentSession.currentUser.ID;
        message.senderID = senderID;
        message.markable = YES;
        message.deliveredIDs = @[@(senderID)];
        message.readIDs = @[@(senderID)];
        message.dialogID = dialogID;
        message.dateSent = [NSDate date];
        
        return [self sendMessage:message];
    }];
}

//MARK: - Helpers
- (BOOL)isSending {
    return self.isExecuting;
}
static inline NSData * __nullable imageData(UIImage * __nonnull image) {
    
    int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    
    if (hasAlpha) {
        return UIImagePNGRepresentation(image);
    }
    else {
        return UIImageJPEGRepresentation(image, 1.0f);
    }
}

- (BFTask *)sendMessage:(QBChatMessage *)message {
    
    if (message.attachments > 0 && !message.isLocationMessage) {
        QBChatAttachment *attachment = message.attachments.firstObject;
        
        return [[self uploadAttachment:attachment] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatAttachment *> * _Nonnull t) {
            NSLog(@"Upload Task: %@",t);
            message.attachments = @[t.result];
            return [self taskRestSendMessage:message];
        }];
    }
    else {
        return [self taskRestSendMessage:message];
    }
}

- (BFTask *)taskRestSendMessage:(QBChatMessage *)message {
    
    if (self.isCancelled) {
        NSLog(@"Cancelled task");
        return [BFTask cancelledTask];
    }
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        NSLog(@"taskRestSendMessage Task");
        self.currentRequest = [QBRequest sendMessage:message
                                        successBlock:^(QBResponse * _Nonnull __unused response, QBChatMessage * _Nonnull __unused tMessage) {
                                            [source setResult:tMessage];
                                        }
                                          errorBlock:^(QBResponse * _Nonnull response) {
                                              [source setError:response.error.error];
                                          }];
    });
}

- (BFTask <QBChatAttachment *> *)uploadAttachment:(QBChatAttachment *)attatchment {
    
    if (self.isCancelled) {
        NSLog(@"Cancelled task");
        return [BFTask cancelledTask];
    }
    NSData *dataToSend = ^NSData *{
        
        if (attatchment.attachmentType == QMAttachmentContentTypeImage) {
            return imageData(attatchment.image);
        }
        
        return nil;
        
    }();
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        if (dataToSend) {
            self.currentRequest = [QBRequest TUploadFile:dataToSend
                                                 fileName:attatchment.name
                                              contentType:attatchment.contentType
                                                 isPublic:NO
                                             successBlock:^(QBResponse * __unused  _Nonnull response,
                                                            QBCBlob * _Nonnull tBlob)
                                    {
                                        attatchment.ID = tBlob.UID;
                                        [source setResult:attatchment];
                                    }
                                              statusBlock:nil
                                    
                                               errorBlock:^(QBResponse * _Nonnull response)
                                    {
                                        [source setError:response.error.error];
                                    }];
        }
        else if (attatchment.localFileURL) {
            self.currentRequest = [QBRequest uploadFileWithUrl:attatchment.localFileURL
                                                      fileName:attatchment.name
                                                   contentType:attatchment.contentType
                                                      isPublic:NO
                                                  successBlock:^(QBResponse * _Nonnull __unused response,
                                                                 QBCBlob * _Nonnull tBlob)
                                   {
                                       attatchment.ID = tBlob.UID;
                                       [source setResult:attatchment];
                                   }
                                                   statusBlock:nil
                                                    errorBlock:^(QBResponse * _Nonnull response)
                                   {
                                       [source setError:response.error.error];
                                   }];
        }
    });
}

- (BFTask <NSString *> *)dialogIDForUser:(QBUUser *)user {
    return [self.operationDelegate dialogIDForUser:user];
}

- (BFTask <NSString *>*)dialogIDForShareItem:(id <QMShareItemProtocol>)shareItem {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        if ([shareItem isKindOfClass:QBChatDialog.class]) {
            [source setResult:((QBChatDialog *)shareItem).ID];
        }
        else {
            [[self dialogIDForUser:(QBUUser *)shareItem] continueWithBlock:^id _Nullable(BFTask<NSString *> * _Nonnull t) {
                t.error ? [source setError:t.error] : [source setResult:t.result];
                return nil;
            }];
        }
    });
}

@end
