//
//  QMNotification.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNotification.h"
#import "QMCore.h"
#import <SDWebImageManager.h>
#import "QMPlaceholder.h"
#import "QMMessageStatusStringBuilder.h"
#import "QMMessageNotification.h"
#import "REAlertView.h"
#import "REAlertView+QMSuccess.h"

static const CGFloat kQMMessageNotificationIconImageSize = 32.0;

@implementation QMNotification

#pragma mark - Message notification

+ (void)showMessageNotificationWithMessage:(QBChatMessage *)chatMessage buttonHandler:(MPGNotificationButtonHandler)buttonHandler {
    NSParameterAssert(chatMessage.dialogID);
    
    UIImage *avatarImage = nil;
    NSString *title = nil;
    
    QBChatDialog *chatDialog = [[QMCore instance].chatService.dialogsMemoryStorage chatDialogWithID:chatMessage.dialogID];
    
    if (chatDialog == nil) {
        // for some reason chat dialog was not find
        // no reason to show message notification
        return;
    }
    
    switch (chatDialog.type) {
            
        case QBChatDialogTypePrivate: {
            
            QBUUser *user = [[QMCore instance].usersService.usersMemoryStorage userWithID:chatMessage.senderID];
            
            UIImage *placeholderImage = [QMPlaceholder placeholderWithFrame:[[self class] messageNotificationIconFrame] title:user.fullName ID:user.ID];
            avatarImage = [self imageForKey:user.avatarUrl placeholderImage:placeholderImage];
            
            title = user.fullName ?: [NSString stringWithFormat:@"%tu", user.ID];
            
            break;
        }
            
        case QBChatDialogTypeGroup:
        case QBChatDialogTypePublicGroup: {
            
            UIImage *placeholderImage = [QMPlaceholder placeholderWithFrame:[[self class] messageNotificationIconFrame] title:chatDialog.name ID:chatDialog.ID.hash];
            avatarImage = [self imageForKey:chatDialog.photo placeholderImage:placeholderImage];
            
            title = chatDialog.name;
            
            break;
        }
    }
    
    NSString *messageText = chatMessage.text;
    
    if (chatMessage.isNotificatonMessage) {
        
        QMMessageStatusStringBuilder *stringBuilder = [QMMessageStatusStringBuilder new];
        messageText = [stringBuilder messageTextForNotification:chatMessage];
    }
    
    [messageNotification() showNotificationWithTitle:title
                                            subTitle:messageText
                                           iconImage:avatarImage
                                       buttonHandler:buttonHandler];
}

#pragma mark - Push notification

+ (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *message = text;
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    event.usersIDs = [NSString stringWithFormat:@"%zd", user.ID];
    event.type = QBMEventTypeOneShot;
    
    // custom params
    NSDictionary  *dictPush = @{@"message" : message,
                                @"ios_badge": @"1",
                                @"ios_sound": @"default",
                                };
    
    NSError *error = nil;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    
    event.message = jsonString;
    
    [QBRequest createEvent:event successBlock:^(QBResponse *__unused response, NSArray *__unused events) {
        
        [source setResult:nil];
        
    } errorBlock:^(QBResponse *response) {
        
        [source setError:response.error.error];
    }];
    
    return source.task;
}

#pragma mark - Helpers

+ (UIImage *)imageForKey:(NSString *)key placeholderImage:(UIImage *)placeholderImage {
    
    UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:key];
    
    if (image == nil) {
        
        image = placeholderImage;
    }
    
    return image;
}

+ (CGRect)messageNotificationIconFrame {
    
    return CGRectMake(0,
                      0,
                      kQMMessageNotificationIconImageSize,
                      kQMMessageNotificationIconImageSize);
}

#pragma mark - Static notifications

QMMessageNotification *messageNotification() {
    
    static QMMessageNotification *messageNotification = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        messageNotification = [[QMMessageNotification alloc] init];
    });
    
    return messageNotification;
}

@end
