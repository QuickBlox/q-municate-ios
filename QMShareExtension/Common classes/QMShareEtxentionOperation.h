//
//  QMMessageMediator.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/2/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <QMServicesDevelopment/QMServices.h>
#import <QMServicesDevelopment/QMChatTypes.h>
#import <QMServicesDevelopment/QMMediaBlocks.h>

@class QBChatAttachment;
@class QBUUser;
@class QMShareEtxentionOperation;

@protocol QMShareItemProtocol;

NS_ASSUME_NONNULL_BEGIN
typedef void(^QMShareOperationCompletionBlock)(NSError *_Nullable error, BOOL completed);

@protocol QMShareEtxentionOperationDelegate <NSObject>

@required
- (BFTask <QBChatDialog *> *)taskForOperation:(QMShareEtxentionOperation *)operation
                                dialogForUser:(QBUUser *)user;

- (BFTask *)taskForOperation:(QMShareEtxentionOperation *)operation
                 sendMessage:(QBChatMessage *)message;

@optional

- (BFTask <QBChatAttachment*> *)customTaskForOperation:(QMShareEtxentionOperation *)operation
                                     uploadAttachment:(QBChatAttachment *)attachment
                                        progressBlock:(QMAttachmentProgressBlock)progressBlock;

- (BFTask <NSURL *>*)customTaskForOperation:(QMShareEtxentionOperation *)operation
                             saveAttachment:(QBChatAttachment *)attachment
                                  cacheType:(QMAttachmentCacheType)cacheType;

- (BFTask <QBChatAttachment*> *)customTaskForOperation:(QMShareEtxentionOperation *)operation
                                    downloadAttachment:(QBChatAttachment *)attachment
                                         progressBlock:(QMAttachmentProgressBlock)progressBlock;

- (BOOL)operation:(QMShareEtxentionOperation *)operation
shouldUploadAttachment:(QBChatAttachment *)attachment
 forMessageWithID:(NSString *)messageID;

@end

@interface QMShareEtxentionOperation : QMAsynchronousOperation


+ (QMShareEtxentionOperation *)operationWithID:(NSString *)ID
                                          text:(NSString *)text
                                    attachment:(QBChatAttachment * _Nullable )attachment
                                    recipients:(NSArray *)recipients
                                    completion:(QMShareOperationCompletionBlock)shareOperationCompletionBlock;

@property (nonatomic, assign, readonly) BOOL isSending;

@property (nonatomic, weak) id <QMShareEtxentionOperationDelegate> operationDelegate;
@property (nonatomic, strong, readonly) NSArray <id<QMShareItemProtocol>> *recipients;
@property (nonatomic, copy, readonly, nullable) QMAttachmentProgressBlock progressBlock;

@end

NS_ASSUME_NONNULL_END
