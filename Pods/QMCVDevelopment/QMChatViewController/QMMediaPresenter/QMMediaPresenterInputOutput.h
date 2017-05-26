//
//  QMMediaPresenterInput.h
//  QMPLayer
//
//  Created by Vitaliy Gurkovsky on 1/30/17.
//  Copyright © 2017 quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMChatModel.h"

@class QBChatMessage;
@class QBChatAttachment;


@protocol QMMediaPresenterInput <NSObject>

@property (copy, nonatomic) NSString *attachmentID;
@property (strong, nonatomic) QBChatMessage *message;
@property (nonatomic, strong) QMChatModel *model;

- (void)didTapContainer;
- (void)requestForMedia;
- (void)activateMedia;

@end

@protocol QMMediaPresenterOutput <NSObject>

- (void)didUpdateIsReady:(BOOL)isReady;
- (void)didUpdateIsActive:(BOOL)isActive;

- (void)didUpdateOffset:(NSTimeInterval)offset;
- (void)didUpdateDuration:(NSTimeInterval)duration;
- (void)didUpdateProgress:(CGFloat)progress;
- (void)didUpdateCurrentTime:(NSTimeInterval)currentTime
                    duration:(NSTimeInterval)duration;

- (void)didUpdateThumbnailImage:(UIImage *)image;
- (void)didUpdateImage:(UIImage *)image;

- (void)didUpdateLoadingProgress:(CGFloat)loadingProgress;

- (void)didOccureUploadError:(NSError *)error;
- (void)didOccureDownloadError:(NSError *)error;

@end

