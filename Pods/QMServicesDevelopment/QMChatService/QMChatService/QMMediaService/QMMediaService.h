//
//  QMMediaService.h
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/8/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMMediaServiceDelegate.h"
#import "QMMediaStoreServiceDelegate.h"
#import "QMMediaDownloadServiceDelegate.h"
#import "QMMediaUploadServiceDelegate.h"

@class QMChatAttachmentService;
@protocol QMMediaServiceDelegate;

@interface QMMediaService : NSObject <QMMediaServiceDelegate>

@property (copy, nonatomic) QMAttachmentMessageStatusBlock onMessageDidChangeAttachmentStatus;
@property (copy, nonatomic) QMAttachmentMesssageUploadProgressBlock onMessageDidChangeUploadingProgress;
@property (copy, nonatomic) QMAttachmentDownloadProgressBlock onMessageDidChangeDownloadingProgress;
@property (copy, nonatomic) QMAttachmentMessageDidStartUploading onMessageDidStartUploading;

- (QBChatAttachment *)placeholderAttachment:(NSString *)messageID;

- (void)imageForAttachment:(QBChatAttachment *)attachment
                   message:(QBChatMessage *)message
                completion:(void(^)(UIImage *image, NSError *error))completion;

- (void)audioDataForAttachment:(QBChatAttachment *)attachment
                       message:(QBChatMessage *)message
                    completion:(void(^)(BOOL isReady, NSError *error))completion;

- (void)cancelOperationsForAttachment:(QBChatAttachment *)attachment;

@end

