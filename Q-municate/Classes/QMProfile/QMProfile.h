//
//  QMProfile.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class provides profile.
 */
@interface QMProfile : NSObject <NSCoding>

@property (strong, nonatomic, QB_NULLABLE_PROPERTY) QBUUser *userData;
@property (assign, nonatomic) BOOL rememberMe;

@property (assign, nonatomic) BOOL userAgreementAccepted;
@property (assign, nonatomic) BOOL pushNotificationsEnabled;

/**
 *  Returns loaded current profile with user.
 *
 *  @return current profile
 */
+ (QB_NONNULL instancetype)currentProfile;

//- (BOOL)synchronize;

- (BOOL)synchronizeWithUserData:(QB_NONNULL QBUUser *)userData;

- (BOOL)clearProfile;

- (QB_NONNULL BFTask QB_GENERIC(QBUUser *) *)updateUserImage:(QB_NONNULL UIImage *)userImage progress:(QB_NULLABLE QMContentProgressBlock)progress;
- (QB_NONNULL BFTask *)resetPasswordForEmail:(QB_NONNULL NSString *)email;

@end
