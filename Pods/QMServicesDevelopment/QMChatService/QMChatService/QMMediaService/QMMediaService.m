//
//  QMMediaService.m
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/8/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import "QMMediaService.h"
#import "QMChatService.h"
#import "QMMediaError.h"
#import "QMSLog.h"
#import "QMMediaInfoService.h"
#import "QBChatMessage+QMCustomParameters.h"
#import "QBChatAttachment+QMCustomParameters.h"
#import "QBChatAttachment+QMFactory.h"

@interface QMMediaService()

@property (strong, nonatomic) NSMutableDictionary *placeholderAttachments;
@property (strong, nonatomic) NSMutableArray *mediaItemsInProgress;

@end

@implementation QMMediaService

@synthesize storeService = _storeService;
@synthesize downloadService = _downloadService;
@synthesize uploadService = _uploadService;
@synthesize mediaInfoService = _mediaInfoService;

//MARK: - NSObject

- (instancetype)init {
    
    if (self = [super init]) {
        
        _mediaItemsInProgress = [NSMutableArray array];
        _placeholderAttachments = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

//MARK: - QMMediaServiceDelegate

- (void)cancelOperationsForAttachment:(QBChatAttachment *)attachment {
    
    [self.mediaInfoService cancelInfoOperationForKey:attachment.ID];
}

- (QBChatAttachment *)placeholderAttachment:(NSString *)messageID {
    
    return _placeholderAttachments[messageID];
}


-(BOOL)attachmentIsReadyToPlay:(QBChatAttachment *)attachment
                       message:(QBChatMessage *)message {
    
    if ([_mediaItemsInProgress containsObject:attachment.ID]) {
        return  NO;
    }
    
    if (attachment.contentType == QMAttachmentContentTypeAudio) {
        
        NSURL *fileURL = [self.storeService fileURLForAttachment:attachment
                                                       messageID:message.ID
                                                        dialogID:message.dialogID];
        return fileURL != nil;
    }
    else if (attachment.contentType == QMAttachmentContentTypeVideo) {
        
        return YES;
    }
    return NO;
}

- (QBChatAttachment *)cachedAttachmentWithID:(NSString *)attachmentID
                                forMessageID:(NSString *)messageID {
    
    if ([self.mediaItemsInProgress containsObject:attachmentID]) {
        return  nil;
    }
    
    return [self.storeService cachedAttachmentWithID:attachmentID
                                        forMessageID:messageID];
}
- (void)statusForAttachment:(QBChatAttachment *)attachment
                 completion:(void(^)(int))completionBlock {
    
}
//MARK: Sending message

- (void)sendMessage:(QBChatMessage *)message
           toDialog:(QBChatDialog *)dialog
    withChatService:(QMChatService *)chatService
     withAttachment:(QBChatAttachment *)attachment
         completion:(QBChatCompletionBlock)completion {
    
    message.attachments = @[attachment];
    
    _placeholderAttachments[message.ID] = attachment;
    
    [self changeMessageAttachmentStatus:QMMessageAttachmentStatusLoading
                             forMessage:message];
    
    __weak typeof(self) weakSelf = self;
    
    void(^completionBlock)(NSError *error) = ^(NSError *error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            
            [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusError
                                           forMessage:message];
            
            completion(error);
            return;
        }
        
        message.text =
        [NSString stringWithFormat:@"%@ attachment",
         [[attachment stringContentType] capitalizedString]];
        
        [strongSelf.storeService saveAttachment:attachment
                                      cacheType:QMAttachmentCacheTypeDisc|QMAttachmentCacheTypeMemory
                                      messageID:message.ID
                                       dialogID:dialog.ID];
        
        [strongSelf changeMessageAttachmentStatus:QMMessageAttachmentStatusLoaded
                                       forMessage:message];
        
        message.attachments = @[attachment];
        
        [chatService sendMessage:message
                        toDialog:dialog
                   saveToHistory:YES
                   saveToStorage:YES
                      completion:completion];
    };
    
    void(^progressBlock)(float progress) = ^(float progress) {
        
        [self changeMessageUploadingProgress:progress
                                  forMessage:message];
    };
    
    if (attachment.localFileURL) {
        
        [self.uploadService uploadAttachment:attachment
                                 withFileURL:attachment.localFileURL
                         withCompletionBlock:completionBlock
                               progressBlock:progressBlock];
    }
    
    else if (attachment.contentType == QMAttachmentContentTypeImage) {
        
        [self.uploadService uploadAttachment:attachment
                                    withData:UIImagePNGRepresentation(attachment.image)
                         withCompletionBlock:completionBlock
                               progressBlock:progressBlock];
    }
}

- (void)changeMessageAttachmentStatus:(QMMessageAttachmentStatus)status
                           forMessage:(QBChatMessage *)message {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.onMessageDidChangeAttachmentStatus) {
            self.onMessageDidChangeAttachmentStatus(status, message);
        }
        
    });
    
}

- (void)changeMessageUploadingProgress:(float)progress
                            forMessage:(QBChatMessage *)message {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.onMessageDidChangeUploadingProgress) {
            self.onMessageDidChangeUploadingProgress(progress, message);
        }
    });
}


- (void)changeDownloadingProgress:(float)progress
                       forMessage:(QBChatMessage *)message
                       attachment:(QBChatAttachment *)attachment {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.onMessageDidChangeDownloadingProgress) {
            self.onMessageDidChangeDownloadingProgress(progress, message, attachment);
        }
    });
}


- (void)audioDataForAttachment:(QBChatAttachment *)attachment
                       message:(QBChatMessage *)message
                    completion:(void(^)(BOOL isReady, NSError *error))completion {
    
    if ([self cachedAttachmentWithID:attachment.ID
                        forMessageID:message.ID]) {
        
        completion(YES, nil);
        return;
    }
    
    NSURL *localFileURL = [self.storeService fileURLForAttachment:attachment
                                                        messageID:message.ID
                                                         dialogID:message.dialogID];
    if (localFileURL) {
        attachment.localFileURL = localFileURL;
        completion(YES, nil);
        return;
    }
    else {
        __weak typeof(self) weakSelf = self;
        
        [self.downloadService downloadDataForAttachment:attachment
                                    withCompletionBlock:^(NSString *attachmentID,
                                                          NSData *data,
                                                          QMMediaError *error)
         {
             __strong typeof(weakSelf) strongSelf = weakSelf;
             
             if (data) {
                 [strongSelf.storeService saveData:data
                                     forAttachment:attachment
                                         cacheType:QMAttachmentCacheTypeMemory | QMAttachmentCacheTypeDisc
                                         messageID:message.ID
                                          dialogID:message.dialogID];
                 
                 completion(YES,nil);
             }
             else {
                 completion(NO, error.error);
             }
         } progressBlock:^(float progress) {
             
             [weakSelf changeDownloadingProgress:progress
                                      forMessage:message
                                      attachment:attachment];
         }];
        
    }
}

- (void)imageForAttachment:(QBChatAttachment *)attachment
                   message:(QBChatMessage *)message
                completion:(void(^)(UIImage *image, NSError *error))completion {
    
    __weak typeof(self) weakSelf = self;
    
    [self.storeService cachedImageForAttachment:attachment
                                     messageID:message.ID
                                      dialogID:message.dialogID
                                    completion:^(UIImage *image)
     {
         
         if (!image) {
             
             if (attachment.status == QMAttachmentStatusLoading ||
                 attachment.status == QMAttachmentStatusError) {
                 return;
             }
             
             QMAttachmentCacheType cacheType = QMAttachmentCacheTypeMemory|QMAttachmentCacheTypeDisc;
             
             if (attachment.contentType == QMAttachmentContentTypeImage) {
                 
                 attachment.status = QMAttachmentStatusLoading;
                 __strong typeof(weakSelf) strongSelf = weakSelf;
                 [strongSelf.downloadService downloadDataForAttachment:attachment
                                                   withCompletionBlock:^(NSString *attachmentID,
                                                                         NSData *data,
                                                                         QMMediaError *error) {
                                                       if (data) {
                                                           [strongSelf.storeService saveData:data
                                                                               forAttachment:attachment
                                                                                   cacheType:cacheType
                                                                                   messageID:message.ID
                                                                                    dialogID:message.dialogID];
                                                           
                                                           completion([UIImage imageWithData:data], nil);
                                                           attachment.status = QMAttachmentStatusLoaded;
                                                       }
                                                       else {
                                                           attachment.status = QMAttachmentStatusError;
                                                           completion(nil, error.error);
                                                       }
                                                   } progressBlock:^(float progress) {
                                                       
                                                       [self changeDownloadingProgress:progress
                                                                            forMessage:message
                                                                            attachment:attachment];
                                                   }];
             }
             else if (attachment.contentType == QMAttachmentContentTypeVideo) {
                 
                 if (attachment.status == QMAttachmentStatusPreparing ||
                     attachment.status == QMAttachmentStatusError) {
                     return;
                 }
                 __strong typeof(weakSelf) strongSelf = weakSelf;
                 attachment.status = QMAttachmentStatusPreparing;
                 [strongSelf.mediaInfoService videoThumbnailForAttachment:attachment
                                                               completion:^(UIImage *image, NSError *error)
                  {
                     
                          
                          if (image) {
                              [strongSelf.storeService saveData:UIImagePNGRepresentation(image)
                                                  forAttachment:attachment
                                                      cacheType:cacheType
                                                      messageID:message.ID
                                                       dialogID:message.dialogID];
                              attachment.status = QMAttachmentStatusPrepared;
                          }
                          else {
                              attachment.status = QMAttachmentStatusError;
                          }
                          
                          completion(image, error);
    
                  }];
             }
         }
         else {
             if (completion) {
                 completion(image, nil);
             }
         }
     }];
}

@end
