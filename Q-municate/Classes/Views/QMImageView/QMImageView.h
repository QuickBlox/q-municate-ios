//
//  QMImageView.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"

typedef NS_ENUM(NSUInteger, QMImageViewType) {
    QMImageViewTypeNone,
    QMImageViewTypeCircle,
    QMImageViewTypeSquare
};

@interface QMImageView : UIImageView
/**
 Default QMUserImageViewType QMUserImageViewTypeNone
 */
@property (assign, nonatomic) QMImageViewType imageViewType;

+ (void)imageWithURL:(NSURL *)url
                size:(CGSize)size
            progress:(SDWebImageDownloaderProgressBlock)progress
                type:(QMImageViewType)type
          completion:(void (^)(UIImage *img))completion;

- (void)sd_setImage:(UIImage *)image withKey:(NSString *)key;
- (void)sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placehoderImage;
- (void)sd_setImageWithURL:(NSURL *)url progress:(SDWebImageDownloaderProgressBlock)progress placeholderImage:(UIImage *)placehoderImage;
@end
