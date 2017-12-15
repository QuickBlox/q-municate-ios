//
//  QMAttachmentProvider.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/30/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMAttachmentProvider.h"
#import <AVFoundation/AVFoundation.h>
#import "QBChatAttachment+QMCustomParameters.h"
#import "QBChatAttachment+QMFactory.h"

@implementation QMAttachmentProviderSettings @end

@interface QMAssetConverter : NSObject

@end

@interface QMAssetConverter()

@end

@implementation QMAssetConverter

+ (BFTask <NSURL *> *)taskConvertToOtputFileType:(AVFileType)fileType
                                        inputURL:(NSURL *)inputFileURL
                                       outputURL: (NSURL *)outputFileURL
                                  withPresetName:(nullable NSString *)presetName
                     shouldOptimizeForNetworkUse:(BOOL)shouldOptimizeForNetworkUse {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    AVAsset *asset = [AVAsset assetWithURL:inputFileURL];
    if (!presetName) {
        presetName = AVAssetExportPresetMediumQuality;
    }
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:presetName];
    exportSession.outputURL = outputFileURL;
    
    exportSession.shouldOptimizeForNetworkUse = shouldOptimizeForNetworkUse;
    exportSession.outputFileType = fileType;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
                
            case AVAssetExportSessionStatusCompleted:
                [source setResult:outputFileURL];
                break;
            case AVAssetExportSessionStatusFailed:
            case AVAssetExportSessionStatusCancelled:
                [source setError:exportSession.error];
                break;
            default:
                NSAssert(NO, @"Not handled state for export session");
                break;
        }
    }];
    
    return source.task;
}

+ (BFTask <NSURL *> *)taskConvertAudioToM4AFormatAtUrl:(NSURL *)audioFileURL {
    
    NSURL *fileOutput = uniqueOutputFileURLWithFileExtension(@".m4a");
    
    return [self taskConvertToOtputFileType:AVFileTypeAppleM4A
                                   inputURL:audioFileURL
                                  outputURL:fileOutput
                             withPresetName:AVAssetExportPresetPassthrough
                shouldOptimizeForNetworkUse:YES];
}

+ (BFTask <NSURL *> *)taskConvertVideoToMpeg4FormatAtUrl:(NSURL *)videoFileURL {
    
    NSURL *fileOutput = uniqueOutputFileURLWithFileExtension(@".mp4");
    
    return [self taskConvertToOtputFileType:AVFileTypeMPEG4
                                   inputURL:videoFileURL
                                  outputURL:fileOutput
                             withPresetName:AVAssetExportPresetPassthrough
                shouldOptimizeForNetworkUse:YES];
}

static inline NSURL *uniqueOutputFileURLWithFileExtension(NSString * fileExtension) {
    
    NSString *uniqueFileName = [[NSUUID UUID] UUIDString];
    NSString *outputFilePath =
    [NSTemporaryDirectory() stringByAppendingFormat:@"output_%@%@", uniqueFileName, fileExtension];
    
    return [NSURL fileURLWithPath:outputFilePath];
}

@end

@implementation QMAttachmentProvider

+ (BFTask <QBChatAttachment *>*)imageAttachmentWithData:(NSData *)imageData
                                               settings:(nullable QMAttachmentProviderSettings *)providerSettings {
    if (providerSettings.maxFileSize > 0) {
        
        CGFloat fileSize = imageData.length/1024.0f/1024.0f;
        
        if (fileSize > providerSettings.maxFileSize) {
            NSString *localizedDescription =
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_MAXIMUM_FILE_SIZE", nil), providerSettings.maxFileSize];
            NSError *error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                                 code:0
                                             userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
            return [BFTask taskWithError:error];
        }
    }
    
    BFExecutor *backgroundExecutor =
    [BFExecutor executorWithDispatchQueue:dispatch_queue_create("backgroundExecutor", DISPATCH_QUEUE_PRIORITY_DEFAULT)];
    
    return [BFTask taskFromExecutor:backgroundExecutor withBlock:^id _Nonnull{
        
        UIImage *image = [UIImage imageWithData:imageData];
        UIImage *resizedImage = [self resizedImageFromImage:image
                                           withMaxImageSize:providerSettings.maxImageSize];
        
        QBChatAttachment *attachment = [QBChatAttachment imageAttachmentWithImage:resizedImage];
        return [BFTask taskFromExecutor:BFExecutor.mainThreadExecutor withBlock:^id _Nonnull{
            
            return [BFTask taskWithResult:attachment];
        }];
    }];    
}

+ (BFTask <QBChatAttachment *>*)attachmentWithFileURL:(NSURL *)fileURL
                                             settings:(nullable QMAttachmentProviderSettings *)providerSettings {
    if (providerSettings.maxFileSize > 0) {
        
        NSError *attributesError = nil;
        
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path
                                                                                        error:&attributesError];
        if (attributesError) {
            NSLog(@"Error occurred while getting file attributes = %@", attributesError);
            return [BFTask taskWithError:attributesError];
        }
        
        NSNumber *fileSizeNumber = fileAttributes[NSFileSize];
        CGFloat fileSize = fileSizeNumber.longLongValue/1024.0f/1024.0f;
        
        if (fileSize > providerSettings.maxFileSize) {
            NSString *localizedDescription =
            [NSString stringWithFormat:NSLocalizedString(@"QM_STR_MAXIMUM_FILE_SIZE", nil), providerSettings.maxFileSize];
            NSError *error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                                 code:0
                                             userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
            return [BFTask taskWithError:error];
        }
    }
    
    NSString *fileName =
    [[fileURL pathComponents] lastObject];

    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[fileName pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    
    if (UTTypeConformsTo(UTI, kUTTypeMovie)) {
        
        //We should convert all video formats to mp4 format.
        if (UTTypeConformsTo(UTI, kUTTypeMPEG4)) {
            QBChatAttachment *attachment =  [QBChatAttachment videoAttachmentWithFileURL:fileURL];
            return [self taskLoadValuesForAttachment:attachment];
        }
        else {
            
            return [[QMAssetConverter taskConvertVideoToMpeg4FormatAtUrl:fileURL] continueWithBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
                if (t.error) {
                    return [BFTask taskWithError:t.error];
                }
                else {
                    
                    QBChatAttachment *attachment = [[QBChatAttachment alloc] initWithName:@"Video attachment"
                                                                                  fileURL:t.result
                                                                              contentType:(__bridge NSString *)MIMEType
                                                                           attachmentType:kQMAttachmentTypeVideo];
                    return [self taskLoadValuesForAttachment:attachment];
                }
            }];
        }
    }
    else if (UTTypeConformsTo(UTI, kUTTypeAudio)) {
        
        if (UTTypeConformsTo(UTI, kUTTypeMPEG4Audio)
            || UTTypeConformsTo(UTI, kUTTypeMP3)) {
            
            QBChatAttachment *attachment = [[QBChatAttachment alloc] initWithName:@"Audio attachment"
                                                                          fileURL:fileURL
                                                                      contentType:(__bridge NSString *)MIMEType
                                                                   attachmentType:kQMAttachmentTypeAudio];
            return [self taskLoadValuesForAttachment:attachment];
        }
    }
    else if (UTTypeConformsTo(UTI, kUTTypeImage)) {
        
        if (UTTypeConformsTo(UTI, kUTTypePNG)
            || UTTypeConformsTo(UTI, kUTTypeJPEG)) {
            
            NSData *imageData = [NSData dataWithContentsOfURL:fileURL];
            return [self imageAttachmentWithData:imageData
                                        settings:providerSettings];
        }
    }
    
    NSString *localizedDescription =
    [NSString stringWithFormat:@"Attachment with name %@ is not supported",fileName];
    
    NSError *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
    
    return [BFTask taskWithError:error];
}

+ (NSString *)mimeTypeForData:(NSData *)data {
    
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
            break;
        case 0x89:
            return @"image/png";
            break;
        case 0x47:
            return @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            break;
        case 0x25:
            return @"application/pdf";
            break;
        case 0xD0:
            return @"application/vnd";
            break;
        case 0x46:
            return @"text/plain";
            break;
        default:
            return @"application/octet-stream";
    }
}

+ (BFTask <QBChatAttachment *> *)taskLoadValuesForAttachment:(QBChatAttachment *)attachment {
    
    if (attachment.attachmentType == QMAttachmentContentTypeImage) {
        return [BFTask taskWithResult:attachment];
    }
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:attachment.localFileURL
                                               options:options];
    
    NSTimeInterval durationSeconds = CMTimeGetSeconds(urlAsset.duration);
    attachment.duration = lround(durationSeconds);
    
    if ([urlAsset tracksWithMediaType:AVMediaTypeVideo].count > 0) {
        
        AVAssetTrack *videoTrack = [[urlAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        CGSize videoSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
        attachment.width = lround(videoSize.width);
        attachment.height = lround(videoSize.height);
    }
    return [BFTask taskWithResult:attachment];
}

+ (UIImage *)resizedImageFromImage:(UIImage *)image
                  withMaxImageSize:(CGFloat)maxImageSize {
    
    if (maxImageSize > 0) {
        CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
        CGFloat scaleCoefficient = largestSide / maxImageSize;
        CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
        
        UIGraphicsBeginImageContext(newSize);
        
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return resizedImage;
    }
    
    return image;
}

@end
