//
//  QMDevice.m
//  Q-municate
//
//  Created by Igor Alefirenko on 02.02.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMDevice.h"

@implementation QMDevice

+ (BOOL)isIphone6
{
    CGSize rectSize = [UIScreen mainScreen].bounds.size;
    return rectSize.width == 375.0f;
}

+ (BOOL)isIphone6Plus
{
    CGSize rectSize = [UIScreen mainScreen].bounds.size;
    return rectSize.width == 414.0f;
}

@end
