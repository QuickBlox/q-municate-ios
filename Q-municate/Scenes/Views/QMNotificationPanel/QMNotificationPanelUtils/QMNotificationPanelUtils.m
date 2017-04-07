//
//  QMNotificationUtils.m
//  municate
//
//  Created by Vitaliy Gorbachov on 3/22/16.
//  Copyright © 2016 Vitaliy Gorbachov. All rights reserved.
//

#import "QMNotificationPanelUtils.h"

//MARK: - Images

UIImage *successImage() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-notification-success"];
    });
    
    return image;
}

UIImage *warningImage() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-notification-warning"];
    });
    
    return image;
}

UIImage *failImage() {
    
    static UIImage *image = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        image = [UIImage imageNamed:@"qm-ic-notification-fail"];
    });
    
    return image;
}

//MARK: - Colors

UIColor *successColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [[UIColor colorWithRed:35.0f/255.0f green:160.0f/255.0f blue:73.0f/255.0f alpha:1.0f] colorWithAlphaComponent:0.6f];
    });
    
    return color;
}

UIColor *warningColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [[UIColor colorWithRed:249.0f/255.0f green:169.0f/255.0f blue:69.0f/255.0f alpha:1.0f] colorWithAlphaComponent:0.6f];
    });
    
    return color;
}

UIColor *failedColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [[UIColor colorWithRed:1.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1.0f] colorWithAlphaComponent:0.6f];
    });
    
    return color;
}

UIColor *loadingColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [[UIColor colorWithRed:91.0f/255.0f green:184.0f/255.0f blue:230.0f/255.0f alpha:1.0f] colorWithAlphaComponent:0.6f];
    });
    
    return color;
}
