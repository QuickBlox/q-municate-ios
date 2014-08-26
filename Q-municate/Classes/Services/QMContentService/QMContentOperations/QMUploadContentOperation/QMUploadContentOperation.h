//
//  QMUploadContentOperation.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 28.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMContentOperation.h"

@interface QMUploadContentOperation : QMContentOperation

- (instancetype)initWithUploadFile:(NSData *)data fileName:(NSString *)fileName contentType:(NSString *)contentType isPublic:(BOOL)isPublic;

@end
