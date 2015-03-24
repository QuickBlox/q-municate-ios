//
//  QMImagePicker.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImagePicker.h"
#import "REActionSheet.h"

@interface QMImagePicker()

<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (copy, nonatomic) QMImagePickerResult result;

@end

@implementation QMImagePicker

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

+ (void)presentIn:(UIViewController *)vc
        configure:(void (^)(UIImagePickerController *picker))configure
           result:(QMImagePickerResult)result {
    
    QMImagePicker *picker = [[QMImagePicker alloc] init];
    picker.result = result;
    configure(picker);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [vc presentViewController:picker animated:YES completion:nil];
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
    __weak __typeof(self)weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        weakSelf.result(image);
        weakSelf.result = nil;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    __weak __typeof(self)weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        weakSelf.result = nil;
    }];
}

+ (void)chooseSourceTypeInVC:(id)vc allowsEditing:(BOOL)allowsEditing result:(QMImagePickerResult)result {
    
    UIViewController *viewController = vc;
    
    void (^showImagePicker)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType type) {
        
        [QMImagePicker presentIn:viewController configure:^(UIImagePickerController *picker) {
            
            picker.sourceType = type;
            picker.allowsEditing = allowsEditing;
            
        } result:result];
    };
    
    
    [REActionSheet presentActionSheetInView:viewController.view configuration:^(REActionSheet *actionSheet) {
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_TAKE_NEW_PHOTO", nil)
                         andActionBlock:^{
                             showImagePicker(UIImagePickerControllerSourceTypeCamera);
                         }];
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_FROM_LIBRARY", nil)
                         andActionBlock:^{
                             showImagePicker(UIImagePickerControllerSourceTypePhotoLibrary);
                         }];
        
        [actionSheet addCancelButtonWihtTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                               andActionBlock:^{}];
    }];
}

@end
