//
//  QMImageView.h
//  Qmunicate
//
//  Created by Andrey on 27.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

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

@end
