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

@interface QMImagePicker()

<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) id<QMImagePickerResultHandler> resultHandler;

@end

@implementation QMImagePicker

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        
        if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            
            NSURL *resultMediaUrl = info[UIImagePickerControllerMediaURL];
            
            CGFloat startTime = [info[@"_UIImagePickerControllerVideoEditingStart"] floatValue];
            CGFloat endTime = [info[@"_UIImagePickerControllerVideoEditingEnd"] floatValue];
            BOOL wasEdited = endTime > 0;
            
            //In case we record video and edit it the result video wil be not trimmed
            if (picker.allowsEditing
                && picker.sourceType == UIImagePickerControllerSourceTypeCamera
                && wasEdited) {
                
                __weak typeof(self) weakSelf = self;
                
                [self trimVideoFileAtUrl:resultMediaUrl
                           withStartTime:startTime
                                 endTime:endTime
                              completion:^(NSURL *outputFileURL, NSError *error) {
                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                  if (!error) {
                                      [strongSelf.resultHandler imagePicker:self didFinishPickingVideo:outputFileURL];
                                  }
                                  else {
                                      [strongSelf.resultHandler imagePicker:self didFinishPickingWithError:error];
                                  }
                              }];
            }
            else {
                [self.resultHandler imagePicker:self didFinishPickingVideo:resultMediaUrl];
            }
        }
        else {
            
            NSString *key = picker.allowsEditing ? UIImagePickerControllerEditedImage: UIImagePickerControllerOriginalImage;
            UIImage *resultImage = info[key];
            
            [self.resultHandler imagePicker:self didFinishPickingPhoto:resultImage];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

-(void)trimVideoFileAtUrl:(NSURL *)videoFileURL
            withStartTime:(CGFloat)startVideoTime
                  endTime:(CGFloat)endVideoTime
               completion:(void(^)(NSURL *outputFileURL, NSError *error))completion {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    
    NSString *outputFilePath = [cacheDirectory stringByAppendingFormat:@"/output_%@.mov", [dateFormatter stringFromDate:[NSDate date]]];
    NSURL *videoFileOutput = [NSURL fileURLWithPath:outputFilePath];
    NSURL *videoFileInput = videoFileURL;
    
    AVAsset *asset = [AVAsset assetWithURL:videoFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:AVAssetExportPresetMediumQuality];
    if (exportSession == nil) {
        NSError *error = [NSError errorWithDomain:kQMImagePickerErrorDomain code:0 userInfo:nil];
        completion(nil, error);
    }
    
    CMTime startTime = CMTimeMake((int)(floor(startVideoTime * 100)), 100);
    CMTime endTime = CMTimeMake((int)(ceil(endVideoTime * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, endTime);
    
    exportSession.outputURL = videoFileOutput;
    exportSession.timeRange = exportTimeRange;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         switch (exportSession.status) {
                 
             case AVAssetExportSessionStatusCompleted:
                 completion(videoFileOutput, nil);
                 break;
                 
             case AVAssetExportSessionStatusFailed:
             case AVAssetExportSessionStatusCancelled:
                 completion(nil, exportSession.error);
                 break;
             default:
                 NSAssert(NO, @"Not handled state for export session");
                 break;
         }
     }];
}

@end
