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


@class QBChatAttachment;
@class QBUUser;
@protocol QMShareItemProtocol;

NS_ASSUME_NONNULL_BEGIN
typedef void(^QMShareOperationCompletionBlock)(NSError *_Nullable error, BOOL completed);

@protocol QMShareEtxentionOperationDelegate <NSObject>
- (BFTask <NSString *> *)dialogIDForUser:(QBUUser *)user;
@end

@interface QMShareEtxentionOperation : QMAsynchronousOperation


+ (QMShareEtxentionOperation *)operationWithID:(NSString *)ID
                                          text:(NSString *)text
                                    attachment:(QBChatAttachment * _Nullable )attachment
                                    recipients:(NSArray <id<QMShareItemProtocol>> *)recipients
                                    completion:(QMShareOperationCompletionBlock)completionBlock;

@property (assign, nonatomic, readonly) BOOL isSending;
@property (weak, nonatomic) id <QMShareEtxentionOperationDelegate> operationDelegate;
@property (strong, nonatomic, readonly) NSArray <id<QMShareItemProtocol>> *recipients;

@end

NS_ASSUME_NONNULL_END
