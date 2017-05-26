//
//  QMMediaDownloadService.m
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/7/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import "QMMediaDownloadServiceDelegate.h"
#import "QMMediaDownloadService.h"

#import "QMMediaBlocks.h"
#import "QMSLog.h"
#import "QMMediaError.h"
#import "QMAsynchronousOperation.h"

@interface QMMediaDownloadService()

@property (strong, nonatomic) NSOperationQueue *downloadOperationQueue;
@property (strong, nonatomic) NSMutableDictionary *downloads;

@end

@implementation QMMediaDownloadService

- (instancetype)init {
    
    if (self  = [super init]) {
        
        self.downloadOperationQueue = [NSOperationQueue new];
        self.downloadOperationQueue.maxConcurrentOperationCount = 5;
        self.downloads = [NSMutableDictionary dictionary];
    
    }
    
    return self;
}

- (void)dealloc {
    
    [self cancellAllDownloads];
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}



- (void)downloadDataForAttachment:(QBChatAttachment *)attachment
              withCompletionBlock:(QMAttachmentDataCompletionBlock)completionBlock
                    progressBlock:(QMMediaProgressBlock)progressBlock {
    
    NSString *attachmentID = attachment.ID;
    
    if (self.downloads[attachmentID]) {
        return;
    }
    
    QMAsynchronousOperation *operation =
    [QMAsynchronousOperation asynchronousOperationWithID:attachmentID
                                                   queue:self.downloadOperationQueue];
    
    __weak typeof(QMAsynchronousOperation) *weakOperation = operation;
    
    operation.operationBlock = ^{
        
        QBRequest *request =
        [QBRequest downloadFileWithUID:attachmentID
                          successBlock:^(QBResponse *response, NSData *fileData)
         {
             
             if (fileData) {
                 completionBlock(attachmentID, fileData, nil);
             }
             [weakOperation complete];
             
         } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
             
             progressBlock(status.percentOfCompletion);
             
         } errorBlock:^(QBResponse *response) {
             
             QMMediaError *error = [QMMediaError errorWithResponse:response];
             completionBlock(attachmentID, nil, error);
             
             [weakOperation complete];
         }];
        
        @synchronized (self.downloads) {
            self.downloads[attachmentID] = request;
        }
    };
    
    operation.completionBlock = ^{
        
        @synchronized (self.downloads) {
            [self.downloads removeObjectForKey:attachmentID];
        }
    };
    
    operation.cancellBlock = ^{
        
        QBRequest *request = self.downloads[attachmentID];
        [request cancel];
        
        @synchronized (self.downloads) {
            [self.downloads removeObjectForKey:attachmentID];
        }
        
    };
    
    [self.downloadOperationQueue addOperation:operation];
}

- (void)cancellAllDownloads {
    [QMAsynchronousOperation cancelAllOperationsForQueue:self.downloadOperationQueue];
}

- (void)cancelDownloadOperationForAttachment:(QBChatAttachment *)attachment {
    [QMAsynchronousOperation cancelOperationWithID:attachment.ID
                                             queue:self.downloadOperationQueue];
}

@end
