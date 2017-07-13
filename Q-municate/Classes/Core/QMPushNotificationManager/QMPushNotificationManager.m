//
//  QMPushNotificationManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMPushNotificationManager.h"
#import "QMCore.h"

@interface QMPushNotificationManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;

@end

@implementation QMPushNotificationManager

@dynamic serviceManager;

//MARK: - Subscriptions

- (BFTask *)subscribeForPushNotifications {
    
    if (self.serviceManager.currentProfile.pushNotificationsEnabled) {
        // push notifications already enabled
        return nil;
    }
    
    if (self.deviceToken == nil) {
        // device token should exist
        return nil;
    }
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = self.deviceToken;
    
    self.serviceManager.currentProfile.pushNotificationsEnabled = YES;
    
    @weakify(self);
    [QBRequest createSubscription:subscription successBlock:^(QBResponse * _Nonnull __unused response, NSArray<QBMSubscription *> * _Nullable __unused objects) {
        
        @strongify(self);
        [self.serviceManager.currentProfile synchronize];
        
        [source setResult:nil];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        @strongify(self);
        self.serviceManager.currentProfile.pushNotificationsEnabled = NO;
        [source setError:response.error.error];
    }];
    
    return source.task;
}

- (BFTask *)unSubscribeFromPushNotifications {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    @weakify(self);
    void (^disablePushNotifications)(void) = ^(void) {
        
        @strongify(self);
        self.serviceManager.currentProfile.pushNotificationsEnabled = NO;
        [self.serviceManager.currentProfile synchronize];
        [source setResult:nil];
    };
    
    NSString *deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse * _Nonnull __unused response) {
        
        disablePushNotifications();
        
    } errorBlock:^(QBError * _Nullable error) {
        
        if (error.reasons == nil) {
            // successful unsubscribe
            disablePushNotifications();
        }
        else {
            
            [source setError:error.error];
        }
    }];
    
    return source.task;
}

//MARK: - Push notification handling

- (void)handlePushNotificationWithDelegate:(id<QMPushNotificationManagerDelegate>)delegate {
    
    if (self.serviceManager.currentProfile.userData == nil) {
        // user is not logged in
        return;
    }
    
    if (self.pushNotification == nil) {
        
        return;
    }
    
    NSString *dialogID = self.pushNotification[kQMPushNotificationDialogIDKey];
    if (dialogID == nil) {
        NSAssert(nil, @"Push notification should contain dialog ID in user info.");
        return;
    }
    
    __block QBChatDialog *chatDialog = nil;
    
    @weakify(self);
    [[[[self.serviceManager.chatService fetchDialogWithID:dialogID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        @strongify(self);
        if (task.result != nil) {
            
            chatDialog = task.result;
            
            return [self.serviceManager.usersService getUsersWithIDs:task.result.occupantIDs];
        }
        
        if ([delegate respondsToSelector:@selector(pushNotificationManagerDidStartLoadingDialogFromServer:)]) {
            
            [delegate pushNotificationManagerDidStartLoadingDialogFromServer:self];
        }
        
        return [self.serviceManager.chatService loadDialogWithID:dialogID];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        @strongify(self);
        if (task.isFaulted) {
            
            if ([delegate respondsToSelector:@selector(pushNotificationManager:didFailFetchingDialogWithError:)]) {
                
                [delegate pushNotificationManager:self didFailFetchingDialogWithError:task.error];
            }
        }
        else {
            
            if ([task.result isKindOfClass:[QBChatDialog class]]) {
                
                if ([delegate respondsToSelector:@selector(pushNotificationManagerDidFinishLoadingDialogFromServer:)]) {
                    
                    [delegate pushNotificationManagerDidFinishLoadingDialogFromServer:self];
                }
                
                chatDialog = (QBChatDialog *)task.result;
                
                return [self.serviceManager.usersService getUsersWithIDs:chatDialog.occupantIDs];
            }
        }
        
        return nil;
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        [delegate pushNotificationManager:self didSucceedFetchingDialog:chatDialog];
        
        return nil;
    }];
}

- (void)setDeviceToken:(NSData *)deviceToken {
    
    if (_deviceToken != deviceToken) {
        _deviceToken = deviceToken;
        [self subscribeForPushNotifications];
    }
}

@end
