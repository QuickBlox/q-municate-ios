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

@interface QMVideoConverter : NSObject

@end

@interface QMVideoConverter()

@end

@implementation QMVideoConverter

+ (BFTask <NSURL *> *)taskConvertToOtputFileType:(AVFileType)fileType
                                           atURL:(NSURL*)fileURL
                                  withPresetName:(nullable NSString *)presetName
                     shouldOptimizeForNetworkUse:(BOOL)shouldOptimizeForNetworkUse {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    NSURL *fileOutput = uniqueOutputFileURL();
    NSURL *fileInput = fileURL;
    
    AVAsset *asset = [AVAsset assetWithURL:fileInput];
    if (!presetName) {
        presetName = AVAssetExportPresetMediumQuality;
    }
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:presetName];
    exportSession.outputURL = fileOutput;
    
    exportSession.shouldOptimizeForNetworkUse = shouldOptimizeForNetworkUse;
    exportSession.outputFileType = fileType;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
                
            case AVAssetExportSessionStatusCompleted:
                [source setResult:fileOutput];
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
    
    return [self taskConvertToOtputFileType:AVFileTypeAppleM4A
                                      atURL:audioFileURL
                             withPresetName:AVAssetExportPresetAppleM4A
                shouldOptimizeForNetworkUse:YES];
}

+ (BFTask <NSURL *> *)taskConvertVideoToMpeg4FormatAtUrl:(NSURL *)videoFileURL {
    
    return [self taskConvertToOtputFileType:AVFileTypeMPEG4
                                      atURL:videoFileURL
                             withPresetName:nil
                shouldOptimizeForNetworkUse:YES];
}

static inline NSURL *uniqueOutputFileURL() {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    
    NSString *uniqueFileName = [[NSUUID UUID] UUIDString];
    NSString *outputFilePath =
    [cacheDirectory stringByAppendingFormat:@"/output_%@", uniqueFileName];
    
    return [NSURL fileURLWithPath:outputFilePath];
}
@end

@implementation QMAttachmentProvider


+ (BFTask <QBChatAttachment *>*)attachmentWithFileURL:(NSURL *)fileURL
                                             settings:(nullable QMAttachmentProviderSettings *)providerSettings {
    
    NSString *fileName = [[fileURL pathComponents] lastObject];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[fileName pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    
    if (UTTypeConformsTo(UTI, kUTTypeMovie)) {
        //We should convert all video formats to mp4 format.
        if (UTTypeConformsTo(UTI, kUTTypeMPEG4)) {
            QBChatAttachment *attachment =  [QBChatAttachment videoAttachmentWithFileURL:fileURL];
            return [self taskLoadValuesForAttachment:attachment];
        }
        else {
            
            return [[QMVideoConverter taskConvertVideoToMpeg4FormatAtUrl:fileURL] continueWithBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
                if (t.error) {
                    [BFTask taskWithError:t.error];
                }
                else {
                    QBChatAttachment *attachment = [QBChatAttachment videoAttachmentWithFileURL:t.result];
                    return [self taskLoadValuesForAttachment:attachment];
                }
                
                return nil;
            }];
        }
    }
    else if (UTTypeConformsTo(UTI, kUTTypeAudio)) {
        if (UTTypeConformsTo(UTI, kUTTypeMPEG4Audio)) {
            QBChatAttachment *attachment =  [QBChatAttachment audioAttachmentWithFileURL:fileURL];
            return [self taskLoadValuesForAttachment:attachment];
        }
        else {
            return [[QMVideoConverter taskConvertAudioToM4AFormatAtUrl:fileURL] continueWithBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
                if (t.error) {
                    [BFTask taskWithError:t.error];
                }
                QBChatAttachment *attachment =  [QBChatAttachment audioAttachmentWithFileURL:t.result];
                return  [self taskLoadValuesForAttachment:attachment];
            }];
        }
    }
    else if (UTTypeConformsTo(UTI, kUTTypeImage)) {
        
        BFExecutor *backgroundExecutor =
        [BFExecutor executorWithDispatchQueue:dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        return [BFTask taskFromExecutor:backgroundExecutor withBlock:^id _Nonnull{
            
            NSData *imageData = [NSData dataWithContentsOfURL:fileURL];
            UIImage *image = [UIImage imageWithData:imageData];
            UIImage *resizedImage = [self resizedImageFromImage:image
                                               withMaxImageSize:providerSettings.maxImageSize];
            
            QBChatAttachment *attachment = [QBChatAttachment imageAttachmentWithImage:resizedImage];
            return [BFTask taskFromExecutor:BFExecutor.mainThreadExecutor withBlock:^id _Nonnull{
                return [BFTask taskWithResult:attachment];
            }];
        }];
    }
    
    NSString *localizedDescription =
    [NSString stringWithFormat:@"Attachment with type identifier:%@ and mimeType:%@ is not supported",
     (__bridge NSString *)UTI,
     (__bridge NSString *)MIMEType];
    NSError *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
    
    return [BFTask taskWithError:error];
}

+ (BFTask <QBChatAttachment *> *)taskLoadValuesForAttachment:(QBChatAttachment *)attachment {
    
    if (attachment.attachmentType == QMAttachmentContentTypeImage) {
        return [BFTask taskWithResult:attachment];
    }
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:attachment.localFileURL options:nil];
    
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
