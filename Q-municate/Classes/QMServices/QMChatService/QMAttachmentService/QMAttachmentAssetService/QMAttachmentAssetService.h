//
//  QMAttachmentAssetService.h
//  QMChatService
//
//  Created by Injoit on 2/22/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

#import "QMMediaBlocks.h"
#import "QMCancellableService.h"

NS_ASSUME_NONNULL_BEGIN
@interface QMAttachmentAssetService : NSObject <QMCancellableService>

/**
 Loads asset from attachment's local file or remote URL.
 
 @param attachment The 'QBChatAttachment' instance.
 @param messageID The message ID that contains attachment.
 @param completion The block to be invoked when the loading succeeds, fails, or is cancelled.
 */
- (void)loadAssetForAttachment:(QBChatAttachment *)attachment
                     messageID:(NSString *)messageID
                    completion:(QMAttachmentAssetLoaderCompletionBlock)completion;
@end
NS_ASSUME_NONNULL_END
