//
//  QMImageView.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"
IB_DESIGNABLE
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
@property (nonatomic) IBInspectable CGFloat borderWidth;

- (void)sd_setImage:(UIImage *)image withKey:(NSString *)key;
- (void)setImageWithURL:(NSURL *)url
            placeholder:(UIImage *)placehoder
                options:(SDWebImageOptions)options
               progress:(SDWebImageDownloaderProgressBlock)progress
         completedBlock:(SDWebImageCompletionBlock)completedBlock;
@end
