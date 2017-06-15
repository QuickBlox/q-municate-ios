//
//  QMMediaController.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 2/19/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMMediaViewDelegate.h"
#import "QMMediaPresenter.h"
#import <QMChatViewController.h>

@protocol QMMediaControllerDelegate;
@class QMChatModel;

NS_ASSUME_NONNULL_BEGIN
@interface QMMediaController : NSObject <QMChatAttachmentServiceDelegate>

@property (copy, nonatomic) void(^onError)(QBChatMessage *message, NSError *error);

- (instancetype)initWithViewController:(UIViewController<QMMediaControllerDelegate> *)controller;

- (void)configureView:(id<QMMediaViewDelegate>)view
          withMessage:(QBChatMessage *)message
           attachment:(QBChatAttachment *)attachment;

- (void)cancelOperationsForMessage:(QBChatMessage *)message;

//- (QMChatModel *)chatModelForMessageWithID:(NSString *)messageID;

@end

@protocol QMMediaControllerDelegate <NSObject>

@required

- (nullable id<QMMediaViewDelegate>)viewForMessage:(QBChatMessage *)message;
- (void)didUpdateMessage:(QBChatMessage *)message;

@end

NS_ASSUME_NONNULL_END
