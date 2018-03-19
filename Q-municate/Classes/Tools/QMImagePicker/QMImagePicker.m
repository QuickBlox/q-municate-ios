//
//  QMImagePicker.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import "QMImagePicker.h"

static NSString * const kQMImagePickerErrorDomain = @"com.qmunicate.imagepicker";
static const NSUInteger kQMMaxFileSize = 100; //in MBs

@interface QMImagePicker()

<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) id<QMImagePickerResultHandler> resultHandler;
@property (strong, nonatomic) AVAssetExportSession *exportSession;

@end

@implementation QMImagePicker

- (void)dealloc {
    QMLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

+ (void)takePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    [[self class] takePhotoInViewController:vc resultHandler:resultHandler allowsEditing:YES];
}

+ (void)takePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing {
    
    QMImagePicker *imagePicker = [[[self class] alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = allowsEditing;
    imagePicker.resultHandler = resultHandler;
    
    [vc presentViewController:imagePicker animated:YES completion:nil];
}

+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    [[self class] choosePhotoInViewController:vc resultHandler:resultHandler allowsEditing:YES];
}

+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing {
    
    QMImagePicker *imagePicker = [[[self class] alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = allowsEditing;
    
    imagePicker.resultHandler = resultHandler;
    
    [vc presentViewController:imagePicker animated:YES completion:nil];
}

+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    [[self class] takePhotoOrVideoInViewController:vc
                                       maxDuration:maxDuration
                                           quality:quality
                                     resultHandler:resultHandler
                                     allowsEditing:YES];
}

+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler
                           allowsEditing:(BOOL)allowsEditing {
    
    QMImagePicker *imagePicker = [[[self class] alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    imagePicker.videoMaximumDuration = maxDuration;
    imagePicker.videoQuality = quality;
    
    imagePicker.allowsEditing = allowsEditing;
    imagePicker.resultHandler = resultHandler;
    
    dispatch_block_t presentBlock = ^{
        [vc presentViewController:imagePicker
                         animated:YES
                       completion:nil];
    };
    
    if ([resultHandler respondsToSelector:@selector(imagePickerCanBePresented:withCompletion:)]) {
        
        [resultHandler imagePickerCanBePresented:imagePicker withCompletion:^(BOOL granted) {
            if (granted) {
                presentBlock();
            }
        }];
    }
    else {
        presentBlock();
    }
}

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler
                           allowsEditing:(BOOL)allowsEditing {
    
    QMImagePicker *imagePicker = [[[self class] alloc] init];
    
    imagePicker.allowsEditing =
    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? NO : allowsEditing;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    
    if (maxDuration > 0) {
        imagePicker.videoMaximumDuration = maxDuration;
    }
    
    imagePicker.resultHandler = resultHandler;
    
    dispatch_block_t presentBlock = ^{
        [vc presentViewController:imagePicker
                         animated:YES
                       completion:nil];
    };
    
    if ([resultHandler respondsToSelector:@selector(imagePickerCanBePresented:withCompletion:)]) {
        
        [resultHandler imagePickerCanBePresented:imagePicker withCompletion:^(BOOL granted) {
            if (granted) {
                presentBlock();
            }
        }];
    }
    else {
        presentBlock();
    }
}

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    [[self class] chooseFromGaleryInViewController:vc
                                     resultHandler:resultHandler
                                     allowsEditing:YES];
}

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing {
    
    [[self class] chooseFromGaleryInViewController:vc
                                       maxDuration:0.0
                                     resultHandler:resultHandler
                                     allowsEditing:allowsEditing];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        
        if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            
            NSURL *resultMediaUrl = info[UIImagePickerControllerMediaURL];
            
            NSError *attributesError = nil;
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:resultMediaUrl.path
                                                                                            error:&attributesError];
            if (attributesError) {
                QMLog(@"Error occurred while getting file attributes = %@", attributesError);
                return;
            }
            
            NSNumber *fileSizeNumber = fileAttributes[NSFileSize];
            CGFloat fileSize = fileSizeNumber.longLongValue/1024.0f/1024.0f;
            
            if (fileSize > kQMMaxFileSize) {
          
                NSString *localizedDescription =
                [NSString stringWithFormat:NSLocalizedString(@"QM_STR_MAXIMUM_FILE_SIZE", nil),kQMMaxFileSize];
                [self.resultHandler imagePicker:self didFinishPickingWithError:[NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                                                                                                   code:0
                                                                                               userInfo:@{NSLocalizedDescriptionKey : localizedDescription}]];
                return;
            }
            
            [self convertVideoFileToMpegFormatAtUrl:resultMediaUrl
                                         completion:^(NSURL *outputFileURL, NSError *error) {
                                             
                                             error ?
                                             [self.resultHandler imagePicker:self didFinishPickingWithError:error] :
                                             [self.resultHandler imagePicker:self didFinishPickingVideo:outputFileURL];
                                         }];
        }
        else {
            
            NSString *key = picker.allowsEditing ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage;
            
            UIImage *resultImage = info[key];
            [self.resultHandler imagePicker:self didFinishPickingPhoto:resultImage];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{}];
}


- (void)convertVideoFileToMpegFormatAtUrl:(NSURL *)videoFileURL
                               completion:(void(^)(NSURL *outputFileURL, NSError *error))completion {
    
    [self convertVideoFileToMpegFormatAtUrl:videoFileURL
                              withStartTime:0
                                    endTime:0
                                 completion:completion];
}

- (void)convertVideoFileToMpegFormatAtUrl:(NSURL *)videoFileURL
                            withStartTime:(CGFloat)startVideoTime
                                  endTime:(CGFloat)endVideoTime
                               completion:(void(^)(NSURL *outputFileURL, NSError *error))completion {
    
    NSURL *videoFileOutput = uniqueOutputFileURL();
    NSURL *videoFileInput = videoFileURL;
    
    AVAsset *asset = [AVAsset assetWithURL:videoFileInput];
    
    self.exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                           presetName:AVAssetExportPresetMediumQuality];
    if (self.exportSession == nil) {
        NSError *error = [NSError errorWithDomain:kQMImagePickerErrorDomain code:0 userInfo:nil];
        completion(nil, error);
    }
    
    //Trim video if needed
    if (endVideoTime > 0 && startVideoTime < endVideoTime) {
        
        CMTime startTime = CMTimeMake((int)(floor(startVideoTime * 100)), 100);
        CMTime endTime = CMTimeMake((int)(ceil(endVideoTime * 100)), 100);
        
        CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, endTime);
        self.exportSession.timeRange = exportTimeRange;
    }
    
    self.exportSession.outputURL = videoFileOutput;
    
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    
    __weak typeof(self) weakSelf = self;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         switch (strongSelf.exportSession.status) {
                 
             case AVAssetExportSessionStatusCompleted:
                 completion(videoFileOutput, nil);
                 break;
                 
             case AVAssetExportSessionStatusFailed:
             case AVAssetExportSessionStatusCancelled:
                 completion(nil, self.exportSession.error);
                 break;
             default:
                 NSAssert(NO, @"Not handled state for export session");
                 break;
         }
     }];
}

static inline NSURL *uniqueOutputFileURL() {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    
    NSString *uniqueFileName = [[NSUUID UUID] UUIDString];
    NSString *outputFilePath =
    [cacheDirectory stringByAppendingFormat:@"/output_%@.mp4", uniqueFileName];
    
    return [NSURL fileURLWithPath:outputFilePath];
}

@end
