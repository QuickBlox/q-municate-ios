//
//  QMImagePreview.m
//  Q-municate
//
//  Created by Injoit on 8/30/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMImagePreview.h"
#import "QMPhoto.h"

#import "QMChatViewController.h"
#import <NYTPhotoViewer/NYTPhotoViewer.h>

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
                                   UIImage * _Nullable  transfomedImage,
                                   NSError * _Nullable  error,
                                   SDImageCacheType  cacheType,
                                   BOOL  finished,
                                   NSURL * _Nonnull  imageURL) {
                           
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
