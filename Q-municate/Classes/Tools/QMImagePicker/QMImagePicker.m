//
//  QMImagePicker.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import "QMImagePicker.h"
#import "REActionSheet.h"

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
    
    QMImagePicker *imagePicker = [[QMImagePicker alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = YES;
    imagePicker.resultHandler = resultHandler;
    
    [vc presentViewController:imagePicker animated:YES completion:nil];
}

+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    QMImagePicker *imagePicker = [[QMImagePicker alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    
    imagePicker.resultHandler = resultHandler;
    
    [vc presentViewController:imagePicker animated:YES completion:nil];
}

+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    QMImagePicker *imagePicker = [[QMImagePicker alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    imagePicker.videoMaximumDuration = maxDuration;
    imagePicker.videoQuality = quality;
    imagePicker.allowsEditing = YES;
    
    imagePicker.resultHandler = resultHandler;
    
    [vc presentViewController:imagePicker animated:NO completion:nil];
}

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler {
    
    QMImagePicker *imagePicker = [[QMImagePicker alloc] init];
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
    imagePicker.resultHandler = resultHandler;
    [vc presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            
            NSURL *resultMediaUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            [self.resultHandler imagePicker:self didFinishPickingVideo:resultMediaUrl];
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

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
}

@end
