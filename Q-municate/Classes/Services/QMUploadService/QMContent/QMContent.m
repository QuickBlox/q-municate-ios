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
    completion (nil);
}

- (void)uploadImage:(UIImage *)image named:(NSString *)name completion:(QBFileUploadTaskResultBlock)completion {
    completion (nil);
}

- (void)uploadUserImageForUser:(QBUUser *)user image:(UIImage *)image withCompletion:(QBFileUploadTaskResultBlock)completion {
    completion (nil);
}

@end
