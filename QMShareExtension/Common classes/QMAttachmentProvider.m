//
//  QMAttachmentProvider.m
//  QMShareExtension
//
//  Created by Injoit on 10/30/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMAttachmentProvider.h"
#import <AVFoundation/AVFoundation.h>
#import "QBChatAttachment+QMCustomParameters.h"
#import "QBChatAttachment+QMFactory.h"
#import "UIImage+QM.h"

static const NSUInteger kQMMaxFileSize = 100; //in MBs
static const NSUInteger kQMMaxImageSize = 1000; //in pixels

@implementation QMAttachmentProviderSettings @end

@interface QMAssetConverter : NSObject

@end

@implementation QMAssetConverter

+ (BFTask <NSURL *> *)taskConvertToOutputFileType:(AVFileType)fileType
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
    
    return [self taskConvertToOutputFileType:AVFileTypeAppleM4A
                                    inputURL:audioFileURL
                                   outputURL:fileOutput
                              withPresetName:AVAssetExportPresetPassthrough
                 shouldOptimizeForNetworkUse:YES];
}

+ (BFTask <NSURL *> *)taskConvertVideoToMpeg4FormatAtUrl:(NSURL *)videoFileURL {
    
    NSURL *fileOutput = uniqueOutputFileURLWithFileExtension(@".mp4");
    
    return [self taskConvertToOutputFileType:AVFileTypeMPEG4
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


- (QMAttachmentProviderSettings *)providerSettings {
    
    if (!_providerSettings) {
        _providerSettings = defaultSettings();
    }
    
    return _providerSettings;
}


- (BFTask <QBChatAttachment*> *)taskAttachmentWithImage:(UIImage *)image
                                        typeIdentifiers:(NSArray *)typeIdentifiers {
    
    CGFloat fileSize = image.dataRepresentation.length/1024.0f/1024.0f;
    
    NSError *fileSizeError = validateFileSize(fileSize, self.providerSettings.maxFileSize);
    if (fileSizeError) {
        return [BFTask taskWithError:fileSizeError];
    }
    
    return taskAttachmentFromImage(image, self.providerSettings.maxImageSideSize);
}


- (BFTask <QBChatAttachment*> *)taskAttachmentWithFileURL:(NSURL *)fileURL
                                          typeIdentifiers:(NSArray *)typeIdentifiers {
    
    NSAssert(fileURL.isFileURL, @"fileURL");
    
    NSError *attributesError = nil;
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path
                                                                                    error:&attributesError];
    if (attributesError) {
        NSLog(@"Error occurred while getting file attributes = %@", attributesError);
        return attachmentErrorTask();
    }
    
    NSNumber *fileSizeNumber = fileAttributes[NSFileSize];
    CGFloat fileSize = fileSizeNumber.longLongValue/1024.0f/1024.0f;
    
    NSError *fileSizeError = validateFileSize(fileSize, self.providerSettings.maxFileSize);
    if (fileSizeError) {
        return [BFTask taskWithError:fileSizeError];
    }
    
    CFStringRef UTI = UTIFileURL(fileURL, typeIdentifiers);
    
    if (UTI == NULL) {
        return attachmentErrorTask();
    }
    
    
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
            
            NSData *data = [NSData dataWithContentsOfFile:fileURL.path];
            UIImage *image = [UIImage imageWithData:data];
            
            if (image) {
                return taskAttachmentFromImage(image,self.providerSettings.maxImageSideSize);
            }
            else {
                return attachmentErrorTask();
            }
        }
    }
    
    return attachmentErrorTask();
}


- (BFTask <QBChatAttachment*> *)taskAttachmentWithData:(NSData *)data
                                       typeIdentifiers:(NSArray *)typeIdentifiers {
    NSAssert(data, @"data");
    
    CGFloat fileSize = data.length/1024.0f/1024.0f;
    
    NSError *fileSizeError = validateFileSize(fileSize, self.providerSettings.maxFileSize);
    if (fileSizeError) {
        return [BFTask taskWithError:fileSizeError];
    }
    
    CFStringRef UTI = UTITypeIdentifiers(typeIdentifiers);
    
    if (UTTypeEqual(UTI, kUTTypePNG) ||
        UTTypeEqual(UTI, kUTTypeJPEG)) {
        
        UIImage *image = [UIImage imageWithData:data];
        
        if (image) {
            return taskAttachmentFromImage(image, self.providerSettings.maxImageSideSize);
        }
        else {
            return attachmentErrorTask();
        }
    }
    
    return attachmentErrorTask();
}


- (BFTask <QBChatAttachment *> *)taskLoadValuesForAttachment:(QBChatAttachment *)attachment {
    
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

//MARK: - Helpers


static BFTask<QBChatAttachment*> *taskAttachmentFromImage(UIImage *image, CGFloat maxSideSize) {
    
    BFExecutor *backgroundExecutor =
    [BFExecutor executorWithDispatchQueue:dispatch_queue_create("backgroundExecutor", DISPATCH_QUEUE_PRIORITY_DEFAULT)];
    
    return [BFTask taskFromExecutor:backgroundExecutor withBlock:^id _Nonnull{
        
        UIImage *resizedImage = resizeImage(image,maxSideSize);
        
        QBChatAttachment *attachment = [QBChatAttachment imageAttachmentWithImage:resizedImage];
        attachment.fileData = resizedImage.dataRepresentation;
        
        return [BFTask taskFromExecutor:BFExecutor.mainThreadExecutor withBlock:^id _Nonnull{
            return [BFTask taskWithResult:attachment];
        }];
    }];
}

static BFTask *attachmentErrorTask() {
    NSString *localizedDescription =
    [NSString stringWithFormat:@"Attachment is not supported"];
    
    NSError *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
    
    return [BFTask taskWithError:error];
}

static inline NSError* validateFileSize(CGFloat fileSize, NSUInteger maxFileSize) {
    
    NSError *error = nil;
    
    if (maxFileSize > 0 && fileSize > maxFileSize) {
        
        NSString *localizedDescription =
        [NSString stringWithFormat:NSLocalizedString(@"QM_STR_MAXIMUM_FILE_SIZE", nil), maxFileSize];
        error = [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                    code:0
                                userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
    }
    
    return error;
}

static UIImage *resizeImage(UIImage* image, CGFloat maxSideSize) {
    
    if (maxSideSize > 0) {
        CGFloat largestSide = image.size.width > image.size.height ? image.size.width : image.size.height;
        CGFloat scaleCoefficient = largestSide / maxSideSize;
        CGSize newSize = CGSizeMake(image.size.width / scaleCoefficient, image.size.height / scaleCoefficient);
        
        UIGraphicsBeginImageContext(newSize);
        
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        return resizedImage;
    }
    
    return image;
}

static CFStringRef UTITypeIdentifiers( NSArray *typeIdentifiers) {
    CFStringRef UTI = NULL;
    for (NSString *typeIdentifier in typeIdentifiers) {
        
        NSString *extension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)typeIdentifier, kUTTagClassFilenameExtension));
        
        if (extension) {
            UTI = (__bridge CFStringRef)typeIdentifier;
            break;
        }
    }
    return UTI;
}

static CFStringRef UTIFileURL(NSURL *fileURL, NSArray *typeIdentifiers) {
    
    CFStringRef UTI = UTITypeIdentifiers(typeIdentifiers);;
    
    if (UTI == NULL) {
        NSString *fileName =
        [[fileURL pathComponents] lastObject];
        if (fileName.pathExtension.length > 0) {
            UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[fileName pathExtension], NULL);
        }
    }
    
    return UTI;
}

static inline QMAttachmentProviderSettings *defaultSettings() {
    
    static QMAttachmentProviderSettings *defaultSettings = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultSettings = [QMAttachmentProviderSettings new];
        defaultSettings.maxImageSideSize = kQMMaxImageSize;
        defaultSettings.maxFileSize = kQMMaxFileSize;
    });
    
    return defaultSettings;
}

@end
