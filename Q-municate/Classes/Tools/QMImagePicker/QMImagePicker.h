//
//  QMImagePicker.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMImagePickerResultHandler;

@interface QMImagePicker : UIImagePickerController

+ (void)takePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler;

+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler;

+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler;

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler;

@end

@protocol QMImagePickerResultHandler <NSObject>

@optional

- (void)imagePicker:(QMImagePicker *)imagePicker didFinishPickingPhoto:(UIImage *)photo;
- (void)imagePicker:(QMImagePicker *)imagePicker didFinishPickingVideo:(NSURL *)videoUrl;

@end
