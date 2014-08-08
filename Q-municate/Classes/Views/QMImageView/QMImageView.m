//
//  QMImageView.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImageView.h"
#import "UIImage+Cropper.h"

NSString *const kQMAvatarsImageCacheName = @"qm.images.cache";

@interface QMImageView()


@end

@implementation QMImageView

- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (SDImageCache *)imageCache {
    
    static dispatch_once_t onceToken;
    static  SDImageCache *_imageCache = nil;
    dispatch_once(&onceToken, ^{
        _imageCache = [[SDImageCache alloc] initWithNamespace:kQMAvatarsImageCacheName];
    });
    return _imageCache;
}

- (void)sd_setImageWithURL:(NSURL *)url  placeholderImage:(UIImage *)placehoderImage {
    [self sd_setImageWithURL:url progress:nil placeholderImage:placehoderImage];
}

+ (NSString *)keyWithURL:(NSURL *)url size:(CGSize)size {
    
    NSString* prefix = NSStringFromCGSize(size);
    NSString *key = [NSString stringWithFormat:@"%@-forSize-%@", url.absoluteString, prefix];
    
    return key;
}

- (void)sd_setImageWithURL:(NSURL *)url progress:(SDWebImageDownloaderProgressBlock)progress placeholderImage:(UIImage *)placehoderImage {
    
    self.image = placehoderImage;
    
    NSString *key = [QMImageView keyWithURL:url size:self.frame.size];
    UIImage *cachedImage = [QMImageView.imageCache imageFromDiskCacheForKey:key];
    if (cachedImage) {
        self.image = cachedImage;
    }
    else {
        
        __weak __typeof(self)weakSelf = self;
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url
                                                            options:0
                                                           progress:progress
                                                          completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             
             if (image && finished) {
                 [QMImageView storeImage:image size:weakSelf.image.size type:weakSelf.imageViewType key:key completion:^(UIImage *img) {
                     weakSelf.image = img;
                 }];
             }
         }];
    }
};


- (void)sd_setImage:(UIImage *)image withKey:(NSString *)key {

    UIImage *cachedImage = [QMImageView.imageCache imageFromDiskCacheForKey:key];
    if (cachedImage) {
        self.image = cachedImage;
    }
    else {
        __weak __typeof(self)weakSelf = self;
        [QMImageView storeImage:image size:self.frame.size type:self.imageViewType key:key completion:^(UIImage *img) {
            weakSelf.image = img;
        }];
    }

}

+ (void)imageWithURL:(NSURL *)url
                size:(CGSize)size
            progress:(SDWebImageDownloaderProgressBlock)progress
                type:(QMImageViewType)type
          completion:(void (^)(UIImage *img))completion {
    
    NSString *key = [QMImageView keyWithURL:url size:size];
    UIImage *cachedImage = [QMImageView.imageCache imageFromDiskCacheForKey:key];
    if (cachedImage) {
        completion(cachedImage);
    }
    else {
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url
                                                            options:0
                                                           progress:progress
                                                          completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             
             if (image && finished) {
                 [QMImageView storeImage:image size:size type:type key:key completion:completion];
             }
         }];
    }
}

+ (void)storeImage:(UIImage *)image size:(CGSize)size type:(QMImageViewType)type key:(NSString *)key completion:(void (^)(UIImage *img))completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        UIImage *resultImage = image;
        
        if (type == QMImageViewTypeSquare) {
            resultImage = [resultImage imageByScaleAndCrop:size];
        }
        else if (type == QMImageViewTypeCircle) {
            resultImage = [resultImage imageByCircularScaleAndCrop:size];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [QMImageView.imageCache storeImage:resultImage forKey:key];
            completion(resultImage);
        });
    });

}

@end
