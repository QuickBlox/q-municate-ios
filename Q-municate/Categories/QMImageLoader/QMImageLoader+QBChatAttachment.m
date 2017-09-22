//
//  QMImageLoader+QBChatAttachment.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 7/3/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMImageLoader+QBChatAttachment.h"
#import "QBChatAttachment+QMCustomParameters.h"
#import "QMServices.h"
#import "QMCore.h"

@implementation QMImageLoader (QBChatAttachment)

- (void)imageForAttachment:(QBChatAttachment *)attachment
                 transform:(nullable QMImageTransform *)transform
                   options:(SDWebImageOptions)options
                  progress:(_Nullable SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(QMWebImageCompletionWithFinishedBlock)completedBlock {
    
    if (attachment.attachmentType == QMAttachmentContentTypeImage) {
        
        NSURL *remoteURL = [attachment remoteURLWithToken:NO];
        NSString *token = QBSession.currentSession.sessionDetails.token;
        
        [self downloadImageWithURL:remoteURL
                             token:token
                         transform:transform
                           options:options
                          progress:progressBlock
                         completed:completedBlock];
        }
    
    else if (attachment.attachmentType == QMAttachmentContentTypeVideo){}
//
    

}

@end
