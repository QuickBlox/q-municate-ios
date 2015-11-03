//
//  QMContentService.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContentService.h"
#import "QMDownloadContentOperation.h"
#import "QMUploadContentOperation.h"

NSString *const kQMDefaultImageName = @"image";

@interface QMContentService()

@property(strong, nonatomic) NSOperationQueue *contentOperationQueue;

@end

@implementation QMContentService

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.contentOperationQueue = [[NSOperationQueue alloc] init];
        self.contentOperationQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

- (void)uploadJPEGImage:(UIImage *)image
               progress:(QMContentProgressBlock)progress
             completion:(QMCFileUploadResponseBlock)completion {
    
    NSData *data = UIImageJPEGRepresentation(image, 0.4);
    [self uploadData:data
            fileName:@"image"
         contentType:@"image/jpeg"
            isPublic:YES progress:progress
          completion:completion];
}

- (void)uploadPNGImage:(UIImage *)image
              progress:(QMContentProgressBlock)progress
            completion:(QMCFileUploadResponseBlock)completion {
    
    NSData *data = UIImagePNGRepresentation(image);
    [self uploadData:data fileName:@"image"
         contentType:@"image/png"
            isPublic:YES
            progress:progress
          completion:completion];
}

- (void)uploadData:(NSData *)data
          fileName:(NSString *)fileName
       contentType:(NSString *)contentType
          isPublic:(BOOL)isPublic
          progress:(QMContentProgressBlock)progress
        completion:(QMCFileUploadResponseBlock)completion {
    
    QMUploadContentOperation *uploadOperation =
    [[QMUploadContentOperation alloc] initWithUploadFile:data
                                                fileName:fileName
                                             contentType:contentType
                                                isPublic:isPublic];
    uploadOperation.progressHandler = progress;
    uploadOperation.completionHandler = completion;
    
    [self.contentOperationQueue addOperation:uploadOperation];
}

- (void)downloadFileWithBlobID:(NSUInteger )blobID
                      progress:(QMContentProgressBlock)progress
                    completion:(QMCFileDownloadResponseBlock)completion {
    
    QMDownloadContentOperation *downloadOperation =
    [[QMDownloadContentOperation alloc] initWithBlobID:blobID];
    
    downloadOperation.progressHandler = progress;
    downloadOperation.completionHandler = completion;
    
    [self.contentOperationQueue addOperation:downloadOperation];
}

- (void)downloadFileWithUrl:(NSURL *)url completion:(void(^)(NSData *data))completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(data);
        });
    });
}

@end

