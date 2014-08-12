//
//  QMImagePicker.m
//  Q-municate
//
//  Created by Andrey on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImagePicker.h"

@interface QMImagePicker()

<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (copy, nonatomic) QMImagePickerResult result;

@end

@implementation QMImagePicker

+ (void)presentIn:(UIViewController *)vc
        configure:(void (^)(UIImagePickerController *picker))configure
           result:(QMImagePickerResult)result {
    
    QMImagePicker *picker = [[QMImagePicker alloc] init];
    picker.result = result;
    configure(picker);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [vc presentViewController:picker animated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *key = picker.allowsEditing ? UIImagePickerControllerEditedImage: UIImagePickerControllerOriginalImage;
    UIImage *image = info[key];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.result(image);
        self.result = nil;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        self.result = nil;        
    }];
}

@end
