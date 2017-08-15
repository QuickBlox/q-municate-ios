//
//  QMImageLoader+QBChatAttachment.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 7/3/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

@class QBChatAttachment;
#import <QMImageLoader.h>

NS_ASSUME_NONNULL_BEGIN
@interface QMImageLoader (QBChatAttachment)

- (void)imageForAttachment:(QBChatAttachment *)attachment
                 transform:(nullable QMImageTransform *)transform
                   options:(SDWebImageOptions)options
                  progress:(_Nullable SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(QMWebImageCompletionWithFinishedBlock)completedBlock;

@end
NS_ASSUME_NONNULL_END

