//
//  UIImageView+ImageWithBlobID.m
//  Q-municate
//
//  Created by Igor Alefirenko on 25/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "UIImageView+ImageWithBlobID.h"

@implementation UIImageView (ImageWithBlobID) 


- (void)loadImageWithBlobID:(NSUInteger)blobID
{
    QBResultBlock resultBlock = ^(Result *result) {
        if (result.success && [result isKindOfClass:[QBCFileDownloadTaskResult class]]) {
            QBCFileDownloadTaskResult *taskResult =  (QBCFileDownloadTaskResult *)result;
            NSData *imageData = taskResult.file;
            UIImage *img = [UIImage imageWithData:imageData];
            self.image = img;
        }
    };
    [QBContent TDownloadFileWithBlobID:blobID delegate:self context: Block_copy((__bridge void *)(resultBlock))];
}

- (void)completedWithResult:(Result *)result context:(void *)contextInfo
{
    ((__bridge void (^)(Result * result))(contextInfo))(result);
    Block_release(contextInfo);
}

@end
