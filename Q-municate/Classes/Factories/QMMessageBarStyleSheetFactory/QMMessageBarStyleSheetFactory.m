//
//  QMMessageBarStyleSheetFactory.m
//  Q-municate
//
//  Created by Andrey Ivanov on 07.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMessageBarStyleSheetFactory.h"
#import "QMApi.h"


@implementation QMMessageBarStyleSheetFactory

+ (void)showMessageBarNotificationWithMessage:(QBChatAbstractMessage *)chatMessage chatDialog:(QBChatDialog *)chatDialog completionBlock:(MPGNotificationButtonHandler)block
{
    UIImage *img = nil;
    NSString *title = nil;
    
    if (chatDialog.type ==  QBChatDialogTypeGroup) {
        
        img = [UIImage imageNamed:@"upic_placeholder_details_group"];
        title = chatDialog.name;
    }
    else if (chatDialog.type == QBChatDialogTypePrivate) {
        
        NSUInteger occupantID = [[QMApi instance] occupantIDForPrivateChatDialog:chatDialog];
        QBUUser *user = [[QMApi instance] userWithID:occupantID];
        title = user.fullName;
        img = [UIImage imageNamed:@"upic_placeholderr"];
    }

    MPGNotification *newNotification = [MPGNotification notificationWithTitle:title subtitle:chatMessage.encodedText backgroundColor:[UIColor colorWithRed:0.32 green:0.33 blue:0.34 alpha:0.86] iconImage:img];
    [newNotification setButtonConfiguration:MPGNotificationButtonConfigrationOneButton withButtonTitles:@[@"Reply"]];
    newNotification.duration = 2.0;
    
    newNotification.buttonHandler = block;
    [newNotification show];
}



@end
