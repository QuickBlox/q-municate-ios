//
//  QMContent.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContent.h"
#import "QMContactList.h"

@interface QMContent () <QBActionStatusDelegate>

@end

@implementation QMContent

- (void)uploadImage:(UIImage *)image named:(NSString *)name completion:(QBFileUploadTaskResultBlock)completion {

    NSData *data = UIImagePNGRepresentation(image);
    
    [QBContent TUploadFile:data
                  fileName:name
               contentType:@"image/png"
                  isPublic:YES
                  delegate:self
                   context:Block_copy((__bridge void *)(completion))];
}

- (void)uploadUserImageForUser:(QBUUser *)user image:(UIImage *)image withCompletion:(QBFileUploadTaskResultBlock)completion {
    
    NSString *fileName = [NSString stringWithFormat:@"PIC_USR_ID_%lu", (unsigned long)user.ID];
    [self uploadImage:image named:fileName completion:completion];
}

#pragma mark - QBActionStatusDelegate

- (void)completedWithResult:(Result *)result context:(void *)contextInfo {
    
    ((__bridge void (^)(Result * result))(contextInfo))(result);
    Block_release(contextInfo);
}

- (void)setProgress:(float)progress {
    
    self.uploadProgress = progress;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadProgressDidChanged" object:nil];
}

@end
