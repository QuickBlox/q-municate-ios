//
//  QMServiceManager.h
//  QMServices
//
//  Created by Injoit on 5/19/15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMServices.h"
#import "QMServiceManagerProtocol.h"
#import "QMChatService.h"
#import "QMAuthService.h"
#import "QMUsersService.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Base manager that handles authentication and chat functionality.
 */
@interface QMServicesManager : NSObject
<
QMServiceManagerProtocol,
QMChatServiceCacheDataSource,
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMUsersServiceCacheDataSource,
QMUsersServiceDelegate
>

/**
 *  REST authentication service.
 */
@property (strong, nonatomic, readonly) QMAuthService *authService;

/**
 *  Chat service.
 */
@property (strong, nonatomic, readonly) QMChatService *chatService;

/**
 *  Users service.
 */
@property (strong, nonatomic, readonly) QMUsersService *usersService;

+ (instancetype)instance;

/**
 *  Determines whether extended services logging is enabled.
 *
 *  @param flag whether logs should be enabled or not
 *
 *  @discussion By default logs are enabled.
 *
 *  @note If you don't want logs in production environment you should disable them within this flag.
 */
+ (void)enableLogging:(BOOL)flag;

/**
 *  Login to quickblox REST and chat, group dialog join.
 *
 *  @param user       QBUUser for login.
 *  @param completion Completion block with a result.
 */
- (void)logInWithUser:(QBUUser *)user completion:(nullable void(^)(BOOL success, NSString * _Nullable errorMessage))completion;

/**
 *  Logouts from quickblox REST and chat, clears dialogs and messages.
 *
 *  @param completion Completion block with a result.
 */
- (void)logoutWithCompletion:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
