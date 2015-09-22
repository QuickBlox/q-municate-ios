//
//  QMContentService.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMContentOperation.h"

@interface QMContentService : NSObject

- (void)uploadJPEGImage:(UIImage *)image progress:(QMContentProgressBlock)progress completion:(QMCFileUploadResponseBlock)completion;
- (void)uploadPNGImage:(UIImage *)image progress:(QMContentProgressBlock)progress completion:(QMCFileUploadResponseBlock)completion;

- (void)downloadFileWithUrl:(NSURL *)url completion:(void(^)(NSData *data))completion;
- (void)downloadFileWithBlobID:(NSUInteger )blobID progress:(QMContentProgressBlock)progress completion:(QMCFileDownloadResponseBlock)completion;

@end
