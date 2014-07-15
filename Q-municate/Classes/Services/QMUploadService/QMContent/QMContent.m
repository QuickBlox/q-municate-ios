//
//  QMContent.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContent.h"
#import "QBEchoObject.h"

@interface QMContent ()

@end

@implementation QMContent

- (void)loadImageWithBlobID:(NSUInteger)blobID completion:(QBCFileDownloadTaskResultBlock)completion {
    [QBContent TDownloadFileWithBlobID:blobID delegate:[QBEchoObject instance] context: [QBEchoObject makeBlockForEchoObject:completion]];
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

#pragma mark - QBActionStatusDelegate


- (void)setProgress:(float)progress {
    
    self.uploadProgress = progress;
}

@end
