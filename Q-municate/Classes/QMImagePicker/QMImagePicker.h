//
//  QMImagePicker.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QMImagePickerResult)(UIImage *image);

@interface QMImagePicker : UIImagePickerController

+ (void)presentIn:(UIViewController *)vc
        configure:(void (^)(UIImagePickerController *picker))configure
           result:(QMImagePickerResult)result;

+ (void)chooseSourceTypeInVC:(id)vc allowsEditing:(BOOL)allowsEditing result:(QMImagePickerResult)result;

@end
