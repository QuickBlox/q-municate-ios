//
//  QMNotificationManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/26/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNotificationManager.h"
#import "QMCore.h"

@interface QMNotificationManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;

@property (strong, nonatomic) QMNotificationPanel *notificationPanel;

@end

@implementation QMNotificationManager

@dynamic serviceManager;

- (void)serviceWillStart {
    
    self.notificationPanel = [[QMNotificationPanel alloc] init];
}

#pragma mark - Instances

- (QBChatMessage *)contactRequestNotificationForUser:(QBUUser *)user {
    
    QBChatMessage *notification = notificationForUser(user);
    notification.messageType = QMMessageTypeContactRequest;
    
    return notification;
}

- (QBChatMessage *)removeContactNotificationForUser:(QBUUser *)user {
    
    QBChatMessage *notification = notificationForUser(user);
    notification.messageType = QMMessageTypeDeleteContactRequest;
    
    return notification;
}

#pragma mark - Notificaiton panel

- (void)showNotificationWithType:(QMNotificationPanelType)notificationType message:(NSString *)message timeUntilDismiss:(NSTimeInterval)timeUntilDismiss {
    
    self.notificationPanel.timeUntilDismiss = timeUntilDismiss;
    
    UINavigationController *navigationController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [self.notificationPanel showNotificationWithType:notificationType belowNavigation:navigationController message:message];
}

- (void)dismissNotification {
    
    [self.notificationPanel dismissNotification];
}

#pragma mark - Notification management

- (BFTask *)sendPushNotificationToUser:(QBUUser *)user withText:(NSString *)text {
    
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

static inline QBChatMessage *notificationForUser(QBUUser *user) {
    
    QBChatMessage *notification = [QBChatMessage message];
    notification.recipientID = user.ID;
    notification.text = kQMContactRequestNotificationMessage;
    notification.dateSent = [NSDate date];
    
    return notification;
}

@end
