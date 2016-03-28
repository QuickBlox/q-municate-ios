//
//  QMProfile.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QMAccountType) {
    QMAccountTypeNone,
    QMAccountTypeEmail,
    QMAccountTypeFacebook,
    QMAccountTypeDigits
};

/**
 *  This class provides profile.
 */
@interface QMProfile : NSObject <NSCoding>

@property (strong, nonatomic, nullable) QBUUser *userData;
@property (assign, nonatomic) QMAccountType accountType;
@property (assign, nonatomic) BOOL skipSync;

@property (assign, nonatomic) BOOL userAgreementAccepted;
@property (assign, nonatomic) BOOL pushNotificationsEnabled;

/**
 *  Returns loaded current profile with user.
 *
 *  @return current profile
 */
+ (nullable instancetype)currentProfile;

//- (BOOL)synchronize;

- (BOOL)synchronizeWithUserData:(QBUUser *)userData;

- (BOOL)clearProfile;

- (BFTask <QBUUser *> *)updateUserImage:(UIImage *)userImage progress:(nullable QMContentProgressBlock)progress;
- (BFTask *)resetPasswordForEmail:(NSString *)email;

@end

NS_ASSUME_NONNULL_END
