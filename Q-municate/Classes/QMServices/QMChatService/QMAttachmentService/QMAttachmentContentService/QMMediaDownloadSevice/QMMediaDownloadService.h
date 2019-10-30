//
//  QMMediaDownloadService.h
//  QMMediaKit
//
//  Created by Injoit on 2/7/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>
#import "QMCancellableService.h"
#import "QMMediaBlocks.h"

#import "QMAsynchronousOperation.h"


@interface QMDownloadOperation : QMAsynchronousBlockOperation

@property (nonatomic, strong) QBRequest *request;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSData *data;

@end

@interface QMMediaDownloadService : NSObject <QMCancellableService>

- (BOOL)isDownloadingMessageWithID:(NSString *)messageID;

- (void)downloadAttachmentWithID:(NSString *)attachmentID
                       messageID:(NSString *)messageID
                   progressBlock:(QMAttachmentProgressBlock)progressBlock
                 completionBlock:(void(^)(QMDownloadOperation *downloadOperation))completion;

@end
