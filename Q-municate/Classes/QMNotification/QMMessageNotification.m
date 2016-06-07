//
//  QMMessageNotification.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMMessageNotification.h"

static UIColor *backgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:0.32f green:0.33f blue:0.34f alpha:0.86f];
    });
    
    return color;
}

static const NSTimeInterval kQMMessageNotificationDuration = 2.0f;

@interface QMMessageNotification ()

@property (strong, nonatomic) MPGNotification *messageNotification;

@end

@implementation QMMessageNotification

- (void)showNotificationWithTitle:(NSString *)title subTitle:(NSString *)subTitle iconImage:(UIImage *)iconImage buttonHandler:(MPGNotificationButtonHandler)buttonHandler {
    
    if (self.messageNotification != nil) {
        
        [self.messageNotification dismissWithAnimation:NO];
    }
    
    self.messageNotification = [MPGNotification notificationWithTitle:title subtitle:subTitle backgroundColor:backgroundColor() iconImage:iconImage];
    [self.messageNotification setButtonConfiguration:MPGNotificationButtonConfigrationOneButton withButtonTitles:@[NSLocalizedString(@"QM_STR_REPLY", nil)]];
    self.messageNotification.duration = kQMMessageNotificationDuration;
    self.messageNotification.buttonHandler = buttonHandler;
    self.messageNotification.autoresizingMask =
    self.messageNotification.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.messageNotification.fullWidthMessages = YES;
    
    [self.messageNotification show];
}

@end
