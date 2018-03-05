//
//  QMMessageNotification.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessageNotification.h"
#import <QMChatViewController/QMImageLoader.h>

static UIColor *backgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:0.32f green:0.33f blue:0.34f alpha:0.86f];
    });
    
    return color;
}

static const NSTimeInterval kQMMessageNotificationDuration = 2.0f;
const CGRect QMMessageNotificationIconRect = (CGRect){(CGPoint){0,0}, (CGSize){32.0f,32.0f}};

@interface QMMessageNotification ()

@property (strong, nonatomic) MPGNotification *messageNotification;
@property (weak, nonatomic) id <SDWebImageOperation> imageOperation;

@end

@implementation QMMessageNotification

- (void)showNotificationWithTitle:(NSString *)title
                         subTitle:(NSString *)subTitle
                     iconImageURL:(NSURL *)iconImageURL
                    buttonHandler:(MPGNotificationButtonHandler)buttonHandler {
    
    if (self.messageNotification != nil) {
        [self.messageNotification dismissWithAnimation:NO];
    }
    
    [self.imageOperation cancel];
    
    self.messageNotification = [MPGNotification notificationWithTitle:title
                                                             subtitle:subTitle
                                                      backgroundColor:backgroundColor()
                                                            iconImage:nil];
    
    if (iconImageURL) {
        
        @weakify(self);
        
        self.imageOperation =
        [[QMImageLoader instance]
         downloadImageWithURL:iconImageURL
         transform:[QMImageTransform transformWithType:QMImageTransformTypeCircle size:CGSizeMake(30, 30)]
         options:SDWebImageHighPriority
         progress:nil
         completed:^(UIImage * _Nullable __unused image,
                     UIImage * _Nullable transfomedImage,
                     NSError * _Nullable __unused error,
                     SDImageCacheType __unused cacheType,
                     BOOL __unused finished,
                     NSURL * _Nonnull __unused imageURL) {
             @strongify(self);
             
             if (transfomedImage != nil) {
                 self.messageNotification.iconImage = transfomedImage;
             }
         }];
    }
    
    if (buttonHandler != nil) {
        
        [self.messageNotification setButtonConfiguration:MPGNotificationButtonConfigrationOneButton withButtonTitles:@[NSLocalizedString(@"QM_STR_REPLY", nil)]];
        self.messageNotification.buttonHandler = buttonHandler;
    }
    
    self.messageNotification.duration = kQMMessageNotificationDuration;
    self.messageNotification.autoresizingMask =
    self.messageNotification.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messageNotification.fullWidthMessages = YES;
    
    self.messageNotification.hostViewController = self.hostViewController;
    [self.messageNotification show];
}

@end
