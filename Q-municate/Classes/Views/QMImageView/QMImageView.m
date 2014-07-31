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

@property (strong, nonatomic, readonly) SDImageCache *imageCache;

@end

@implementation QMImageView

@dynamic imageCache;


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (SDImageCache *)imageCache {
    
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

- (NSString *)keyWithURL:(NSURL *)url {
    
    NSString* prefix = NSStringFromCGSize(self.frame.size);
    NSString *key = [NSString stringWithFormat:@"%@-forSize-%@", url.absoluteString, prefix];
    
    return key;
}

- (void)sd_setImageWithURL:(NSURL *)url progress:(SDWebImageDownloaderProgressBlock)progress placeholderImage:(UIImage *)placehoderImage {
    
    self.image = placehoderImage;
    
    NSString *key = [self keyWithURL:url];
    UIImage *cachedImage = [self.imageCache imageFromDiskCacheForKey:key];
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
                 [weakSelf storeImage:image withKey:key];
             }
         }];
    }
};

- (void)storeImage:(UIImage *)image withKey:(NSString *)key {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        UIImage *resultImage = image;
        
        if (self.imageViewType == QMImageViewTypeSquare) {
            resultImage = [resultImage imageByScaleAndCrop:self.frame.size];
        }
        else if (self.imageViewType == QMImageViewTypeCircle) {
            resultImage = [resultImage imageByCircularScaleAndCrop:self.frame.size];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = resultImage;
            [self.imageCache storeImage:resultImage forKey:key];
        });
    });
}

- (void)sd_setImage:(UIImage *)image withKey:(NSString *)key {

    UIImage *cachedImage = [self.imageCache imageFromDiskCacheForKey:key];
    if (cachedImage) {
        self.image = cachedImage;
    }
    else {
        [self storeImage:image withKey:key];
    }

}

@end
