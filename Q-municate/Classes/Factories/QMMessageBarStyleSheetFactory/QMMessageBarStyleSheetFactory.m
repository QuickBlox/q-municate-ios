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


@implementation QMMessageBarStyleSheetFactory

+ (void)showMessageBarNotificationWithMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)chatDialog completionBlock:(MPGNotificationButtonHandler)block
{
    UIImage *img = nil;
    NSString *title = @"";
    
    if (chatDialog.type ==  QBChatDialogTypeGroup) {
        
        img = [UIImage imageNamed:@"upic_placeholder_details_group"];
        title = chatDialog.name;
    }
    else if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *user = [[QMApi instance] userWithID:message.senderID];
        title = user.fullName;
        img = [UIImage imageNamed:@"upic_placeholderr"];
    }
    
    NSString *messageText = [NSString string];
    if (message.isNotificatonMessage && message.messageType != QMMessageTypeUpdateGroupDialog) {
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



@end
