//
//  QMUploadService.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUploadService.h"
#import "QMContent.h"
#import "QBEchoObject.h"


@interface QMUploadService() 

@property(strong, nonatomic) NSOperationQueue *contentOperationQueue;

@end

@implementation QMUploadService

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.contentOperationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

@end

@implementation QMContentOperation 

- (void)setProgress:(float)progress {
    
    if(self.progressBlock)
        self.progressBlock(progress);
}

- (void)completedWithResult:(Result*)result {

    NSError *error = nil;
    
    if (!result.success) {
        if (self.completion) {
            self.completion(error);
        }
    }
}

@end

@implementation QMDownloadOperation

- (void)loadImageWithBlobID:(NSUInteger)blobID {
    [QBContent TDownloadFileWithBlobID:blobID delegate:self];
}

@end

@interface QMUploadOperation()

@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *contentType;
@property (assign, nonatomic) BOOL public;

@end

@implementation QMUploadOperation

- (instancetype)initWithUploadFile:(NSData *)data fileName:(NSString *)fileName contentType:(NSString *)contentType isPublic:(BOOL)isPublic {
    self = [super init];
    if (self) {
    
    }
    return self;
}

- (void)main {
    [QBContent TUploadFile:self.data fileName:self.fileName contentType:self.contentType isPublic:self.public delegate:self];
}

@end