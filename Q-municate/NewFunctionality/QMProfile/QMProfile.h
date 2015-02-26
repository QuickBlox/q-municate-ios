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

/**
 *  Creates and returns an user profile. (Automatically loaded from keychain)
 */
+ (instancetype)profile;

/**
 *  Writes any modifications to the persistent domains to keychain and updates all unmodified persistent domains to what is on keychain.
 *
 *  @return YES if the data was saved successfully to disk, otherwise NO.
 */
- (BOOL)synchronize;

/**
 *  Writes QBUUser data to the persistent domains to keychain.
 *
 *  @return YES if the data was saved successfully to disk, otherwise NO.
 */
- (BOOL)synchronizeWithUserData:(QBUUser *)user;

/**
 *  Writes QBUUser data to the persistent domains to Quickblox server.
 *
 *  @param completion Block with response YES if the data was saved successfully, otherwise NO.
 */
- (void)saveOnServer:(void (^)(BOOL success))completion;

/**
 *  Update user image. Writes QBUUser data to the persistent domains to Quickblox server and keychain.
 *
 *  @param userImage  UIImage instance
 *  @param progress   Block with upload progress
 *  @param completion Block with response YES if the data was saved successfully, otherwise NO.
 */
- (void)updateUserImage:(UIImage *)userImage
               progress:(void (^)(float progress))progress
             completion:(void (^)(BOOL success))completion;
/**
 *  Change password. Writes QBUUser data to the persistent domains to Quickblox server and keychain.
 *
 *  @param newPassword New password string
 *  @param completion  Block with response YES if the data was saved successfully, otherwise NO.
 */
- (void)changePassword:(NSString *)newPassword
            completion:(void(^)(BOOL success))completion;

/**
 *  Remove profile from keychain
 *
 *  @return YES if the data was cleared successfully, otherwise NO.
 */
- (BOOL)clearProfile;

@end
