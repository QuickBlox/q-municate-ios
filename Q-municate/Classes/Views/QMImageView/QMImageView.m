//
//  QMImageView.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMImageView.h"
#import "UIImage+Cropper.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

@interface QMImageView() <SDWebImageManagerDelegate>

@end

@implementation QMImageView

- (void)awakeFromNib {
    [super awakeFromNib];
}


- (NSString *)keyWithURL:(NSURL *)url size:(CGSize)size {
    
    NSString* prefix = NSStringFromCGSize(size);
    NSString *key = [NSString stringWithFormat:@"%@-forSize-%@", url.absoluteString, prefix];
    
    return key;
}

- (void)sd_setImageWithURL:(NSURL *)url progress:(SDWebImageDownloaderProgressBlock)progress placeholderImage:(UIImage *)placehoderImage completed:(SDWebImageCompletionBlock)completedBlock  {
    
    __weak __typeof(self)weakSelf = self;
    
    [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *t_url) {
        return [weakSelf keyWithURL:t_url size:weakSelf.frame.size];
        
    }];
    
    [SDWebImageManager sharedManager].delegate = self;
    
    [self sd_setImageWithURL:url placeholderImage:placehoderImage
                     options:SDWebImageHighPriority
                    progress:progress
                   completed:completedBlock];
}

- (void)sd_setImageWithURL:(NSURL *)url progress:(SDWebImageDownloaderProgressBlock)progress placeholderImage:(UIImage *)placehoderImage {
    
    [self sd_setImageWithURL:url progress:progress placeholderImage:placehoderImage completed:nil];
    
};

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL {
    
    return [self transformImage:image];
}

- (UIImage *)transformImage:(UIImage *)image {
    
    if (self.imageViewType == QMImageViewTypeSquare) {
        return [image imageByScaleAndCrop:self.frame.size];
    }
    else if (self.imageViewType == QMImageViewTypeCircle) {
        return [image imageByCircularScaleAndCrop:self.frame.size];
    } else {
        return image;
    }
}

- (void)sd_setImage:(UIImage *)image withKey:(NSString *)key {
    
    UIImage *cachedImage = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:key];
    if (cachedImage) {
        self.image = cachedImage;
    }
    else {

        UIImage *img = [self transformImage:image];
        [[[SDWebImageManager sharedManager] imageCache] storeImage:img forKey:key];
        self.image = img;
    }
}

@end
