//
//  QMImagePreview.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 8/30/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMImagePreview.h"
#import <QMImageLoader.h>

#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import "QMPhoto.h"

@implementation QMImagePreview

+ (void)previewImageWithURL:(NSURL *)url inViewController:(UIViewController *)ivc {
    
    if (url == nil) {
        
        return;
    }
    
    QMPhoto *photo = [[QMPhoto alloc] init];
    
    NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
    
    if ([ivc conformsToProtocol:@protocol(NYTPhotosViewControllerDelegate)]) {
        
        photosViewController.delegate = (UIViewController<NYTPhotosViewControllerDelegate> *)ivc;
    }
    
    [ivc presentViewController:photosViewController animated:YES completion:nil];
    
    QMImageLoader *loader = [QMImageLoader instance];
    [loader downloadImageWithURL:url
                         options:SDWebImageHighPriority
                        progress:nil
                       completed:^(UIImage *image,
                                   NSError *error,
                                   SDImageCacheType __unused cacheType,
                                   BOOL __unused finished,
                                   NSURL *__unused imageURL)
     {
         if (!error && image) {
             photo.image = [loader originalImageWithURL:imageURL];
             [photosViewController updateImageForPhoto:photo];
         }
     }];
}

@end
