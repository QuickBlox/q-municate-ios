//
//  QMMessageBarStyleSheetFactory.m
//  Q-municate
//
//  Created by Andrey Ivanov on 07.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMessageBarStyleSheetFactory.h"
#import "QMApi.h"
#import "QMChatUtils.h"
#import <SDWebImageManager.h>

@implementation QMMessageBarStyleSheetFactory

+ (void)showMessageBarNotificationWithMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)chatDialog completionBlock:(MPGNotificationButtonHandler)block
{
    UIImage *img = nil;
    NSString *title = @"";
    
    if (chatDialog.type ==  QBChatDialogTypeGroup) {
        
        img = [self imageForKey:chatDialog.photo withPlaceHolder:[UIImage imageNamed:@"upic_placeholder_details_group"]];
        title = chatDialog.name;
    }
    else if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *user = [[QMApi instance] userWithID:message.senderID];
        
        title = user.fullName;
        img = [self imageForKey:user.avatarUrl withPlaceHolder:[UIImage imageNamed:@"upic_placeholderr"]];
    }
    
    NSString *messageText = nil;
    if (message.isNotificatonMessage) {
        messageText = [QMChatUtils messageTextForNotification:message];
    }
    else {
        messageText = message.encodedText;
    }

    MPGNotification *newNotification = [MPGNotification notificationWithTitle:title subtitle:messageText backgroundColor:[UIColor colorWithRed:0.32 green:0.33 blue:0.34 alpha:0.86] iconImage:img];
    [newNotification setButtonConfiguration:MPGNotificationButtonConfigrationOneButton withButtonTitles:@[@"Reply"]];
    newNotification.duration = 2.0;
    
    newNotification.buttonHandler = block;
    [newNotification show];
}

+ (UIImage *)imageForKey:(NSString *)key withPlaceHolder:(UIImage *)placeHolder{
    
    UIImage *image = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:key];
    if (image == nil) {
        image = placeHolder;
    }
    
    return image;
}

@end
