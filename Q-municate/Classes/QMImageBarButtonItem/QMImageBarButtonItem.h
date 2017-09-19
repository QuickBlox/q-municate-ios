//
//  QMImageBarButtonItem.h
//  Q-municate
//
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMImageBarButtonItem : UIBarButtonItem

typedef void(^QMImageViewTapBlock)(QMImageView *imageView);

@property (nonatomic, strong, readonly) QMImageView *imageView;
@property (nonatomic, copy, nullable) QMImageViewTapBlock onTapHandler;
@property (nonatomic, assign) CGSize size;

- (void)setImageWithURL:(NSURL *)imageURL
                  title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
