//
//  QMUploadService.m
//  Qmunicate
//
//  Created by Andrey on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUploadService.h"
#import "QMContent.h"
#import "QBEchoObject.h"

typedef void(^QMContentProgressBlock)(float progress);

typedef void(^QMContentCompetionBlock)(NSError *error);

@interface QMUploadService()

@property(strong, nonatomic) NSOperationQueue *contentOperationQueue;

@end

@implementation QMUploadService

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.contentOperationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

@end

@interface QMContentOperation : NSOperation

<QBActionStatusDelegate>

@property (copy, nonatomic) QMContentProgressBlock progressBlock;
@property (copy, nonatomic) QMContentCompetionBlock completion;

@end

@interface QMUploadOperation : QMContentOperation

@end

@interface QMDownloadOperation : QMContentOperation

@end

@implementation QMContentOperation

- (void)setProgress:(float)progress {
    if(self.progressBlock)
        self.progressBlock(progress);
}


- (void)completedWithResult:(Result*)result {

    NSError *error = nil;
    
    if (!result.success) {
        
    }
    
    if (self.completion) {
        self.completion(error);
    }
}

@end

@implementation QMDownloadOperation
- (void)loadImageWithBlobID:(NSUInteger)blobID completion:(QBCFileDownloadTaskResultBlock)completion {
    [QBContent TDownloadFileWithBlobID:blobID delegate:self];
}

- (void)uploadImage:(UIImage *)image named:(NSString *)name completion:(QBFileUploadTaskResultBlock)completion {
    
    NSData *data = UIImagePNGRepresentation(image);
    
    [QBContent TUploadFile:data
                  fileName:name
               contentType:@"image/png"
                  isPublic:YES
                  delegate:[QBEchoObject instance]
                   context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)uploadUserImageForUser:(QBUUser *)user image:(UIImage *)image withCompletion:(QBFileUploadTaskResultBlock)completion {
    
    NSString *fileName = [NSString stringWithFormat:@"PIC_USR_ID_%lu", (unsigned long)user.ID];
    [self uploadImage:image named:fileName completion:completion];
}

@end