//
//  QMPushNotificationManager.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMPushNotificationManager.h"
#import "QMCore.h"
#import "QMHelpers.h"

static NSString * const kQMNotificationActionTextAction = @"TEXT_ACTION";
static NSString * const kQMNotificationCategoryReply = @"TEXT_REPLY";
static NSString * const kQMSubscriptionKey = @"SUBSCRIPTION_KEY";
static NSString * const kQMDeviceTokenKey = @"DEVICE_TOKEN_KEY";

typedef void(^QBTokenCompletionBlock)(NSData *token, NSError *error);

@interface QMPushNotificationManager () {
    QBMSubscription *internalSubscription;
    NSData *internalToken;
}

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;
@property (copy, nonatomic) QBTokenCompletionBlock tokenCompletionBlock;


@end

@implementation QMPushNotificationManager

@dynamic serviceManager;


- (BFTask *)unregisterFromPushNotificationsAndUnsubscribe:(BOOL)shouldUnsubscribe {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    if (shouldUnsubscribe) {
        [[self unSubscribeFromPushNotifications] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            
            if (t.isCancelled) {
                [source trySetCancelled];
            }
            else if (t.error) {
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
    NSLog(@"<QMPushNotificationManager> 2. Get device token");
    if (self.deviceToken) {
        NSLog(@"<QMPushNotificationManager> 2. Has token in memory");
        [source setResult:self.deviceToken];
    }
    
    if (self.subscription) {
        
        NSParameterAssert(self.subscription.deviceToken.length);
        
        self->internalToken = self.subscription.deviceToken;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self->internalToken];
        [self.userDefaults setObject:data forKey:kQMDeviceTokenKey];
        [self.userDefaults synchronize];
        
        NSLog(@"<QMPushNotificationManager> 2. Has token from subscription");
        [source setResult:self.deviceToken];
        
    }
    else {
        [self getDeviceTokenWithCompletion:^(NSData *token, NSError *error) {
            NSLog(@"<QMPushNotificationManager> 2. Get device token with completion token:%@ error%@", token,error);
            if (token) {
                self -> internalToken = token;
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self->internalToken];
                [self.userDefaults setObject:data forKey:kQMDeviceTokenKey];
                [self.userDefaults synchronize];
                
                [source setResult:token];
            }
            else {
                [source setError:error];
            }
        }];
    }
    return source.task;
}

- (BFTask *)registerAndSubscribeForPushNotifications {
    
    return [[self getSubscription] continueWithBlock:^id _Nullable(BFTask * _Nonnull getSubscriptionTask) {
        
        if (getSubscriptionTask.result != nil) {
            return [BFTask taskWithResult:getSubscriptionTask.result];
        }
        else if (getSubscriptionTask.error) {
            return [BFTask taskWithError:getSubscriptionTask.error];
        }
        
        return [[self getDeviceToken] continueWithBlock:^id _Nullable(BFTask * _Nonnull getDeviceTokenTask) {
            if (getDeviceTokenTask.error) {
                return [BFTask taskWithError:getDeviceTokenTask.error];
            }
            return [[self subscribeForPushNotifications] continueWithBlock:^id _Nullable(BFTask * _Nonnull subsribeTask) {
                if (subsribeTask.error) {
                    return [BFTask taskWithError:subsribeTask.error];
                }
                else {
                    QBMSubscription *subscription = subsribeTask.result;
                    subscription.deviceToken = self.deviceToken;
                    [self setSubscription:subscription];
                    return [BFTask taskWithResult:subscription];
                }
            }];
        }];
    }];
    
}

- (void)setSubscription:(QBMSubscription *)subscription {
    
    if (subscription.deviceToken == nil) {
        NSParameterAssert(NO);
    }
    
    internalSubscription = [subscription copy];
    NSLog(@"<QMPushNotificationManager> SET subscription :%@", self.subscription);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.subscription];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kQMSubscriptionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (QBMSubscription *)subscription {
    
    NSLog(@"<QMPushNotificationManager>GET subscription :%@", internalSubscription);
    
    if (internalSubscription) {
        return internalSubscription;
    }
    
    NSData *data = [self.userDefaults objectForKey:kQMSubscriptionKey];
    internalSubscription = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"<QMPushNotificationManager>GET DATA  subscription :%@", internalSubscription);
    return internalSubscription;
}

- (NSData *)deviceToken {
    
    if (internalToken) {
        return internalToken;
    }
    
    NSData *data = [self.userDefaults objectForKey:kQMDeviceTokenKey];
    internalToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return internalToken;
}

- (BFTask *)subscribeForPushNotifications {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSLog(@"<QMPushNotificationManager> 3. Subscribe with token:%@", self.deviceToken);
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = self.deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse * _Nonnull __unused response, NSArray<QBMSubscription *> * _Nullable __unused objects) {
        NSLog(@"<QMPushNotificationManager> 3. Subscribe with token result:%@", subscription);
        [source setResult:subscription];
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        NSLog(@"<QMPushNotificationManager> 3. Subscribe with token error:%@", response.error.error);
        [source setError:response.error.error];
    }];
    
    return source.task;
}

- (BFTask *)unSubscribeFromPushNotifications {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;
    [QBRequest unregisterSubscriptionForUniqueDeviceIdentifier:deviceIdentifier successBlock:^(QBResponse * _Nonnull __unused response) {
        self->internalSubscription = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kQMSubscriptionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}


- (void)handleActionWithIdentifier:(NSString *)identifier
                remoteNotification:(NSDictionary *)userInfo
                      responseInfo:(NSDictionary *)responseInfo
                 completionHandler:(void(^)())completionHandler {
    
    if ([identifier isEqualToString:kQMNotificationActionTextAction]) {
        //  [QMCore instance].pushNotificationManager
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

- (void)handleToken:(NSData *)token {
    
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

- (BFTask *)getSubscription {
    
    NSLog(@"<QMPushNotificationManager> 1. Get subscriptions");
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    if (self.subscription) {
        if (![self isRegistered]) {
            [self registerForPushNotifications];
        }
        NSLog(@"<QMPushNotificationManager> 1. Has subscriptions");
        [source setResult:self.subscription];
    }
    else {
        //TODO : ADD REST METHOD; nil for now
        NSLog(@"<QMPushNotificationManager> 1. Hasn't subscriptions");
        [source setResult:nil];
    }
    
    return source.task;
}

- (BOOL)isRegistered {
    BOOL registered = [[self application] isRegisteredForRemoteNotifications];
    NSLog(@"<QMPushNotificationManager> isRegistered = %@", registered ? @"YES":@"NO");
    return registered;
}

- (UIApplication *)application {
    return [UIApplication sharedApplication];
}

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

@end
