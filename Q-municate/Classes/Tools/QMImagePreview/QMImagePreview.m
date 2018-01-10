//
//  QMImagePreview.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 8/30/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMImagePreview.h"
#import <QMImageLoader.h>

#import <NYTPhotoViewer/NYTPhotoViewer.h>
#import "QMPhoto.h"

@implementation QMImagePreview

+ (void)previewImageWithURL:(NSURL *)url inViewController:(UIViewController *)ivc {
    
    if (url == nil) {
        
        return;
    }
    
    QMPhoto *photo = [[QMPhoto alloc] init];
    NYTPhotoViewerSinglePhotoDataSource *photoDataSource =
    [NYTPhotoViewerSinglePhotoDataSource dataSourceWithPhoto:photo];
    
    NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithDataSource:photoDataSource];
    
    if ([ivc conformsToProtocol:@protocol(NYTPhotosViewControllerDelegate)]) {
        photosViewController.delegate = (UIViewController<NYTPhotosViewControllerDelegate> *)ivc;
    }
    
    [ivc presentViewController:photosViewController animated:YES completion:nil];
    
    QMImageLoader *loader = [QMImageLoader instance];
    
    [loader downloadImageWithURL:url
                       transform:nil
                         options:SDWebImageHighPriority
                        progress:nil
                       completed:^(UIImage * _Nullable image,
                                   UIImage * _Nullable __unused transfomedImage,
                                   NSError * _Nullable  error,
                                   SDImageCacheType __unused cacheType,
                                   BOOL __unused finished,
                                   NSURL * _Nonnull __unused imageURL) {
                           
                           if (!error && image) {
                               photo.image = [loader originalImageWithURL:imageURL];
                               NYTPhotoViewerSinglePhotoDataSource *updatedPhotoDataSource =
                               [NYTPhotoViewerSinglePhotoDataSource dataSourceWithPhoto:photo];
                               
                               photosViewController.dataSource = updatedPhotoDataSource;
                               [photosViewController reloadPhotosAnimated:YES];
                           }
                       }];
}

@end
