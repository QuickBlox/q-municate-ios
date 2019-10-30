//
//  QMImages.m
//  Q-municate
//
//  Created by Injoit on 5/19/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIImage *QMStatusBarBackgroundImage(void) {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
