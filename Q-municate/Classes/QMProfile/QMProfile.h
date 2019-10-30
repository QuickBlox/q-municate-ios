//
//  QMProfile.h
//  Q-municate
//
//  Created by Injoit on 1/8/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

@class QMProfile;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Account type enum.
 */
typedef NS_ENUM(NSInteger, QMAccountType) {
    /**
     *  Account type is not determined.
     */
    QMAccountTypeNone,
    /**
     *  Account type is email.
     */
    QMAccountTypeEmail,
    /**
     *  Account type is facebook.
     */
    QMAccountTypeFacebook,
    /**
     *  Account type is Phone number.
     */
    QMAccountTypePhone
};

/**
 *  QMProfileDelegate protocol. Used to notify about profile changes.
 */
@protocol QMProfileDelegate <NSObject>

/**
 *  Protocol methods down below are required to be implemented
 */
@required

/**
 *  Notifying about user data being updated in current profile.
 *
 *  @param currentProfile current profile
 *  @param userData       updated user data
 */
- (void)profile:(QMProfile *)currentProfile didUpdateUserData:(QBUUser *)userData;

@end

/**
 *  QMProfile class interface.
 *  This class provides user profile management.
 */
@interface QMProfile : NSObject <NSCoding>

/**
 *  Delegate instance that conforms to QMProfileDelegate protocol.
 */
@property (weak, nonatomic, nullable) id<QMProfileDelegate> delegate;

/**
 *  User data.
 */
@property (strong, nonatomic, readonly, nullable) QBUUser *userData;

/**
 *  User account type.
 */
@property (assign, nonatomic) QMAccountType accountType;

/**
 *  Whether user agreement was already accepted.
 */
@property (assign, nonatomic) BOOL userAgreementAccepted;

/**
 *  Whether push notifications are enabled.
 */
@property (assign, nonatomic) BOOL pushNotificationsEnabled;

/**
 *  Last dialogs fetching date with QBRequest from server.
 */
@property (strong, nonatomic, nullable) NSDate *lastDialogsFetchingDate;

/**
 *  Last user fetch date with QBRequest from server.
 */
@property (strong, nonatomic, nullable) NSDate *lastUserFetchDate;

/**
 *  Returns loaded current profile with user.
 *
 *  @return current profile
 */
+ (nullable instancetype)currentProfile;

/**
 *  Synchronize current profile in keychain.
 *
 *  @return whether synchronize was successful
 */
- (BOOL)synchronize;

/**
 *  Synchronize user data in keychain.
 *
 *  @param userData user data to synchronize
 *
 *  @return whether synchronize was successful
 */
- (BOOL)synchronizeWithUserData:(QBUUser *)userData;

/**
 *  Remove all user data.
 *
 *  @return Whether clear was successful
 */
- (BOOL)clearProfile;

@end

NS_ASSUME_NONNULL_END
