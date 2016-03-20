//
//  QMNotifications.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNotifications.h"
#import "QMCore.h"
#import "QMProfile.h"

@implementation QMNotifications

+ (QBChatMessage *)contactRequestNotificationForUser:(QBUUser *)user withChatDialog:(QBChatDialog *)chatDialog {
    
    QBChatMessage *notification = [QBChatMessage message];
    notification.recipientID = user.ID;
    notification.senderID = [QMCore instance].currentProfile.userData.ID;
    notification.text = @"Contact request";  // contact request
    notification.dateSent = [NSDate date];
    notification.messageType = QMMessageTypeContactRequest;
    
    [notification updateCustomParametersWithDialog:chatDialog];
    
    return notification;
}

+ (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *message = text;
    QBMEvent *event = [QBMEvent event];
    event.notificationType = QBMNotificationTypePush;
    event.usersIDs = [NSString stringWithFormat:@"%zd", user.ID];
    event.type = QBMEventTypeOneShot;
    //
    // custom params
    NSDictionary  *dictPush = @{@"message" : message,
                                @"ios_badge": @"1",
                                @"ios_sound": @"default",
                                };
    //
    NSError *error = nil;
    NSData *sendData = [NSJSONSerialization dataWithJSONObject:dictPush options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:sendData encoding:NSUTF8StringEncoding];
    //
    event.message = jsonString;
    
    [QBRequest createEvent:event successBlock:^(QBResponse *__unused response, NSArray *__unused events) {
        
        [source setResult:nil];
    } errorBlock:^(QBResponse *response) {
        
        [source setError:response.error.error];
    }];
    
    return source.task;
}

@end
