//
//  QMMediaUploadServiceDelegate.h
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/9/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMMediaBlocks.h"

@protocol QMMediaUploadServiceDelegate <NSObject>

- (void)uploadAttachment:(QBChatAttachment *)attachment
                withData:(NSData *)data
     withCompletionBlock:(QMAttachmentUploadCompletionBlock)completionBlock
           progressBlock:(QMMediaProgressBlock)progressBlock;

- (void)uploadAttachment:(QBChatAttachment *)attachment
             withFileURL:(NSURL *)fileURL
     withCompletionBlock:(QMAttachmentUploadCompletionBlock)completionBlock
           progressBlock:(QMMediaProgressBlock)progressBlock;

@end
