//
//  QMPushNotificationManager.m
//  Q-municate
//
//  Created by Injoit on 5/10/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMPushNotificationManager.h"

#import "QMCore.h"

#import <PushKit/PushKit.h>

static NSString * const kQMNotificationActionTextAction = @"TEXT_ACTION";
static NSString * const kQMNotificationCategoryReply = @"TEXT_REPLY";

typedef void(^QBTokenCompletionBlock)(NSData *token, NSError *error);

@interface QMPushNotificationManager () <PKPushRegistryDelegate>

@property (weak, nonatomic) QMCore <QMServiceManagerProtocol>*serviceManager;
@property (copy, nonatomic) QBTokenCompletionBlock tokenCompletionBlock;
@property (copy, nonatomic, nullable, readwrite) NSData *deviceToken;
@property (nonatomic, strong) NSMutableSet<QBMSubscription *>*subscriptions;

@property (strong, nonatomic) PKPushRegistry *voipRegistry;

@end

@implementation QMPushNotificationManager
@dynamic serviceManager;

- (NSMutableSet<QBMSubscription *> *)subscriptions {
    if (!_subscriptions) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [defaults objectForKey:@"_subscriptions"];
        NSMutableSet *subscriptions = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        _subscriptions = subscriptions ?: [NSMutableSet set];
    }
    return _subscriptions;
}

- (void)synchronizeSubscriptions {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.subscriptions];
    [defaults setObject:data forKey:@"_subscriptions"];
    [defaults synchronize];
}

- (BFTask *)unregisterFromAllNotificationsAndUnsubscribe {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    [UIApplication.sharedApplication unregisterForRemoteNotifications];
    
    self.voipRegistry = nil;
    
    dispatch_group_t serviceGroup = dispatch_group_create();
    NSSet<QBMSubscription *>*subscriptions = self.subscriptions.copy;
    for (QBMSubscription *subscription in subscriptions) {
        dispatch_group_enter(serviceGroup);
        NSString *chanel = subscription.notificationChannel ==
        QBMNotificationChannelAPNSVOIP ? @"VOIP" : @"PUSH";
        [NSString stringWithFormat:@"Unregister %@ Subscription request", chanel];
        [QBRequest deleteSubscriptionWithID:subscription.ID
                               successBlock:^(QBResponse *  response) {
                                   QMSLog([chanel stringByAppendingString:@" - Success"]);
                                   dispatch_group_leave(serviceGroup);
                               } errorBlock:^(QBResponse *response) {
                                   NSString *errorMessage = [NSString stringWithFormat:@" - Error: %@",
                                                             [response.error reasons]];
                                   QMSLog([chanel stringByAppendingString:errorMessage]);
                                   dispatch_group_leave(serviceGroup);
                               }];
        
    }
    @weakify(self);
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        @strongify(self);
        [self.subscriptions removeAllObjects];
        [self synchronizeSubscriptions];
       [source setResult:nil];
    });
    
    return source.task;
}

- (BFTask *)unregisterFromPushNotificationsAndUnsubscribe {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    dispatch_group_t serviceGroup = dispatch_group_create();
    NSSet<QBMSubscription *>*subscriptions = self.subscriptions.copy;
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSMutableArray *toDelete = @[].mutableCopy;
    for (QBMSubscription *subscription in subscriptions) {
        if (subscription.notificationChannel != QBMNotificationChannelAPNS ||
            ![subscription.deviceUDID isEqualToString:deviceIdentifier]) {
            continue;
        }
        dispatch_group_enter(serviceGroup);
        NSString *chanel =  @"PUSH";
        [NSString stringWithFormat:@"Unregister %@ Subscription request", chanel];
        [QBRequest deleteSubscriptionWithID:subscription.ID
                               successBlock:^(QBResponse *  response) {
                                   [UIApplication.sharedApplication unregisterForRemoteNotifications];
                                   QMSLog([chanel stringByAppendingString:@" - Success"]);
                                   [toDelete addObject:subscription];
                                   dispatch_group_leave(serviceGroup);
                               } errorBlock:^(QBResponse *response) {
                                   [UIApplication.sharedApplication unregisterForRemoteNotifications];
                                   NSString *errorMessage = [NSString stringWithFormat:@" - Error: %@",
                                                             [response.error reasons]];
                                   QMSLog([chanel stringByAppendingString:errorMessage]);
                                   [toDelete addObject:subscription];
                                   dispatch_group_leave(serviceGroup);
                               }];
        
    }
    @weakify(self);
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        @strongify(self);
        for (QBMSubscription *subscription in toDelete) {
            [self.subscriptions removeObject:subscription];
        }
        [self synchronizeSubscriptions];
        [source setResult:nil];
    });
    
    return source.task;
}

- (void)getDeviceTokenWithCompletion:(QBTokenCompletionBlock)tokenCompletionBlock {
    
    _tokenCompletionBlock = [tokenCompletionBlock copy];
    [self registerForPushNotifications];
}

// MARK: - Subscriptions

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
    
    @weakify(self);
    [QBRequest createSubscription:subscription
                     successBlock:^(QBResponse * _Nonnull  response,
                                    NSArray<QBMSubscription *> * _Nullable  objects) {
                         @strongify(self);
                         for (QBMSubscription *subscription in objects) {
                             if ([subscription.deviceUDID isEqualToString:deviceIdentifier]) {
                                 [self.subscriptions addObject:subscription];
                             }
                         }
                         [self synchronizeSubscriptions];
                         [source setResult:subscription];
                     } errorBlock:^(QBResponse * _Nonnull response) {
                         [source setError:response.error.error];
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
    
    [[[[self.serviceManager.chatService fetchDialogWithID:dialogID]
       continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
           if (task.result != nil) {
               
               chatDialog = task.result;
               
               return [self.serviceManager.usersService getUsersWithIDs:task.result.occupantIDs];
           }
           
           if ([delegate respondsToSelector:@selector(pushNotificationManagerDidStartLoadingDialogFromServer:)]) {
               [delegate pushNotificationManagerDidStartLoadingDialogFromServer:self];
           }
           
           return [self.serviceManager.chatService loadDialogWithID:dialogID];
       }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
           
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
           
       }] continueWithBlock:^id _Nullable(BFTask * _Nonnull  task) {
           
           dispatch_async(dispatch_get_main_queue(), ^{
               [delegate pushNotificationManager:self didSucceedFetchingDialog:chatDialog];
           });
           
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
    
    [UIApplication.sharedApplication registerUserNotificationSettings:notificationSettings];
    
    // subscribing for PKPushRegistry
    // only if call kit supported
    // as this is the only case for now
    if (QMCallManager.isCallKitAvailable
        && self.voipRegistry == nil) {
        self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
        self.voipRegistry.delegate = self;
        self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    }
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
        
        UIApplication *application = UIApplication.sharedApplication;
        
        __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
            
            [application endBackgroundTask:task];
            task = UIBackgroundTaskInvalid;
        }];
        
        // Do the work associated with the task.
        QMSLog(@"Started background task timeremaining = %f", [application backgroundTimeRemaining]);
        
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

// MARK: - PKPushRegistryDelegate protocol

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType) type {
    QMSLog(@"Created VOIP push token.");
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNSVOIP;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = pushCredentials.token;
    
    @weakify(self);
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *  response, NSArray *  objects) {
        @strongify(self);
        QMSLog(@"Create VOIP Subscription request - Success");
        for (QBMSubscription *subscription in objects) {
            if ([subscription.deviceUDID isEqualToString:deviceIdentifier]) {
                [self.subscriptions addObject:subscription];
            }
        }
        [self synchronizeSubscriptions];
    } errorBlock:^(QBResponse *response) {
        QMSLog(@"Create VOIP Subscription request - Error: %@", [response.error reasons]);
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType) type {
    QMSLog(@"Invalidated VOIP push token.");
    dispatch_group_t serviceGroup = dispatch_group_create();
    NSSet<QBMSubscription *>*subscriptions = self.subscriptions.copy;
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSMutableArray *toDelete = @[].mutableCopy;
    for (QBMSubscription *subscription in subscriptions) {
        if (subscription.notificationChannel != QBMNotificationChannelAPNSVOIP ||
            ![subscription.deviceUDID isEqualToString:deviceIdentifier]) {
            continue;
        }
        dispatch_group_enter(serviceGroup);
        NSString *chanel =  @"VOIP";
        [NSString stringWithFormat:@"Unregister %@ Subscription request", chanel];
        [QBRequest deleteSubscriptionWithID:subscription.ID
                               successBlock:^(QBResponse *  response) {
                                   QMSLog([chanel stringByAppendingString:@" - Success"]);
                                   [toDelete addObject:subscription];
                                   dispatch_group_leave(serviceGroup);
                               } errorBlock:^(QBResponse *response) {
                                   NSString *errorMessage = [NSString stringWithFormat:@" - Error: %@",
                                                             [response.error reasons]];
                                   QMSLog([chanel stringByAppendingString:errorMessage]);
                                   [toDelete addObject:subscription];
                                   dispatch_group_leave(serviceGroup);
                               }];
        
    }
    @weakify(self);
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        @strongify(self);
        for (QBMSubscription *subscription in toDelete) {
            [self.subscriptions removeObject:subscription];
        }
        [self synchronizeSubscriptions];
    });
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType) type {
    if (QMCallManager.isCallKitAvailable
        && [payload.dictionaryPayload objectForKey:QMVoipCallEventKey] != nil) {
        [self.serviceManager.callManager performCallKitPreparations];
    }
}

@end
