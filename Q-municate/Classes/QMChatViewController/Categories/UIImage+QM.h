//
//  UIImage+QM.h
//  QMChatViewController
//
//  Created by Injoit on 20.04.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QM)

/**
 *  Adds color mask to image
 *
 *  @param maskColor color for mask
 *
 *  @return masked image
 */
- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor;

/**
 *  Creates a resizable image with specified color and corner radius
 *
 *  @param color color for mask
 *
 *  @return masked image
 */
+ (UIImage *)resizableImageWithColor:(UIColor *)color
                        cornerRadius:(CGFloat)cornerRadius;

@property (nonatomic, strong, readonly) NSData *dataRepresentation;

@end
