//
//  QMMediaController.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 2/19/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMMediaViewDelegate.h"
#import <QMChatViewController.h>

@protocol QMMediaControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface QMMediaController : NSObject <QMChatAttachmentServiceDelegate>

@property (copy, nonatomic) void(^onError)(QBChatMessage *message, NSError *error);

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithViewController:(UIViewController<QMMediaControllerDelegate> *)controller;

- (void)configureView:(id<QMMediaViewDelegate>)view
          withMessage:(QBChatMessage *)message;

- (void)cancelOperationsForMessage:(QBChatMessage *)message;
- (void)didFinishPickingPhoto:(UIImage *)pickedPhoto;
- (void)didTapContainer:(id<QMMediaViewDelegate>)view;

@end

@protocol QMMediaControllerDelegate <NSObject>

@required

- (nullable id<QMMediaViewDelegate>)viewForMessage:(QBChatMessage *)message;
- (void)didUpdateMessage:(QBChatMessage *)message;
- (NSString *)dialogID;
- (void)sendAttachmentMessageWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
