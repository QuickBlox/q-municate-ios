//
//  QMImageView.h
//  QMChatViewController
//
//  Created by Injoit on 27.06.14.
//  Copyright © 2014 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMImageLoader.h"

@protocol QMImageViewDelegate ;

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
@property (weak, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic, readonly) NSURL *url;

@property (weak, nonatomic) id <QMImageViewDelegate> delegate;

- (void)setImageWithURL:(NSURL *)url;

- (void)setImageWithURL:(NSURL *)url
            placeholder:(UIImage *)placehoder
                options:(SDWebImageOptions)options
               progress:(SDImageLoaderProgressBlock)progress
         completedBlock:(SDExternalCompletionBlock)completedBlock;

- (void)setImageWithURL:(NSURL *)url
                  title:(NSString *)title
         completedBlock:(SDExternalCompletionBlock)completedBlock;

- (UIImage *)originalImage;

@end

@protocol QMImageViewDelegate <NSObject>

- (void)imageViewDidTap:(QMImageView *)imageView;

@end
