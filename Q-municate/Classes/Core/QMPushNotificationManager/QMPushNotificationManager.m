//
//  QMPushNotificationManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMPushNotificationManager.h"
#import "QMCore.h"

static NSString * const kQMNotificationActionTextAction = @"TEXT_ACTION";
static NSString * const kQMNotificationCategoryReply = @"TEXT_REPLY";

typedef void(^QBTokenCompletionBlock)(NSData *token, NSError *error);

@interface QMPushNotificationManager ()

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;
@property (copy, nonatomic) QBTokenCompletionBlock tokenCompletionBlock;
@property (copy, nonatomic, nullable, readwrite) NSData *deviceToken;
@end

@implementation QMPushNotificationManager

@dynamic serviceManager;

- (BFTask *)unregisterFromPushNotificationsAndUnsubscribe:(BOOL)shouldUnsubscribe {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    if (shouldUnsubscribe) {
        [[self unSubscribeFromPushNotifications] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            
            if (t.error) {
                [source setError:t.error];
            }
            else {
                [[UIApplication sharedApplication] unregisterForRemoteNotifications];
                [source setResult:nil];
            }
            
            return source.task;
        }];
    }
    else {
        
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [source setResult:nil];
    }
    
    return source.task;
    
}

- (void)getDeviceTokenWithCompletion:(QBTokenCompletionBlock)tokenCompletionBlock {
    
    _tokenCompletionBlock = [tokenCompletionBlock copy];
    [self registerForPushNotifications];
}

//MARK: - Subscriptions
- (BFTask *)getDeviceToken {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    [self getDeviceTokenWithCompletion:^(NSData *token, NSError *error) {
        if (token.length) {
            [source setResult:token];
        }
        else {
            [source setError:error];
        }
    }];
    
    return source.task;
}

- (BFTask *)registerAndSubscribeForPushNotifications {
    
    return [[self getDeviceToken] continueWithBlock:^id _Nullable(BFTask * _Nonnull getDeviceTokenTask) {
        if (getDeviceTokenTask.error) {
            return [BFTask taskWithError:getDeviceTokenTask.error];
        }
        return [self subscribeForPushNotifications];
    }];
}

- (BFTask *)subscribeForPushNotifications {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = self.deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse * _Nonnull __unused response, NSArray<QBMSubscription *> * _Nullable __unused objects) {
     
        subscription.deviceToken = self.deviceToken;
        [source setResult:subscription];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        [source setError:response.error.error];
    }];
    
    return source.task;
}

- (BFTask *)unSubscribeFromPushNotifications {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier
                                                  successBlock:^(QBResponse * _Nonnull __unused response)
     {
         [source setResult:nil];
     } errorBlock:^(QBError * _Nullable error) {
         [source setError:error.error];
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

- (void)registerForPushNotifications {
    
    NSSet *categories = nil;
    if (iosMajorVersion() > 8) {
        // text input reply is ios 9 +
        UIMutableUserNotificationAction *textAction = [[UIMutableUserNotificationAction alloc] init];
        textAction.identifier = kQMNotificationActionTextAction;
        textAction.title = NSLocalizedString(@"QM_STR_REPLY", nil);
        textAction.activationMode = UIUserNotificationActivationModeBackground;
        textAction.authenticationRequired = NO;
        textAction.destructive = NO;
        textAction.behavior = UIUserNotificationActionBehaviorTextInput;
        
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        category.identifier = kQMNotificationCategoryReply;
        [category setActions:@[textAction] forContext:UIUserNotificationActionContextDefault];
        [category setActions:@[textAction] forContext:UIUserNotificationActionContextMinimal];
        
        categories = [NSSet setWithObject:category];
    }
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings
                                                        settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                        categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    
}


- (void)handleActionWithIdentifier:(NSString *)identifier
                remoteNotification:(NSDictionary *)userInfo
                      responseInfo:(NSDictionary *)responseInfo
                 completionHandler:(dispatch_block_t)completionHandler {
    
    if ([identifier isEqualToString:kQMNotificationActionTextAction]) {
   
        NSString *text = responseInfo[UIUserNotificationActionResponseTypedTextKey];
        
        NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
        if ([text stringByTrimmingCharactersInSet:whiteSpaceSet].length == 0) {
            // do not send message that contains only of spaces
            if (completionHandler) {
                
                completionHandler();
            }
            return;
        }
        
        NSString *dialogID = userInfo[kQMPushNotificationDialogIDKey];
        
        UIApplication *application = [UIApplication sharedApplication];
        
        __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
            
            [application endBackgroundTask:task];
            task = UIBackgroundTaskInvalid;
        }];
        
        // Do the work associated with the task.
        ILog(@"Started background task timeremaining = %f", [application backgroundTimeRemaining]);
        
        [[[QMCore instance].chatService fetchDialogWithID:dialogID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
            
            QBChatDialog *chatDialog = t.result;
            if (chatDialog != nil) {
                
                NSUInteger opponentUserID = [userInfo[kQMPushNotificationUserIDKey] unsignedIntegerValue];
                
                if (chatDialog.type == QBChatDialogTypePrivate
                    && ![[QMCore instance].contactManager isFriendWithUserID:opponentUserID]) {
                    
                    if (completionHandler) {
                        
                        completionHandler();
                    }
                    
                    return nil;
                }
                
                return [[[QMCore instance].chatManager sendBackgroundMessageWithText:text toDialogWithID:dialogID] continueWithBlock:^id _Nullable(BFTask * _Nonnull messageTask) {
                    
                    if (!messageTask.isFaulted
                        && application.applicationIconBadgeNumber > 0) {
                        
                        application.applicationIconBadgeNumber = 0;
                    }
                    
                    [application endBackgroundTask:task];
                    task = UIBackgroundTaskInvalid;
                    
                    return nil;
                }];
            }
            
            return nil;
        }];
        
        if (completionHandler) {
            
            completionHandler();
        }
    }
}

- (void)updateToken:(NSData *)token {
    
    self.deviceToken = token;
    
    if (_tokenCompletionBlock) {
        _tokenCompletionBlock(token, nil);
        _tokenCompletionBlock = nil;
    }
}

- (void)handleError:(NSError *)error {
    
    if (_tokenCompletionBlock) {
        _tokenCompletionBlock(nil, error);
        _tokenCompletionBlock = nil;
    }
}

@end
