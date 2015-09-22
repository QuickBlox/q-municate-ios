//
//  QMDownloadContentOperation.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 28.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDownloadContentOperation.h"

@interface QMDownloadContentOperation()

@property (assign, nonatomic) NSUInteger blobID;

@end

@implementation QMDownloadContentOperation

- (instancetype)initWithBlobID:(NSUInteger )blobID {

    self = [super init];
    if (self) {
        self.blobID = blobID;
    }
    return self;
}

- (void)main {
    
    self.cancelableRequest = [QBRequest downloadFileWithID:self.blobID
                                              successBlock:^(QBResponse *response, NSData *fileData) {
                                                  //
                                                  if (self.completionHandler) {
                                                      QMCFileDownloadResponseBlock block = (QMCFileDownloadResponseBlock)self.completionHandler;
                                                      block(response,fileData);
                                                  }
                                              } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                                  //
                                                  if (self.progressHandler) self.progressHandler(status.percentOfCompletion);
                                              } errorBlock:^(QBResponse *response) {
                                                  //
                                                  if (self.completionHandler) {
                                                      QMCFileDownloadResponseBlock block = (QMCFileDownloadResponseBlock)self.completionHandler;
                                                      block(response,nil);
                                                  }
                                              }];
}

@end
