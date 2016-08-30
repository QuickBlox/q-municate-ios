//
//  QMImagePreview.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 8/30/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMImagePreview.h"
#import <QMImageView.h>

#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import "QMPhoto.h"

@implementation QMImagePreview

+ (void)updateImageForImageView:(QMImageView *)imageView completion:(void(^)(UIImage *originalImage))completion {
    
    NSURL *url = imageView.url;
    [imageView removeImage];
    
    __weak QMImageView *weakImageView = imageView;
    [imageView setImageWithURL:url
                   placeholder:nil
                       options:SDWebImageHighPriority
                      progress:nil
                completedBlock:^(UIImage * __unused image, NSError * __unused error, SDImageCacheType __unused cacheType, NSURL * __unused imageURL) {
                    
                    completion([weakImageView originalImage]);
                }];
}

+ (void)previewImageView:(QMImageView *)imageView inViewController:(UIViewController *)ivc {
    
    QMPhoto *photo = [[QMPhoto alloc] init];
    photo.image = [imageView originalImage];
    
    NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
    
    if ([ivc conformsToProtocol:@protocol(NYTPhotosViewControllerDelegate)]) {
        
        photosViewController.delegate = (UIViewController<NYTPhotosViewControllerDelegate> *)ivc;
    }
    
    [ivc presentViewController:photosViewController animated:YES completion:nil];
    
    if (photo.image == nil) {
        
        [self updateImageForImageView:imageView completion:^(UIImage *originalImage) {
            
            photo.image = originalImage;
            [photosViewController updateImageForPhoto:photo];
        }];
    }
}

@end
