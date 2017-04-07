//
//  QMContent.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QMContentProgressBlock)(float progress);

/**
 *  This class provides interface for content files.
 */
@interface QMContent : NSObject

//MARK: - Upload operations

+ (BFTask QB_GENERIC(QBCBlob *) *)uploadPNGImage:(UIImage *)image
                  progress:(QMContentProgressBlock)progress;

+ (BFTask QB_GENERIC(QBCBlob *) *)uploadJPEGImage:(UIImage *)image
                                         progress:(QMContentProgressBlock)progress;

+ (BFTask QB_GENERIC(QBCBlob *) *)uploadData:(NSData *)data
                                    fileName:(NSString *)fileName
                                 contentType:(NSString *)contentType
                                    isPublic:(BOOL)isPublic
                                    progress:(QMContentProgressBlock)progress;

//MARK: - Download operations

+ (BFTask QB_GENERIC(NSData *) *)downloadFileWithUrl:(NSURL *)url;

+ (BFTask QB_GENERIC(UIImage *) *)downloadImageWithUrl:(NSURL *)url;

@end
