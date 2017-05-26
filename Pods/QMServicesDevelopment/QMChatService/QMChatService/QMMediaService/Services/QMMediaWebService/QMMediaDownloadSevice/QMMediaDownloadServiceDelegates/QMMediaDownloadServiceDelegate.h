//
//  QMMediaDownloadServiceDelegate.h
//  QMMediaKit
//
//  Created by Vitaliy Gurkovsky on 2/7/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMMediaBlocks.h"

@protocol QMMediaDownloadServiceDelegate <NSObject>

- (void)downloadDataForAttachment:(QBChatAttachment *)attachment
              withCompletionBlock:(QMAttachmentDataCompletionBlock)completionBlock
                    progressBlock:(QMMediaProgressBlock)progressBlock;

- (void)cancellAllDownloads;
- (void)cancelDownloadOperationForAttachment:(QBChatAttachment *)attachment;

@end




