//
//  QMMediaViewDelegate.h
//  QMPLayer
//
//  Created by Vitaliy Gurkovsky on 1/30/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMMediaPresenterDelegate.h"

@protocol QMMediaViewDelegate <NSObject>

@required

@property (strong, nonatomic) id <QMMediaPresenterDelegate> presenter;

@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isActive;

@optional

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *image;

- (void)showLoadingError:(NSError *)error;
- (void)showUploadingError:(NSError *)error;

@end
