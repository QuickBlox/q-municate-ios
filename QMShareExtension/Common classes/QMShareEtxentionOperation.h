//
//  QMMessageMediator.h
//  Q-municate
//
//  Created by Injoit on 11/2/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <Quickblox/Quickblox.h>
#import "QMChatTypes.h"
#import "QMMediaBlocks.h"
#import "QMAsynchronousOperation.h"

@class QBChatAttachment;
@class QBUUser;
@class QMShareEtxentionOperation;

@protocol QMShareItemProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface QMRecipientOperationResultDetails : NSObject

@property (nonatomic, strong, readonly) NSSet *sentRecipients;
@property (nonatomic, strong, readonly) NSDictionary <id, NSError *> *unsentRecipients;

@end

typedef void(^QMShareOperationCompletionBlock)(BOOL completed, QMRecipientOperationResultDetails *resultDetails);

@protocol QMShareEtxentionOperationDelegate <NSObject>

@required
- (BFTask <QBChatDialog *> *)taskForOperation:(QMShareEtxentionOperation *)operation
                                dialogForUser:(QBUUser *)user;

- (BFTask *)taskForOperation:(QMShareEtxentionOperation *)operation
                 sendMessage:(QBChatMessage *)message;

@optional

- (BFTask <QBChatAttachment*> *)customTaskForOperation:(QMShareEtxentionOperation *)operation
                                      uploadAttachment:(QBChatAttachment *)attachment
                                         progressBlock:(QMAttachmentProgressBlock)progressBlock
                                     cancellationToken:(BFCancellationToken *)token;

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
