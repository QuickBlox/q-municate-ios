//
//  QMMediaUploadService.m
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/9/17.
//  Copyright © 2017 quickblox. All rights reserved.
//
#import <Quickblox/Quickblox.h>
#import "QMMediaUploadService.h"
#import "QMSLog.h"
#import "QBChatAttachment+QMCustomParameters.h"

@implementation QMMediaUploadService

//MARK: -NSObject
- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)uploadAttachment:(QBChatAttachment *)attachment
             withFileURL:(NSURL *)fileURL
     withCompletionBlock:(QMAttachmentUploadCompletionBlock)completionBlock
           progressBlock:(QMMediaProgressBlock)progressBlock {
    
    [QBRequest uploadFileWithUrl:fileURL
                        fileName:attachment.name
                     contentType:[attachment stringMIMEType]
                        isPublic:YES
                    successBlock:^(QBResponse * _Nonnull response, QBCBlob * _Nonnull tBlob) {
                        
                        attachment.ID = tBlob.UID;
                        attachment.size = tBlob.size;
                        
                        if (completionBlock) {
                            completionBlock(nil);
                        }
                        
                    } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nonnull status) {
                        progressBlock(status.percentOfCompletion);
                    } errorBlock:^(QBResponse * _Nonnull response) {
                        completionBlock(response.error.error);
                    }];
}


- (void)uploadAttachment:(QBChatAttachment *)attachment
                withData:(NSData *)data
     withCompletionBlock:(QMAttachmentUploadCompletionBlock)completionBlock
           progressBlock:(QMMediaProgressBlock)progressBlock {
    
    [QBRequest TUploadFile:data
                  fileName:attachment.name
               contentType:[attachment stringMIMEType]
                  isPublic:NO
              successBlock:^(QBResponse * _Nonnull response, QBCBlob * _Nonnull tBlob) {
                  
                  attachment.ID = tBlob.UID;
                  attachment.size = tBlob.size;
                  
                  if (completionBlock) {
                      completionBlock(nil);
                  }
              } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
                  
                  progressBlock(status.percentOfCompletion);
                  
              } errorBlock:^(QBResponse * _Nonnull response) {
                  
                  completionBlock(response.error.error);
              }];
}

@end
