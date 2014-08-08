//
//  QMDownloadContentOperation.m
//  Qmunicate
//
//  Created by Andrey on 28.07.14.
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
    self.cancelableOperation = [QBContent TDownloadFileWithBlobID:self.blobID delegate:self];
}

@end
