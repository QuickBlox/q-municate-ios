//
//  QMNotification.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNotification.h"

@implementation QMNotification

#pragma mark - Notificaiton panel

+ (void)showNotificationWithType:(QMNotificationPanelType)notificationType message:(NSString *)message timeUntilDismiss:(NSTimeInterval)timeUntilDismiss {
    
    [notificationPanel() dismissNotificationAnimated:NO];
    notificationPanel().timeUntilDismiss = timeUntilDismiss;
    
    UINavigationController *navigationController = (UINavigationController *)[[UIApplication sharedApplication].windows.firstObject rootViewController];
    [notificationPanel() showNotificationWithType:notificationType byInsertingInNavigationBar:navigationController.navigationBar message:message];
}

+ (void)dismissNotification {
    
    [notificationPanel() dismissNotificationAnimated:YES];
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

#pragma mark - Static notifications

QMNotificationPanel *notificationPanel() {
    
    static QMNotificationPanel *notificationPanel = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        notificationPanel = [[QMNotificationPanel alloc] init];
        notificationPanel.enableTapDismiss = NO;
    });
    
    return notificationPanel;
}

@end
