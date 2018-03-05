//
//  UIImage+Cropper.h
//  QMChatViewController
//
//  Created by Igor Alefirenko on 29/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Cropper)

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius
                        targetSize:(CGSize)targetSize;
- (UIImage *)imageByScaleAndCrop:(CGSize)targetSize;
- (UIImage *)imageByCircularScaleAndCrop:(CGSize)targetSize;

@end
