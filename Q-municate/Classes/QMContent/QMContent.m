//
//  QMContent.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContent.h"

static const CGFloat kQMContentUploadJPEGCompressionQuality = 0.4f;
static NSString *const kQMContentImageFileName = @"image";

@implementation QMContent

#pragma mark - Upload operations

+ (BFTask *)uploadJPEGImage:(UIImage *)image
                   progress:(QMContentProgressBlock)progress
{
    
    NSData *data = UIImageJPEGRepresentation(image, kQMContentUploadJPEGCompressionQuality);
    return [self uploadData:data
                   fileName:kQMContentImageFileName
                contentType:@"image/jpeg"
                   isPublic:YES
                   progress:progress];
    
}

+ (BFTask *)uploadPNGImage:(UIImage *)image
                  progress:(QMContentProgressBlock)progress
{
    
    NSData *data = UIImagePNGRepresentation(image);
    return [self uploadData:data
                   fileName:kQMContentImageFileName
                contentType:@"image/png"
                   isPublic:YES
                   progress:progress];
}

+ (BFTask *)uploadData:(NSData *)data
              fileName:(NSString *)fileName
           contentType:(NSString *)contentType
              isPublic:(BOOL)isPublic
              progress:(QMContentProgressBlock)progress
{
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [QBRequest TUploadFile:data
                  fileName:fileName
               contentType:contentType
                  isPublic:isPublic
              successBlock:^(QBResponse * _Nonnull response, QBCBlob * _Nonnull blob) {
                  //
                  [source setResult:blob];
              } statusBlock:^(QBRequest * _Nonnull request, QBRequestStatus * _Nullable status) {
                  //
                  if (progress) progress(status.percentOfCompletion);
              } errorBlock:^(QBResponse * _Nonnull response) {
                  //
                  [source setError:response.error.error];
              }];
    
    return source.task;
}

#pragma mark - Download operations

+ (BFTask *)downloadFileWithUrl:(NSURL *)url {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            [source setResult:data];
        });
    });
    
    return source.task;
}

+ (BFTask *)downloadImageWithUrl:(NSURL *)url {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [[self downloadFileWithUrl:url] continueWithBlock:^id _Nullable(BFTask<NSData *> * _Nonnull task) {
        //
        task.isFaulted ? [source setError:task.error] : [source setResult:[UIImage imageWithData:task.result]];
        return nil;
    }];
    
    return source.task;
}

@end
