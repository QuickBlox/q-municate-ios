//
//  QMApi.h
//  Qmunicate
//
//  Created by Andrey on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMAuthService;
@class QMSettingsManager;
@class QMFacebookService;
@class QMContactList;

@interface QMApi : NSObject

@property (strong, nonatomic, readonly) QMAuthService *authService;
@property (strong, nonatomic, readonly) QMSettingsManager *settingsManager;
@property (strong, nonatomic, readonly) QMFacebookService *facebookService;
@property (strong, nonatomic, readonly) QMContactList *contactList;

+ (instancetype)shared;

- (void)loginWithFacebook:(void(^)(BOOL success))completion;
- (void)loginWithUser:(QBUUser *)user completion:(QBUUserLogInResultBlock)complition;
- (void)signUpAndLoginWithUser:(QBUUser *)user userAvatar:(UIImage *)userAvatar completion:(QBUUserResultBlock)completion;

@end
