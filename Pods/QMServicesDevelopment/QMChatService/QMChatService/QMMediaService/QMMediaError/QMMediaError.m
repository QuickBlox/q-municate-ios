//
//  QMMediaError.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 2/14/17.
//
//

#import "QMMediaError.h"


@implementation QMMediaError

+ (instancetype)errorWithResponse:(QBResponse *)response {
    return  [[self alloc] initWithResponse:response];
}

- (instancetype)initWithResponse:(QBResponse *)response {
    
    if (self = [super init]) {
        
        _error = response.error.error;
        
        if (response.status == QBResponseStatusCodeNotFound) {
            _attachmentStatus = QMMessageAttachmentStatusError;
            
        }
        else {
            _attachmentStatus = QMMessageAttachmentStatusNotLoaded;
        }
    }
    
    return self;
}

@end
