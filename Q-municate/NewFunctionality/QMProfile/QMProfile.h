//
//  QMProfile.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMProfile : NSObject <NSCoding>

@property (strong, nonatomic) QBUUser *userData;

@property (assign, nonatomic) BOOL userAgreementAccepted;
@property (assign, nonatomic) BOOL pushNotificationsEnabled;
@property (assign, nonatomic) BOOL userOfflineState;

- (BOOL)synchronize;
- (BOOL)synchronizeWithUserData:(QBUUser *)user;

- (void)updateUserWithCompletion:(void (^)(BOOL success))completion;

- (void)updateUserWithImage:(UIImage *)userImage
                   progress:(void (^)(float progress))progress
                 completion:(void (^)(BOOL success))completion;

- (void)changePassword:(NSString *)newPassword
            completion:(void(^)(BOOL success))completion;

- (BOOL)clearProfile;

@end
