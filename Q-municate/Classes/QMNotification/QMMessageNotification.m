//
//  QMMessageNotification.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessageNotification.h"
#import <QMImageView.h>

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
@property (copy, nonatomic) NSURL *iconImageURL;

@end

@implementation QMMessageNotification

- (void)showNotificationWithTitle:(NSString *)title subTitle:(NSString *)subTitle iconImageURL:(NSURL *)iconImageURL placeholderImage:(UIImage *)placeholderImage buttonHandler:(MPGNotificationButtonHandler)buttonHandler {
    
    if (self.messageNotification != nil) {
        
        [self.messageNotification dismissWithAnimation:NO];
    }
    
    self.messageNotification = [MPGNotification notificationWithTitle:title subtitle:subTitle backgroundColor:backgroundColor() iconImage:placeholderImage];
    
    if (iconImageURL) {
        
        self.iconImageURL = iconImageURL;
        
        QMImageView *imageView = [[QMImageView alloc] initWithFrame:QMMessageNotificationIconRect];
        imageView.imageViewType = QMImageViewTypeCircle;
        
        @weakify(self);
        [imageView setImageWithURL:iconImageURL placeholder:placeholderImage options:SDWebImageHighPriority progress:nil completedBlock:^(UIImage *image, NSError * __unused error, SDImageCacheType __unused cacheType, NSURL * __unused imageURL) {
            
            @strongify(self);
            if ([self.iconImageURL isEqual:imageURL]) {
            
                self.messageNotification.iconImage = image;
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
    
    @weakify(self);
    self.messageNotification.dismissHandler = ^void(MPGNotification * __unused notification) {
        
        @strongify(self);
        self.iconImageURL = nil;
    };
    
    self.messageNotification.hostViewController = self.hostViewController;
    [self.messageNotification show];
}

@end
