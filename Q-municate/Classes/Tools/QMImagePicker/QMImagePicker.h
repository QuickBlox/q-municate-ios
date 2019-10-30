//
//  QMImagePicker.h
//  Q-municate
//
//  Created by Injoit on 11.08.14.
//  Copyright © 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMImagePickerResultHandler;

@interface QMImagePicker : UIImagePickerController

+ (void)takePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler;
+ (void)takePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing;

+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler;
+ (void)choosePhotoInViewController:(UIViewController *)vc resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing;

+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler;
+ (void)takePhotoOrVideoInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                                 quality:(UIImagePickerControllerQualityType)quality
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler
                           allowsEditing:(BOOL)allowsEditing;

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler;

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler allowsEditing:(BOOL)allowsEditing;

+ (void)chooseFromGaleryInViewController:(UIViewController *)vc
                             maxDuration:(NSTimeInterval)maxDuration
                           resultHandler:(id<QMImagePickerResultHandler>)resultHandler
                           allowsEditing:(BOOL)allowsEditing;

@end

@protocol QMImagePickerResultHandler <NSObject>

@optional

- (void)imagePicker:(QMImagePicker *)imagePicker didFinishPickingPhoto:(UIImage *)photo;
- (void)imagePicker:(QMImagePicker *)imagePicker didFinishPickingVideo:(NSURL *)videoUrl;
- (void)imagePicker:(QMImagePicker *)imagePicker didFinishPickingWithError:(NSError *)error;
- (void)imagePickerCanBePresented:(QMImagePicker *)imagePicker withCompletion:(void(^)(BOOL granted))grantBlock;

@end
