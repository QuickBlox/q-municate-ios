//
//  QMUploadService.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QMContentProgressBlock)(float progress);
typedef void(^QMContentCompetionBlock)(NSError *error);

@interface QMContentOperation : NSOperation <QBActionStatusDelegate>

@property (copy, nonatomic) QMContentProgressBlock progressBlock;
@property (copy, nonatomic) QMContentCompetionBlock completion;

@end

@interface QMUploadOperation : QMContentOperation

@end

@interface QMDownloadOperation : QMContentOperation

@end

@interface QMUploadService : NSObject

- (void)uploadFile:(NSData *)data fileName:(NSString *)fileName contentType:(NSString *)contentType isPublic:(BOOL)isPublic;

@end
